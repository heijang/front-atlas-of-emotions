import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'emotion_report_list.dart';
import 'realtime_emotional_translation.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'mypage.dart';

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
          color: Colors.amber[700],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.amber[800],
                ),
                child: const Text('메뉴', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('마이페이지', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
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
                    // 프로필 영역 (예시)
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => Text(
                            auth.isLoggedIn && auth.userName != null && auth.userName!.isNotEmpty
                                ? auth.userName! + ' 님'
                                : '미로그인',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
                  width: 320, // 원하는 너비로 조정
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
                        const SizedBox(width: 4),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/icon_home.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () => _onItemTapped(0),
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        IconButton(
                          icon: SvgPicture.asset('resources/icons/forum.svg', width: 42, height: 42, color: Colors.black),
                          onPressed: () => _onItemTapped(1),
                          splashRadius: 32,
                          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
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
                          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
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
                          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                          hoverColor: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    onPressed: () => _onItemTapped(4),
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