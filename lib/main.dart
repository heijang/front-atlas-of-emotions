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
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'ENV/.env');
  print('[dotenv] .env loaded: API_BASE_URL = \'${dotenv.env['API_BASE_URL']}\', WS_BASE_URL = \'${dotenv.env['WS_BASE_URL']}\'');
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

String getApiBaseUrl() {
  return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
}

String getWsBaseUrl() {
  return dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
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

  // 추가: 화자/감정 상태 변수
  String? _speaker; // '본인' 또는 '상대방'
  String? _topEmotion; // 가장 높은 감정(한글)

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
        _wsChannel = WebSocketChannel.connect(Uri.parse('${getWsBaseUrl()}/ws'));
        _wsChannel!.stream.listen((message) {
          print('서버로부터 메시지: $message');
          _handleWsMessage(message); // 메시지 핸들링 추가
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
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.isLoggedIn && auth.userId != null && auth.userId!.isNotEmpty) {
                _wsChannel!.sink.add(jsonEncode({
                  "event": "audio_data",
                  "user_info": {"user_id": auth.userId}
                }));
              } else {
                _wsChannel!.sink.add(jsonEncode({"event": "audio_data"}));
              }
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
    js.context['onMp3FilePickedForMain'] = (file) {
      setState(() {
        _isMp3FilePicked = true;
        _selectedMp3FileName = file != null && file.name != null ? file.name : '선택된 파일 없음';
      });
    };
    js.context.callMethod('pickMp3FileForMain');
  }

  // mp3 스트리밍 시작
  Future<void> _startMp3Streaming() async {
    if (_isMp3Streaming) return;
    // 1. WebSocket 연결 (이미 연결되어 있으면 재연결하지 않음)
    if (_wsChannel == null) {
      _wsChannel = WebSocketChannel.connect(Uri.parse('${getWsBaseUrl()}/ws'));
      _wsChannel!.stream.listen((message) {
        print('서버로부터 메시지: $message');
        _handleWsMessage(message); // 메시지 핸들링 추가
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
            final auth = Provider.of<AuthProvider>(context, listen: false);
            if (auth.isLoggedIn && auth.userId != null && auth.userId!.isNotEmpty) {
              _wsChannel!.sink.add(jsonEncode({
                "event": "audio_data",
                "user_info": {"user_id": auth.userId}
              }));
            } else {
              _wsChannel!.sink.add(jsonEncode({"event": "audio_data"}));
            }
            audioEventSent = true;
          }
          _wsChannel!.sink.add(uint8List);
        }
      } catch (e) {
        print('Error converting JS Uint8Array to Uint8List: $e');
      }
    };
    js.context['onMp3StreamEnd'] = () {
      if (_wsChannel != null) {
        _wsChannel!.sink.close();
        _wsChannel = null;
      }
      setState(() {
        _isMp3Streaming = false;
      });
    };
    js.context.callMethod('startMp3StreamingForMain');
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
    js.context['onMp3FilePickedForMain'] = (file) {
      setState(() {
        _isMp3FilePicked = true;
        _selectedMp3FileName = file != null && file.name != null ? file.name : '선택된 파일 없음';
      });
    };
    js.context.callMethod('setDefaultMp3FileForMain');
  }

  // WebSocket 메시지 핸들러
  void _handleWsMessage(dynamic message) {
    try {
      // JSON 형식이 아니면 무시
      if (message is! String || !message.trim().startsWith('{') || !message.trim().endsWith('}')) {
        return;
      }
      final data = jsonDecode(message);
      if (data is Map) {
        if (data['event'] == 'emotion_analysis') {
          final isSame = data['is_same'] as bool?;
          final emotion = data['emotion'] as Map<String, dynamic>?;
          String? koreanEmotion;
          if (emotion != null && emotion['audio'] != null && emotion['audio']['korean'] != null) {
            koreanEmotion = emotion['audio']['korean'] as String;
          }
          if (isSame != null && koreanEmotion != null) {
            setState(() {
              _speaker = isSame ? '본인' : '상대방';
              _topEmotion = koreanEmotion;
            });
          }
        }
      }
    } catch (e) {
      print('WebSocket 메시지 파싱 오류: $e');
    }
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
            // 화자/감정 표시 영역 추가
            if (_speaker != null && _topEmotion != null)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1.2),
                ),
                child: Column(
                  children: [
                    Text('화자: $_speaker', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('감정: $_topEmotion', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
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
                      auth.isLoggedIn ? '마이페이지' : '로그인',
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