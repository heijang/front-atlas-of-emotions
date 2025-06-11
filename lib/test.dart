import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          Ra0201(),
        ]),
      ),
    );
  }
}

class Ra0201 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 430,
          height: 932,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, 0.59),
              end: Alignment(1.00, 0.67),
              colors: [const Color(0xFFFEFEFF), const Color(0xFFF9FBF9)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 456,
                child: Container(
                  width: 414,
                  height: 340,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF232323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 24,
                        top: 168,
                        child: Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 112,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Container(
                              width: 14,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 11.53,
                                    top: 5,
                                    child: Container(
                                      transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.45),
                                      width: 2,
                                      height: 24,
                                      decoration: BoxDecoration(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '250607 노트',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 178),
                                fontSize: 24,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 80,
                        top: 169,
                        child: Container(
                          width: 310,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              SizedBox(
                                width: 310,
                                height: 40,
                                child: Text(
                                  '분위기를 감지하고 있어요.\n조금만 더 들려주세요.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 102),
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.32,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 310,
                                height: 20,
                                child: Text(
                                  '지금 감정이 막 떠오르고 있어요.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 49,
                child: Container(
                  width: 414,
                  height: 500,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, 0.69),
                      end: Alignment(0.50, 1.00),
                      colors: [const Color(0xFFFEFEFE), const Color(0xFFF6F9F8)],
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0xFF232323),
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: -24,
                        child: Container(
                          width: 430,
                          height: 524,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/430x524"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 428,
                        child: Text(
                          '2025-06-07  오후 02:18',
                          style: TextStyle(
                            color: const Color(0x99141414),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 130,
                        top: 228,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 6,
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 24,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 24,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 24,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 24,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 20,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 204),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 163,
                        top: 260,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF03030),
                                shape: OvalBorder(),
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              height: 36,
                              child: Text(
                                '00:05',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 448,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.64,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        '평온',
                                        style: TextStyle(
                                          color: const Color(0xFF009A59),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                      Text(
                                        '90%',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.64,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        '무기력',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                      Text(
                                        '05%',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.64,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        '슬픔',
                                        style: TextStyle(
                                          color: const Color(0xFF5A93FF),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                      Text(
                                        '01%',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.64,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        '분노',
                                        style: TextStyle(
                                          color: const Color(0xFFFF7979),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                      Text(
                                        '01%',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.64,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        '불안',
                                        style: TextStyle(
                                          color: const Color(0xFFFF8420),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.32,
                                        ),
                                      ),
                                      Text(
                                        '18%',
                                        style: TextStyle(
                                          color: const Color(0xFF191919),
                                          fontSize: 16,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.32,
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
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 1,
                child: Container(
                  width: 430,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 26),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 32.93,
                        top: 13.09,
                        child: Container(
                          width: 56.09,
                          height: 22.91,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 2.18,
                                child: SizedBox(
                                  width: 56.09,
                                  height: 19.64,
                                  child: Text(
                                    '9:41',
                                    style: TextStyle(
                                      color: const Color(0xFF141414),
                                      fontSize: 16.48,
                                      fontFamily: 'SF Pro Text',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.33,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 153,
                        top: 6,
                        child: Container(
                          width: 124,
                          height: 36,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF141414),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 900,
                child: Container(
                  width: 430,
                  height: 32,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 430,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 150.43,
                                top: 19.16,
                                child: Container(
                                  width: 128.39,
                                  height: 4.79,
                                  decoration: ShapeDecoration(
                                    color: const Color(0x66141414),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(95.81),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 104,
                top: 820,
                child: Container(
                  width: 310,
                  height: 80,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 310,
                          height: 80,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF232323),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 6,
                        top: 5,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 6,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 17,
                                    top: 17,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 22,
                                    top: 22,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 17,
                                    top: 17,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              padding: const EdgeInsets.all(10),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    color: Colors.white.withValues(alpha: 178),
                                  ),
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                          ),
                                        ),
                                        Positioned(
                                          left: 3,
                                          top: 3,
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                          ),
                                        ),
                                        Positioned(
                                          left: 3,
                                          top: 3,
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 820,
                child: Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0x66141414),
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 23,
                        top: 23,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 49,
                child: Container(
                  width: 430,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 26),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.white.withValues(alpha: 178),
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 48,
                        top: 18,
                        child: Text(
                          '실시간 감정',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF141414),
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.40,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 14,
                        child: Container(
                          width: 32,
                          height: 32,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 322,
                        top: 12,
                        child: Container(
                          width: 92,
                          height: 36,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF232323),
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 92,
                                  height: 36,
                                  decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                ),
                              ),
                              Positioned(
                                left: 18,
                                top: 8,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(color: const Color(0xFFD9D9D9)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '상대방',
                                      style: TextStyle(
                                        color: const Color(0xFF141414),
                                        fontSize: 14,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}