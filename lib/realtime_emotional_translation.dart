import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'voice_emotion_onboarding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'realtime_record.dart';

class RealtimeEmotionalTranslationPage extends StatefulWidget {
  const RealtimeEmotionalTranslationPage({Key? key}) : super(key: key);

  @override
  State<RealtimeEmotionalTranslationPage> createState() => _RealtimeEmotionalTranslationPageState();
}

class _RealtimeEmotionalTranslationPageState extends State<RealtimeEmotionalTranslationPage> {
  bool _showBanner = true;
  final List<Map<String, dynamic>> _conversations = [];
  bool isLoading = true;
  String? error;

  String formatDuration(dynamic durationMs) {
    int ms;
    if (durationMs is int) {
      ms = durationMs;
    } else if (durationMs is String) {
      ms = int.tryParse(durationMs) ?? 0;
    } else {
      ms = 0;
    }
    final seconds = (ms / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() { isLoading = true; error = null; });
    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
      // TODO: 실제 user_uid 값으로 대체 필요
      final userUid = 1;
      final uri = Uri.parse('$apiBaseUrl/api/v1/reports?user_uid=$userUid');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          setState(() {
            _conversations.clear();
            for (final item in jsonData['data']) {
              _conversations.add({
                'title': item['topic'] ?? '제목 없음',
                'created_at': item['created_at'] != null ? DateTime.tryParse(item['created_at']) ?? DateTime.now() : DateTime.now(),
                'duration_ms': item['duration_ms'] ?? '0:00',
              });
            }
            isLoading = false;
          });
        } else {
          setState(() {
            error = '데이터 형식 오류';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = '서버 오류: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '네트워크 오류: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('resources/icons/back.svg', width: 20, height: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '모든 대화 항목',
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
        color: const Color(0xFF141414),
        child: Column(
          children: [
            if (_showBanner)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VoiceEmotionOnboarding()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      image: const DecorationImage(
                        image: AssetImage('resources/images/banner_myvoice_record.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            '목소리 학습을 통해 당신만의\n감정 표현 방식에 더 잘 맞춰드릴게요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showBanner = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                color: const Color(0xFF141414),
                child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                    ? Center(child: Text(error!, style: TextStyle(color: Colors.white)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        itemCount: _conversations.length,
                        separatorBuilder: (context, index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(height: 1, color: Colors.grey[800]),
                        ),
                        itemBuilder: (context, idx) {
                          final item = _conversations[idx];
                          final dt = item['created_at'] as DateTime;
                          final isAm = dt.hour < 12;
                          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                          final minute = dt.minute.toString().padLeft(2, '0');
                          final formattedDate =
                              '${dt.year % 100}년 ${dt.month}월 ${dt.day}일 ${isAm ? '오전' : '오후'} $hour:$minute';
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 0, right: 12, top: 20, bottom: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 20, right: 20),
                                      child: Text(
                                        '▶',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item['title'] ?? '제목 없음',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('·', style: TextStyle(color: Colors.white38, fontSize: 13)),
                                              const SizedBox(width: 8),
                                              Expanded(child: Container()),
                                              Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: Text(
                                                  formatDuration(item['duration_ms']),
                                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 220,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RealtimeRecordPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC435),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'resources/icons/icon_mic.svg',
                            width: 28,
                            height: 28,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '실시간 통역 시작',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF242424),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF242424),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'resources/icons/icon_audio_upload.svg',
                          width: 28,
                          height: 28,
                          color: Colors.white,
                        ),
                      ),
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
