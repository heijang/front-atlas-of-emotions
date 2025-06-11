import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: RecorderPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class RecorderPage extends StatefulWidget {
  const RecorderPage({Key? key}) : super(key: key);

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  html.WebSocket? _webSocket;
  bool _isRecording = false;
  List<Uint8List> _chunks = [];
  Timer? _timer;
  int _recordSeconds = 0;
  int _lastRecordSeconds = 0;
  bool _pendingStop = false;

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // 1. 마이크 권한 요청 및 스트림 획득
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'audio': true});
      if (stream == null) throw Exception('마이크 스트림을 가져올 수 없습니다.');
      _mediaStream = stream;

      // 2. 웹소켓 연결
      _webSocket = html.WebSocket('ws://localhost:8000/ws');
      _webSocket!.binaryType = 'arraybuffer';

      // 3. MediaRecorder 생성 및 이벤트 핸들러 등록
      _mediaRecorder = html.MediaRecorder(_mediaStream!);
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final dynamic e = event as html.Event;
        final blob = (e as dynamic).data;
        if (blob != null) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(blob);
          reader.onLoadEnd.listen((_) {
            if (reader.result != null && _webSocket != null && _webSocket!.readyState == html.WebSocket.OPEN) {
              _webSocket!.send(reader.result);
            }
            if (_pendingStop) {
              _webSocket?.close();
              _webSocket = null;
              _pendingStop = false;
            }
          });
        } else {
          if (_pendingStop) {
            _webSocket?.close();
            _webSocket = null;
            _pendingStop = false;
          }
        }
      });
      _mediaRecorder!.addEventListener('error', (event) {
        print('녹음 에러: $event');
      });

      // 4. 녹음 시작 (5초 단위 chunk)
      _mediaRecorder!.start(5000); // 5000ms = 5초

      // 타이머 시작
      _recordSeconds = _lastRecordSeconds;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordSeconds++;
        });
      });

      setState(() {
        _isRecording = true;
        _lastRecordSeconds = 0;
      });
    } catch (e) {
      print('녹음 시작 실패: $e');
      _stopRecording();
    }
  }

  void _stopRecording() {
    _mediaRecorder?.stop();
    _mediaRecorder = null;
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _pendingStop = true;
    _timer?.cancel();
    _timer = null;
    _lastRecordSeconds = _recordSeconds;
    setState(() {
      _isRecording = false;
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('녹음 및 웹소켓 전송 테스트')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: const Text('녹음 시작'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text('정지'),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isRecording
                    ? const Text('🔴', style: TextStyle(color: Colors.red, fontSize: 28))
                    : const Text('⚫️', style: TextStyle(color: Colors.black, fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_isRecording ? _recordSeconds : _lastRecordSeconds),
                  style: TextStyle(
                    fontSize: 32,
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
