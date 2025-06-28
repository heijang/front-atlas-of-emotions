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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.dart';
import 'main.dart';

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
  bool _showSignup = false;
  WebSocketChannel? _wsChannel;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _setDefaultMp3File();
  }

  Future<void> _setDefaultMp3File() async {
    js.context['onMp3FilePickedForMypage'] = (file) async {
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
    js.context.callMethod('setDefaultMp3FileForMypage');
  }

  Future<void> _pickFile() async {
    js.context['onMp3FilePickedForMypage'] = (file) async {
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
    js.context.callMethod('pickMp3FileForMypage');
  }

  Future<void> _startMp3StreamingForMypage() async {
    if (_isStreaming) return;
    setState(() { _isSending = true; });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _wsChannel = WebSocketChannel.connect(Uri.parse('${getWsBaseUrl()}/ws/users'));
    _wsChannel!.sink.add(jsonEncode({
      'event': 'register_voice',
      'user_info': {
        'user_id': auth.userId ?? '',
      }
    }));
    bool streamEnded = false;
    js.context['onPCMChunk'] = (dynamic jsUint8Array) {
      try {
        final length = js_util.getProperty(jsUint8Array, 'length') as int;
        final list = List<int>.generate(
          length,
          (i) => js_util.getProperty(jsUint8Array, i) as int,
        );
        final uint8List = Uint8List.fromList(list);
        if (_wsChannel != null && !streamEnded) {
          _wsChannel!.sink.add(uint8List);
        }
      } catch (e) {
        print('Error converting JS Uint8Array to Uint8List: $e');
      }
    };
    js.context['onMp3StreamEnd'] = () {
      if (!streamEnded) {
        streamEnded = true;
        setState(() { _isSending = false; _isStreaming = false; });
        if (_wsChannel != null) {
          _wsChannel!.sink.close();
          _wsChannel = null;
        }
      }
    };
    js.context.callMethod('startMp3StreamingForMypage');
    setState(() { _isStreaming = true; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return const LoginPage();
    }
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
                        onPressed: _isSending || _selectedFileName == null || _selectedFileName == '기본 파일 로드 실패' ? null : _startMp3StreamingForMypage,
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

  String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }

  String getWsBaseUrl() {
    return dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
  }
} 