import 'package:flutter/material.dart';

class RealtimeRecordPage extends StatelessWidget {
  const RealtimeRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 녹음'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('여기에 실시간 녹음 UI를 구현하세요.'),
      ),
    );
  }
} 