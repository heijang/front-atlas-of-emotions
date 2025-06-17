import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'emotion_report_page.dart';
import 'mypage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(
        home: RecorderPageRealtime(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class RecorderPageRealtime extends StatefulWidget {
  const RecorderPageRealtime({Key? key}) : super(key: key);

  @override
  State<RecorderPageRealtime> createState() => _RecorderPageRealtimeState();
}

class _RecorderPageRealtimeState extends State<RecorderPageRealtime> {
  WebSocketChannel? _wsChannel;
  bool _isMicRecording = false;
  bool _isMp3Streaming = false;
  Timer? _timer;
  int _recordSeconds = 0;
  int _lastRecordSeconds = 0;
  bool _isMp3FilePicked = false;
  String? _selectedMp3FileName;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 기본 mp3 파일 자동 선택
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDefaultMp3File();
    });
  }

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isMicRecording) return;
    try {
      // 1. WebSocket 연결 (이미 연결되어 있으면 재연결하지 않음)
      if (_wsChannel == null) {
        _wsChannel = WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws'));
        _wsChannel!.stream.listen((message) {
          print('서버로부터 메시지: $message');
        }, onDone: () {
          print('WebSocket 연결 종료');
        }, onError: (error) {
          print('WebSocket 에러: $error');
        });
        print('WebSocket 연결 시도');
      } else {
        print('WebSocket 이미 연결됨');
      }

      // 2. JS interop으로 PCM 스트림 시작
      bool audioEventSent = false;
      js.context['onPCMChunk'] = (dynamic jsUint8Array) {
        try {
          final length = js_util.getProperty(jsUint8Array, 'length') as int;
          final list = List<int>.generate(
            length,
            (i) => js_util.getProperty(jsUint8Array, i) as int,
          );
          final uint8List = Uint8List.fromList(list);
          if (_wsChannel != null) {
            if (!audioEventSent) {
              print('[WebSocket] audio_data 이벤트 전송');
              _wsChannel!.sink.add(jsonEncode({"event": "audio_data"}));
              audioEventSent = true;
            }
            _wsChannel!.sink.add(uint8List);
          }
        } catch (e) {
          print('Error converting JS Uint8Array to Uint8List: $e');
        }
      };
      js.context.callMethod('startPCMStream');

      // 타이머 시작
      _recordSeconds = _lastRecordSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordSeconds++;
        });
      });

      setState(() {
        _isMicRecording = true;
        _lastRecordSeconds = 0;
      });
    } catch (e) {
      print('녹음 시작 실패: $e');
      _stopRecording();
    }
  }

  void _stopRecording() {
    js.context.callMethod('stopPCMStream');
    _timer?.cancel();
    _timer = null;
    _lastRecordSeconds = _recordSeconds;
    if (_wsChannel != null) {
      _wsChannel!.sink.close();
      _wsChannel = null;
    }
    setState(() {
      _isMicRecording = false;
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // mp3 파일 선택
  Future<void> _pickMp3File() async {
    js.context['onMp3FilePicked'] = (file) {
      setState(() {
        _isMp3FilePicked = true;
        _selectedMp3FileName = file != null && file.name != null ? file.name : '선택된 파일 없음';
      });
    };
    js.context.callMethod('pickMp3File');
  }

  // mp3 스트리밍 시작
  Future<void> _startMp3Streaming() async {
    if (_isMp3Streaming) return;
    // 1. WebSocket 연결 (이미 연결되어 있으면 재연결하지 않음)
    if (_wsChannel == null) {
      _wsChannel = WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws'));
      _wsChannel!.stream.listen((message) {
        print('서버로부터 메시지: $message');
      }, onDone: () {
        print('WebSocket 연결 종료');
      }, onError: (error) {
        print('WebSocket 에러: $error');
      });
      print('WebSocket 연결 시도');
    } else {
      print('WebSocket 이미 연결됨');
    }
    bool audioEventSent = false;
    js.context['onPCMChunk'] = (dynamic jsUint8Array) {
      try {
        final length = js_util.getProperty(jsUint8Array, 'length') as int;
        final list = List<int>.generate(
          length,
          (i) => js_util.getProperty(jsUint8Array, i) as int,
        );
        final uint8List = Uint8List.fromList(list);
        if (_wsChannel != null) {
          if (!audioEventSent) {
            print('[WebSocket] audio_data 이벤트 전송');
            _wsChannel!.sink.add(jsonEncode({"event": "audio_data"}));
            audioEventSent = true;
          }
          _wsChannel!.sink.add(uint8List);
        }
      } catch (e) {
        print('Error converting JS Uint8Array to Uint8List: $e');
      }
    };
    js.context.callMethod('startMp3Streaming');
    setState(() {
      _isMp3Streaming = true;
      _lastRecordSeconds = 0;
      _recordSeconds = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  // mp3 스트리밍 정지
  void _stopMp3Streaming() {
    js.context.callMethod('stopMp3Streaming');
    _timer?.cancel();
    _timer = null;
    _lastRecordSeconds = _recordSeconds;
    if (_wsChannel != null) {
      _wsChannel!.sink.close();
      _wsChannel = null;
    }
    setState(() {
      _isMp3Streaming = false;
    });
  }

  // 기본 파일 자동 선택
  Future<void> _setDefaultMp3File() async {
    js.context['onMp3FilePicked'] = (file) {
      setState(() {
        _isMp3FilePicked = true;
        _selectedMp3FileName = file != null && file.name != null ? file.name : '선택된 파일 없음';
      });
    };
    js.context.callMethod('setDefaultMp3File');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '실시간 감정 통역',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: null,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isLoggedIn && auth.userName != null && auth.userName!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      '${auth.userName} 님',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 버튼 Row (타이틀 아래)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6D00), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(90, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyPage()),
                    );
                  },
                  icon: const Text('🧑', style: TextStyle(fontSize: 14, color: Color(0xFFFF6D00), fontWeight: FontWeight.bold)),
                  label: Consumer<AuthProvider>(
                    builder: (context, auth, _) => Text(
                      auth.isLoggedIn ? '마이페이지' : '회원가입',
                      style: const TextStyle(
                        color: Color(0xFFFF6D00),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(90, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmotionReportPage()),
                    );
                  },
                  icon: const Text('📄', style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
                  label: const Text(
                    '감정 리포트',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // 실시간 녹음 블럭
            Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // 연한 블루
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('실시간 녹음', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (_isMicRecording || _isMp3Streaming) ? null : _startRecording,
                        child: const Text('시작'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isMicRecording ? _stopRecording : null,
                        child: const Text('정지'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64B5F6), // 시작과 비슷한 블루 계열
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // mp3 전송 블럭
            Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // 연한 그린
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('mp3 전송', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (_isMicRecording || _isMp3Streaming) ? null : _pickMp3File,
                        child: const Text('파일 선택'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_isMicRecording || _isMp3Streaming) ? null : _setDefaultMp3File,
                        child: const Text('기본파일 선택'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (_isMicRecording || _isMp3Streaming || !_isMp3FilePicked) ? null : _startMp3Streaming,
                        child: const Text('시작'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isMp3Streaming ? _stopMp3Streaming : null,
                        child: const Text('정지'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMp3Streaming ? const Color(0xFF388E3C) : const Color(0xFF81C784),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedMp3FileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.audiotrack, size: 18, color: Color(0xFF388E3C)),
                          const SizedBox(width: 6),
                          Text(
                            '파일: $_selectedMp3FileName',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF388E3C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 녹음중/정지 이모지와 시간 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (_isMicRecording || _isMp3Streaming)
                    ? const Text('🔴', style: TextStyle(color: Colors.red, fontSize: 20))
                    : const Text('⚫️', style: TextStyle(color: Colors.black, fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _formatDuration((_isMicRecording || _isMp3Streaming) ? _recordSeconds : _lastRecordSeconds),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 