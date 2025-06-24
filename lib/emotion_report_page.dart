import 'package:flutter/material.dart';

class EmotionReportPage extends StatelessWidget {
  final String userConversationMasterUid;
  const EmotionReportPage({Key? key, required this.userConversationMasterUid}) : super(key: key);

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('감정 리포트 페이지', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text('UID: $userConversationMasterUid', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
} 