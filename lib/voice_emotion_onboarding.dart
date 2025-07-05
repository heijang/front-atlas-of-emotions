import 'dart:async';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StepData {
  final String id;
  final String title;
  final String subtitle;
  final String? text;
  final String buttonText;
  final String? nextText;
  final String? note;
  final Color bgColor;
  final Gradient? bgGradient;
  final bool isComplete;

  StepData({
    required this.id,
    required this.title,
    required this.subtitle,
    this.text,
    required this.buttonText,
    this.nextText,
    this.note,
    required this.bgColor,
    this.bgGradient,
    this.isComplete = false,
  });
}

class VoiceEmotionOnboarding extends StatefulWidget {
  const VoiceEmotionOnboarding({Key? key}) : super(key: key);

  @override
  State<VoiceEmotionOnboarding> createState() => _VoiceEmotionOnboardingState();
}

class _VoiceEmotionOnboardingState extends State<VoiceEmotionOnboarding>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isRecording = false;
  int _recordingProgress = 0;
  Timer? _recordingTimer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  WebSocketChannel? _wsChannel;

  String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }

  String getWsBaseUrl() {
    return dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000';
  }

  final List<StepData> _steps = [
    StepData(
      id: 'intro',
      title: '감정 분석의 정확도를 높여보세요.',
      subtitle: '사람마다 감정을 표현하는 말투와 억양은 다릅니다.\n목소리 학습을 통해 당신만의 감정 표현 방식에\n더 정밀하게 맞춰드릴게요.',
      buttonText: '시작하기',
      note: '녹음된 음성은 감정 분석 학습 이외의\n용도로는 사용되지 않아요.',
      bgColor: Colors.orange[400]!,
      bgGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
      ),
    ),
    StepData(
      id: 'step1',
      title: '목소리 업로드 시작',
      subtitle: '아래 문장을 따라 읽어주세요.',
      text: '그래도 괜찮아.\n금방 나아질 거야.',
      buttonText: '건너뛰기',
      nextText: '다음',
      bgColor: Colors.yellow[400]!,
      bgGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFFFED4E)],
      ),
    ),
    StepData(
      id: 'step2',
      title: '목소리 업로드 시작',
      subtitle: '아래 문장을 따라 읽어주세요.',
      text: '그래도 괜찮아.\n금방 나아질 거야.',
      buttonText: '건너뛰기',
      nextText: '다음',
      bgColor: Colors.yellow[500]!,
      bgGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFB347), Color(0xFFFFD700)],
      ),
    ),
    StepData(
      id: 'step3',
      title: '목소리 업로드 시작',
      subtitle: '아래 문장을 따라 읽어주세요.',
      text: '천천히,\n내가 할 수 있는 만큼만\n하면 돼.',
      buttonText: '건너뛰기',
      nextText: '다음',
      bgColor: Colors.teal[400]!,
      bgGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      ),
    ),
    StepData(
      id: 'step4',
      title: '목소리 업로드 시작',
      subtitle: '아래 문장을 따라 읽어주세요.',
      text: '그냥 내버려 뒀으면 좋겠어',
      buttonText: '건너뛰기',
      nextText: '다음',
      bgColor: Colors.purple[400]!,
      bgGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
      ),
    ),
    StepData(
      id: 'complete',
      title: '목소리 업로드 완료',
      subtitle: '실시간 감정 분석을 시작해보세요.',
      buttonText: '실시간 분석 시작',
      bgColor: Colors.grey[100]!,
      isComplete: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _wsChannel?.sink.close();
    super.dispose();
  }

  StepData get _currentStepData => _steps[_currentStep];

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _recordingProgress = 0;
        _isRecording = false;
      });
      _pulseController.reset();
      _waveController.reset();
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _recordingProgress = 0;
        _isRecording = false;
      });
      _pulseController.reset();
      _waveController.reset();
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // 녹음 중지
      _stopRecording();
    } else {
      // 녹음 시작
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // WebSocket 연결 - 음성 학습용 엔드포인트
      _wsChannel = WebSocketChannel.connect(Uri.parse('${getWsBaseUrl()}/ws'));
      
      // WebSocket 메시지 수신 처리
      _wsChannel!.stream.listen((message) {
        print('음성 학습 서버 응답: $message');
        try {
          final data = jsonDecode(message);
          if (data['event'] == 'voice_training_complete') {
            // 음성 학습 완료 처리
            _stopRecording();
            setState(() {
              _recordingProgress = 100;
            });
          }
        } catch (e) {
          print('WebSocket 메시지 파싱 에러: $e');
        }
      }, onDone: () {
        print('WebSocket 연결 종료');
        _wsChannel = null;
      }, onError: (error) {
        print('WebSocket 에러: $error');
        _wsChannel = null;
      });

      // 음성 학습 시작 요청
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _wsChannel!.sink.add(jsonEncode({
        "event": "start_voice_training",
        "step": _currentStep,
        "text": _currentStepData.text ?? "",
        "user_info": auth.isLoggedIn ? {"user_id": auth.userId} : null
      }));
      
      // JS interop 콜백 설정
      js.context['onPCMChunk'] = (dynamic jsUint8Array) {
        try {
          final length = js_util.getProperty(jsUint8Array, 'length') as int;
          final list = List<int>.generate(
            length,
            (i) => js_util.getProperty(jsUint8Array, i) as int,
          );
          final uint8List = Uint8List.fromList(list);
          // WebSocket으로 음성 데이터 전송
          if (_wsChannel != null) {
            _wsChannel!.sink.add(uint8List);
          }
        } catch (e) {
          print('Error converting JS Uint8Array to Uint8List: $e');
        }
      };

      // 마이크 녹음 시작
      js.context.callMethod('startPCMStream');
      
      setState(() {
        _isRecording = true;
        _recordingProgress = 0;
      });

      _pulseController.repeat();
      _waveController.repeat();

      // 시뮬레이션: 3초 후 녹음 완료
      _recordingTimer = Timer(const Duration(seconds: 3), () {
        _stopRecording();
        setState(() {
          _recordingProgress = 100;
        });
      });
    } catch (e) {
      print('녹음 시작 실패: $e');
      _stopRecording();
    }
  }

  void _stopRecording() {
    js.context.callMethod('stopPCMStream');
    _recordingTimer?.cancel();
    _pulseController.stop();
    _waveController.stop();
    
    // WebSocket으로 녹음 종료 알림
    if (_wsChannel != null) {
      _wsChannel!.sink.add(jsonEncode({
        "event": "end_voice_training",
        "step": _currentStep,
      }));
    }
    
    setState(() {
      _isRecording = false;
    });
  }

  Widget _buildProgressBar() {
    if (_currentStep == 0 || _currentStep == _steps.length - 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < _currentStep ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecordingSection() {
    if (_currentStep == 0 || _currentStep == _steps.length - 1) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 32),
        // 녹음 버튼
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red[500]
                      : _recordingProgress > 0
                          ? Colors.green[500]
                          : Colors.grey[800],
                  shape: BoxShape.circle,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20 * _pulseController.value,
                            spreadRadius: 10 * _pulseController.value,
                          )
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 진행 표시
        if (_isRecording)
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Container(
                    width: 4,
                    height: 10 + (20 * _waveController.value * (i % 2 == 0 ? 1 : 0.5)),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        if (_recordingProgress > 0 && !_isRecording)
          const Text(
            '녹음 완료!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _handleComplete() {
    // 실시간 분석 시작 - 메인 페이지로 이동
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 상단 AppBar (흰색 배경, 좌측 close.svg만)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset('resources/icons/close.svg', width: 20, height: 20, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (_currentStep == 0) ...[
                // 배경 이미지 + 안내 텍스트
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('resources/images/onboarding_bg1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(top: 48, right: 32, left: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '감정 분석의 정확도를 높여보세요',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '사람마다 감정을 표현하는 말투와 억양은 다릅니다.\n목소리 학습을 통해 당신만의 감정 표현 방식에\n더 정밀하게 맞춰드릴게요.',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '시작하기',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (_currentStepData.note != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _currentStepData.note!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ] else ... [
                // 기존 온보딩 스텝 UI (step1~)
                // 진행 바
                _buildProgressBar(),
                // 메인 콘텐츠
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 배경 이미지/색상 영역
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _currentStepData.bgGradient,
                            color: _currentStepData.bgGradient == null
                                ? _currentStepData.bgColor
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: _currentStepData.isComplete
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '목소리 업로드 완료',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '감정 분석 정확도를 높이기 위해\n목소리를 학습했어요',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                : _currentStepData.text != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          _currentStepData.text!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                          ),
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 제목과 설명
                        Text(
                          _currentStepData.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentStepData.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        // 녹음 섹션
                        _buildRecordingSection(),
                        const Spacer(),
                        // 하단 버튼들
                        Column(
                          children: [
                            if (_currentStepData.nextText != null)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_currentStep > 0 && _recordingProgress == 0)
                                      ? null
                                      : _handleNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_currentStep > 0 && _recordingProgress == 0)
                                        ? Colors.grey[200]
                                        : Colors.black,
                                    foregroundColor: (_currentStep > 0 && _recordingProgress == 0)
                                        ? Colors.grey[400]
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _currentStepData.nextText!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            if (_currentStepData.nextText != null)
                              const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _currentStepData.isComplete
                                    ? _handleComplete
                                    : _currentStep == 0
                                        ? _handleNext
                                        : _handleNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentStepData.isComplete
                                      ? Colors.yellow[400]
                                      : _currentStep == 0
                                          ? Colors.black
                                          : Colors.grey[100],
                                  foregroundColor: _currentStepData.isComplete
                                      ? Colors.black
                                      : _currentStep == 0
                                          ? Colors.white
                                          : Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _currentStepData.buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: VoiceEmotionOnboarding(),
    debugShowCheckedModeBanner: false,
  ));
} 