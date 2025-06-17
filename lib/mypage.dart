import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:html' as html;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isSending = false;
  final String _userId = '1';
  final String _userName = '홍길동';

  @override
  void initState() {
    super.initState();
    _setDefaultMp3File();
  }

  Future<void> _setDefaultMp3File() async {
    js.context['onMp3FilePicked'] = (file) async {
      if (file == null) {
        setState(() {
          _selectedFileBytes = null;
          _selectedFileName = '기본 파일 로드 실패';
        });
        return;
      }
      final name = js_util.getProperty(file, 'name');
      final promise = js_util.callMethod(file, 'arrayBuffer', []);
      final buffer = await js_util.promiseToFuture(promise);
      final bytes = Uint8List.view((buffer as ByteBuffer));
      setState(() {
        _selectedFileBytes = bytes;
        _selectedFileName = name;
      });
    };
    js.context.callMethod('eval', [
      '''(async function() {
        const url = "resources/sample1_man_voice.mp3";
        try {
          const res = await fetch(url);
          const blob = await res.blob();
          const file = new File([blob], 'sample1_man_voice.mp3', { type: 'audio/mp3' });
          window._selectedMp3File = file;
          if (window.onMp3FilePicked) window.onMp3FilePicked(file);
        } catch (e) {
          alert('기본 mp3 파일을 불러올 수 없습니다. resources 폴더에 sample1_man_voice.mp3가 있어야 합니다.');
        }
      })()'''
    ]);
  }

  Future<void> _pickFile() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.mp3,audio/*';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedFileBytes = reader.result as Uint8List;
            _selectedFileName = file.name;
          });
        });
      }
    });
  }

  Future<void> _sendFile() async {
    if (_selectedFileBytes == null) return;
    setState(() { _isSending = true; });
    final ws = WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws'));
    ws.sink.add(jsonEncode({
      'event': 'register_user',
      'user_info': {
        'user_id': _userId,
        'name': _userName,
      }
    }));
    await Future.delayed(const Duration(milliseconds: 200));
    ws.sink.add(_selectedFileBytes!);
    setState(() { _isSending = false; });
    ws.sink.close();
  }

  Future<void> _signup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final userId = _userIdController.text.trim();
    final userName = _userNameController.text.trim();
    try {
      // TODO: Replace with your backend API endpoint
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user_id": "$userId", "user_name": "$userName"}',
      );
      if (response.statusCode == 200) {
        // Parse response JSON
        final data = jsonDecode(response.body);
        final serverUserId = data['user_id'] ?? userId;
        final serverUserName = data['user_name'] ?? userName;
        // 성공 시 Provider로 로그인 처리
        await Provider.of<AuthProvider>(context, listen: false).login(serverUserId, serverUserName);
        // 회원가입 성공 모달 표시
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('회원가입 성공', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
            content: const Text('회원가입이 성공적으로 완료되었습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 닫기
                },
                child: const Text('확인', style: TextStyle(color: Color(0xFFFF6D00), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        // 이후 화면 전환(마이페이지로 자동 전환됨)
      } else {
        setState(() { _error = '회원가입 실패: ${response.body}'; });
      }
    } catch (e) {
      setState(() { _error = '네트워크 오류: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      // 회원가입 폼
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('회원가입', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(labelText: 'User ID'),
                        validator: (v) => v == null || v.isEmpty ? 'User ID를 입력하세요' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 280,
                      child: TextFormField(
                        controller: _userNameController,
                        decoration: const InputDecoration(labelText: 'User Name'),
                        validator: (v) => v == null || v.isEmpty ? 'User Name을 입력하세요' : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: 180,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _signup(context),
                        child: _isLoading ? const CircularProgressIndicator() : const Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6D00),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 기존 마이페이지 내용
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 340,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text('내 목소리 녹음', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: const Text('음성 파일 선택'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6D00),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSending || _selectedFileBytes == null ? null : _sendFile,
                          child: _isSending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('음성 파일 전송'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.audiotrack, size: 18, color: Color(0xFFFF6D00)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedFileName ?? '선택된 파일 없음',
                            style: const TextStyle(fontSize: 15, color: Color(0xFFFF6D00), fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }
  }
} 