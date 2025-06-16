import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Text('🧑', style: TextStyle(fontSize: 18, color: Color(0xFFFF6D00))),
              label: const Text(
                '돌아가기',
                style: TextStyle(
                  color: Color(0xFFFF6D00),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFFF6D00),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(
        child: Text('사용자 등록 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
} 