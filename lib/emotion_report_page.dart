import 'package:flutter/material.dart';

class EmotionReportPage extends StatelessWidget {
  const EmotionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Text('📄', style: TextStyle(fontSize: 18, color: Colors.blue)),
              label: const Text(
                '돌아가기',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(
        child: Text('감정 리포트 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
} 