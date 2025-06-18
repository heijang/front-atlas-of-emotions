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
    _wsChannel = WebSocketChannel.connect(Uri.parse('${getWsBaseUrl()}/ws'));
    _wsChannel!.sink.add(jsonEncode({
      'event': 'register_user',
      'user_info': {
        'user_id': auth.userId ?? '',
      }
    }));
    bool streamEnded = false;
    bool audioEventSent = false;
    js.context['onPCMChunk'] = (dynamic jsUint8Array) {
      try {
        final length = js_util.getProperty(jsUint8Array, 'length') as int;
        final list = List<int>.generate(
          length,
          (i) => js_util.getProperty(jsUint8Array, i) as int,
        );
        final uint8List = Uint8List.fromList(list);
        if (_wsChannel != null && !streamEnded) {
          if (!audioEventSent) {
            print('[WebSocket] audio_data 이벤트 전송');
            _wsChannel!.sink.add(jsonEncode({
              "event": "audio_data",
              "user_info": {"user_id": auth.userId}
            }));
            audioEventSent = true;
          }
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

  Future<void> _login(BuildContext context) async {
    setState(() { _isLoading = true; _error = null; });
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() { _error = 'User ID를 입력하세요'; _isLoading = false; });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await Provider.of<AuthProvider>(context, listen: false)
              .login(data['user_id'], data['user_name'] ?? '');
        } else {
          setState(() { _error = '로그인 실패'; });
        }
      } else {
        setState(() { _error = '로그인 실패'; });
      }
    } catch (e) {
      setState(() { _error = '네트워크 오류: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _signup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    final userId = _userIdController.text.trim();
    final userName = _userNameController.text.trim();
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user_id": "$userId", "user_name": "$userName"}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverUserId = data['user_id'] ?? userId;
        final serverUserName = data['user_name'] ?? userName;
        await Provider.of<AuthProvider>(context, listen: false).login(serverUserId, serverUserName);
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
                  Navigator.of(context).pop();
                  setState(() { _showSignup = false; });
                },
                child: const Text('확인', style: TextStyle(color: Color(0xFFFF6D00), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        setState(() { _error = '회원가입 실패: ${response.body}'; });
      }
    } catch (e) {
      setState(() { _error = '네트워크 오류: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _switchToSignup() {
    setState(() {
      _showSignup = true;
      _error = null;
      _userIdController.clear();
      _userNameController.clear();
    });
  }

  void _switchToLogin() {
    setState(() {
      _showSignup = false;
      _error = null;
      _userIdController.clear();
      _userNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      if (!_showSignup) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Text('��', style: TextStyle(fontSize: 18, color: Color(0xFFFF6D00))),
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
                      const Text('로그인', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 280,
                        child: TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            hintText: '사용자 ID',
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'User ID를 입력하세요' : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6D00),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                textStyle: const TextStyle(fontSize: 15),
                              ),
                              child: _isLoading ? const CircularProgressIndicator() : const Text('로그인'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            height: 38,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _switchToSignup,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6D00),
                                side: const BorderSide(color: Color(0xFFFF6D00), width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                textStyle: const TextStyle(fontSize: 15),
                              ),
                              child: const Text('회원가입'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Text('��', style: TextStyle(fontSize: 18, color: Color(0xFFFF6D00))),
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
                          decoration: const InputDecoration(
                            hintText: '사용자 ID',
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'User ID를 입력하세요' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 280,
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: const InputDecoration(
                            hintText: '사용자 이름',
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'User Name을 입력하세요' : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _signup(context),
                              child: _isLoading ? const CircularProgressIndicator() : const Text('회원가입'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6D00),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                textStyle: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            height: 38,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _switchToLogin,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6D00),
                                side: const BorderSide(color: Color(0xFFFF6D00), width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                textStyle: const TextStyle(fontSize: 15),
                              ),
                              child: const Text('로그인'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Text('��', style: TextStyle(fontSize: 18, color: Color(0xFFFF6D00))),
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
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6D00),
                      side: const BorderSide(color: Color(0xFFFF6D00), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      textStyle: const TextStyle(fontSize: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }
  }

  String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }

  String getWsBaseUrl() {
    return dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
  }
} 