import 'package:flutter/material.dart';
import 'emotion_report_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmotionReportListPage extends StatefulWidget {
  const EmotionReportListPage({Key? key}) : super(key: key);

  @override
  State<EmotionReportListPage> createState() => _EmotionReportListPageState();
}

class _EmotionReportListPageState extends State<EmotionReportListPage> {
  List<Map<String, dynamic>>? reports;
  bool isLoading = true;
  String? error;

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
        print('API 결과: $jsonData');
        if (jsonData['success'] == true && jsonData['data'] is List) {
          setState(() {
            reports = List<Map<String, dynamic>>.from(jsonData['data']);
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
      appBar: AppBar(
        title: const Text(
          '감정 리포트 목록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'resources/icons/back.svg',
            width: 20,
            height: 20
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView.separated(
                  itemCount: reports?.length ?? 0,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final report = reports![idx];
                    final title = report['topic'] ?? '제목 없음';
                    String createdAt = '';
                    if (report['created_at'] != null) {
                      try {
                        final dt = DateTime.parse(report['created_at']);
                        createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
                      } catch (e) {
                        createdAt = report['created_at'].toString();
                      }
                    }
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(createdAt),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EmotionReportPage(
                              userConversationMasterUid: report['uid'].toString(),
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