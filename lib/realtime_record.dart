import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RealtimeRecordPage extends StatelessWidget {
  const RealtimeRecordPage({Key? key}) : super(key: key);

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
              height: 405,
              width: double.infinity,
              color: Color(0xFF18181A),
              child: Center(
                child: Text(
                  'Waveform Placeholder',
                  style: TextStyle(color: Colors.white24, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Timer with red dot
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '00:10.1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 86),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 48, bottom: 32, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Stop
                  Container(
                    width: 76,
                    height: 76,
                    child: IconButton(
                      icon: SvgPicture.asset('resources/icons/icon_mic_stop.svg', width: 32, height: 32, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  // Pause
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset('resources/icons/icon_mic_pause.svg', width: 32, height: 32, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  // Bookmark
                  Container(
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