import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mic_stream/mic_stream.dart';
import 'dart:async';
import 'dart:math';

class RealtimeRecordPage extends StatefulWidget {
  const RealtimeRecordPage({Key? key}) : super(key: key);

  @override
  State<RealtimeRecordPage> createState() => _RealtimeRecordPageState();
}

class _RealtimeRecordPageState extends State<RealtimeRecordPage> {
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        _timer?.cancel();
      } else {
        _isRecording = true;
        _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          setState(() {
            _elapsed += const Duration(milliseconds: 100);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final ms = (d.inMilliseconds % 1000) ~/ 100;
    final s = d.inSeconds % 60;
    final m = d.inMinutes;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('resources/icons/back.svg', width: 20, height: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '실시간 통역',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset('resources/icons/search.svg', width: 28, height: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'resources/images/realtime_bullet_title.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '강남구 언주로',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '2025-06-19 오전 09:10',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            // Waveform placeholder fixed height
            Container(
              height: 365,
              width: double.infinity,
              color: Color(0xFF18181A),
              child: const WebWaveform(),
            ),
            const SizedBox(height: 25),
            // Timer (always centered, with red dot to the left when recording)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 16),
                      child: Visibility(
                        visible: _isRecording,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_elapsed),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 46),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, bottom: 32, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: IconButton(
                      icon: SvgPicture.asset('resources/icons/icon_mic_stop.svg', width: 32, height: 32, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  // Play/Pause (center)
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: IconButton(
                        icon: _isRecording
                            ? SvgPicture.asset('resources/icons/icon_mic_pause.svg', width: 32, height: 32, color: Colors.white)
                            : const Icon(Icons.play_arrow, size: 40, color: Colors.white),
                        onPressed: _toggleRecording,
                      ),
                    ),
                  ),
                  // Bookmark
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: IconButton(
                      icon: SvgPicture.asset('resources/icons/icon_mic_bookmark.svg', width: 32, height: 32, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebWaveform extends StatefulWidget {
  const WebWaveform({Key? key}) : super(key: key);

  @override
  State<WebWaveform> createState() => _WebWaveformState();
}

class _WebWaveformState extends State<WebWaveform> {
  Stream<List<int>>? stream;
  List<int> samples = List.filled(128, 0);
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    _initMic();
  }

  Future<void> _initMic() async {
    stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 44100,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
    );
    subscription = stream?.listen((data) {
      setState(() {
        samples = data.take(128).toList();
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 405),
      painter: _WaveformPainter(samples),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<int> samples;
  _WaveformPainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = i * size.width / samples.length;
      final y = size.height / 2 - (samples[i] / 32768.0) * (size.height / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
} 