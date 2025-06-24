import 'package:flutter/material.dart';
import 'emotion_report_page.dart';

class EmotionReportListPage extends StatelessWidget {
  const EmotionReportListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터 20개 (user_conversation_master_uid 포함)
    final List<Map<String, String>> reports = List.generate(20, (i) => {
      'date': '2024-06-${(i+1).toString().padLeft(2, '0')}',
      'time': '${10 + (i % 10)}:00',
      'title': '감정 리포트 ${i+1}',
      'duration': '${3 + (i % 10)}분',
      'user_conversation_master_uid': 'uid_${1000 + i}',
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('감정 리포트 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        itemCount: reports.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, idx) {
          final report = reports[idx];
          return ListTile(
            title: Text(report['title']!),
            subtitle: Text('${report['date']} ${report['time']}'),
            trailing: Text(report['duration']!),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmotionReportPage(
                    userConversationMasterUid: report['user_conversation_master_uid']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 