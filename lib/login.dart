import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showSignup = false;

  Future<void> _login(BuildContext context) async {
    setState(() { _isLoading = true; _error = null; });
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() { _error = '사용자 ID를 입력하세요'; _isLoading = false; });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"user_id": "$userId"}',
      );
      if (response.statusCode == 200) {
        final data = http.Response('', 200).body.isNotEmpty ? http.Response('', 200).body : response.body;
        final jsonData = data is String ? data : response.body;
        final parsed = jsonData is String ? jsonDecode(jsonData) : jsonData;
        if (parsed['success'] == true) {
          await Provider.of<AuthProvider>(context, listen: false)
              .login(parsed['user_id'], parsed['user_name'] ?? '');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
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
        Uri.parse('${getApiBaseUrl()}/api/v1/users'),
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
      _formKey.currentState?.reset();
    });
  }

  void _switchToLogin() {
    setState(() {
      _showSignup = false;
      _error = null;
      _userIdController.clear();
      _userNameController.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSignup) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              '로그인',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.1,
              ),
            ),
            leading: IconButton(
              icon: SvgPicture.asset(
                'resources/icons/back.svg',
                width: 20,
                height: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 24,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('로그인', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 260,
                      child: TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          hintText: '사용자 ID',
                          filled: true,
                          fillColor: Color(0xFFFFF3E0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        // validator: (v) => v == null || v.isEmpty ? '사용자 ID를 입력하세요' : null,
                      ),
                    ),
                    if (_error == '사용자 ID를 입력하세요')
                      Container(
                        width: 260,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    const SizedBox(height: 24),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              '회원가입',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.1,
              ),
            ),
            leading: IconButton(
              icon: SvgPicture.asset(
                'resources/icons/back.svg',
                width: 20,
                height: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 24,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        validator: (v) => v == null || v.isEmpty ? '사용자 ID를 입력하세요' : null,
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
                        validator: (v) => v == null || v.isEmpty ? '사용자 이름을 입력하세요' : null,
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
  }

  String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }
} 