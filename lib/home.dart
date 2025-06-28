import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'emotion_report_list.dart';
import 'realtime_emotional_translation.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'mypage.dart';
import 'main.dart';
import 'realtime_record.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBanner = true;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset('resources/icons/dehaze.svg', width: 28, height: 28),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: SvgPicture.asset('resources/icons/symbol_logo.svg', height: 32),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset('resources/icons/search.svg', width: 28, height: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset('resources/icons/thread_unread.svg', width: 28, height: 28),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section with close button
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.black,
                child: Stack(
                  children: [
                    // Profile info with real user data
                    Positioned(
                      left: 24,
                      top: 36,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (!(auth.isLoggedIn && auth.userName != null && auth.userName!.isNotEmpty)) {
                            // 미로그인: 아이콘과 텍스트 세로 가운데 정렬, 텍스트 클릭 시 mypage.dart 이동
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[800],
                                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const MyPage()),
                                      );
                                    },
                                    child: Container(
                                      height: 56,
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        '미로그인',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.underline),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // 로그인: 이름, id 세로 정렬, 이름 클릭 시 mypage.dart 이동
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[800],
                                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  height: 56,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(builder: (_) => const MyPage()),
                                            );
                                          },
                                          child: Text(
                                            auth.userName!,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        auth.userId ?? '-',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    // Close button (top right)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'resources/icons/close_sidebar.svg',
                          width: 17,
                          height: 17,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 22,
                      ),
                    ),
                  ],
                ),
              ),
              // Calendar and below: white background
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'resources/images/calendar_sample.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
              // Everything below calendar is white
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Color(0xFFF0F0F0),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MyPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(width: 2),
                                  SvgPicture.asset(
                                    'resources/icons/mic_upload.svg',
                                    width: 16,
                                    height: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 12),
                                  Text('내목소리 업로드', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Color(0xFFF0F0F0),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(width: 2),
                                SvgPicture.asset(
                                  'resources/icons/mic_realtime.svg',
                                  width: 16,
                                  height: 16,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 12),
                                Text('실시간 번역 명령어', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Color(0xFFF0F0F0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context).pop();
                              if (auth.isLoggedIn) {
                                await Provider.of<AuthProvider>(context, listen: false).logout();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const IntroScreen()),
                                  (route) => false,
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const MyPage()),
                                );
                              }
                            },
                            child: Text(
                              auth.isLoggedIn ? '로그아웃' : '로그인',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_showBanner)
                Container(
                  color: Colors.red[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '목소리 학습을 통해 당신만의\n감정 표현 방식에 더 잘 맞춰드릴게요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _showBanner = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), // 하단에 여유 padding
                  children: [
                    const Center(
                      child: Text(
                        '수정 중',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 감정 기록 카드 여러 개
                    for (int i = 1; i <= 8; i++) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('감정 기록 $i', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('오늘의 감정: 행복, 슬픔, 분노 등'),
                              const SizedBox(height: 4),
                              Text('메모: 오늘은 특별한 일이 있었어요.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // 통계 보기 카드 여러 개
                    for (int i = 1; i <= 4; i++) ...[
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.bar_chart, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text('통계 보기 $i', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // 기타 더미 카드
                    for (int i = 1; i <= 6; i++) ...[
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('기타 내용 카드 $i'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // 플로팅 네비게이션 바 + 녹음 버튼
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                  height: 80,
                  width: 280, // 원하는 너비로 조정
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(200, 200, 200, 0.5),
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 2),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/icon_home.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () => _onItemTapped(0),
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 52, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/forum.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () => _onItemTapped(1),
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 52, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/assignment.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EmotionReportListPage()),
                            );
                          },
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 52, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/icon_test.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RecorderPageRealtime()),
                            );
                          },
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 52, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset('resources/icons/settings_voice.svg', width: 40, height: 40),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RealtimeRecordPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 