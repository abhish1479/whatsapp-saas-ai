import 'dart:async';
import 'dart:math'; // ADDED: For random animation values
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_message_bubble.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';
// ADDED: Import for real speech to text (You must add this package)
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AgentPreviewScreen extends ConsumerStatefulWidget {
  const AgentPreviewScreen({super.key});

  @override
  ConsumerState<AgentPreviewScreen> createState() => _AgentPreviewScreenState();
}

class _AgentPreviewScreenState extends ConsumerState<AgentPreviewScreen>
    with TickerProviderStateMixin {
  String _selectedChannel = "voice";
  bool _isListening = false;
  bool _isPaused = false;
  int _callDuration = 0;
  bool _isMuted = false;
  Timer? _callTimer;

  // Animation Controllers
  late AnimationController _micController;
  late AnimationController _rippleController;

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _lastWords = '';

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();

    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 1.0,
      upperBound: 1.2,
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      setState(() {});
    } catch (e) {
      print("Speech initialization failed: $e");
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
  }

  void _startListening() async {
    if (_speechAvailable && !_isPaused) {
      _speech.listen(
        onResult: (val) => setState(() {
          _lastWords = val.recognizedWords;
          if (val.finalResult) {
            ref.read(agentPreviewChatProvider.notifier).sendMessage(_lastWords);
          }
        }),
      );
    }

    setState(() {
      _isListening = true;
      _isPaused = false;
      _startCallTimer();
      _micController.repeat(reverse: true);
      _rippleController.repeat();
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isPaused = false;
      _callDuration = 0;
      _stopCallTimer();
      _micController.stop();
      _micController.reset();
      _rippleController.stop();
      _rippleController.reset();
    });
  }

  void _pauseListening() {
    if (_isPaused) {
      _startListening();
    } else {
      _speech.stop();
      _stopCallTimer();
      _micController.stop();
      _rippleController.stop();
      setState(() => _isPaused = true);
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _micController.dispose();
    _rippleController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _selectChannel(String channelId) {
    setState(() {
      _selectedChannel = channelId;
      _stopListening();
    });
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(agentPreviewChatProvider.notifier).sendMessage(text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        ref.read(agentPreviewChatProvider.notifier).clearChat();
      }
    });

    if (Responsive.isMobile(context)) {
      return _buildMobileLayout();
    }
    return _buildWebLayout();
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        _buildChannelsSidebar(),
        Expanded(
          child: Column(
            children: [
              _buildPreviewHeader(),
              Expanded(child: _buildPreviewContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildPreviewHeader(),
        _buildMobileChannelSelector(),
        Expanded(child: _buildPreviewContent()),
      ],
    );
  }

  Widget _buildMobileChannelSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ToggleSwitch(
        minWidth: double.infinity,
        initialLabelIndex: _selectedChannel == 'whatsapp' ? 0 : 1,
        cornerRadius: 8.0,
        activeBgColor: const [AppColors.primary],
        activeFgColor: AppColors.primaryForeground,
        inactiveBgColor: AppColors.muted,
        inactiveFgColor: AppColors.mutedForeground,
        totalSwitches: 2,
        labels: const ['WhatsApp Agent', 'Voice Agent'],
        icons: const [LucideIcons.messageSquare, LucideIcons.volume2],
        onToggle: (index) {
          _selectChannel(index == 0 ? 'whatsapp' : 'voice');
        },
      ),
    );
  }

  Widget _buildChannelsSidebar() {
    return Container(
      width: 320,
      color: AppColors.card,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildChannelButton(
            id: 'whatsapp',
            name: 'WHATSAPP AGENT',
            description: 'Connect your business number',
            icon: LucideIcons.messageSquare,
          ),
          const SizedBox(height: 12),
          _buildChannelButton(
            id: 'voice',
            name: 'VOICE AGENT',
            description: 'Add voice Agent to your website',
            icon: LucideIcons.volume2,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelButton({
    required String id,
    required String name,
    required String description,
    required IconData icon,
  }) {
    bool isSelected = _selectedChannel == id;
    return InkWell(
      onTap: () => _selectChannel(id),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.muted.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.foreground),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: const TextStyle(
                          color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader() {
    final bool isVoice = _selectedChannel == 'voice';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppBadge(
                text: isVoice ? 'VOICE AGENT' : 'WHATSAPP AGENT',
                color: isVoice
                    ? AppColors.warning.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
                textColor: isVoice ? AppColors.warning : AppColors.success,
                icon: Icon(
                    isVoice ? LucideIcons.volume2 : LucideIcons.messageSquare,
                    size: 12,
                    color: isVoice ? AppColors.warning : AppColors.success),
              ),
              const SizedBox(width: 16),
              if (!Responsive.isMobile(context))
                Text(
                  isVoice
                      ? 'Your Agent is now ready for direct voice calls'
                      : 'Connect your business number',
                  style: const TextStyle(
                      color: AppColors.mutedForeground, fontSize: 14),
                ),
            ],
          ),
          // AppButton(
          //   text: 'Settings',
          //   icon: const Icon(LucideIcons.settings),
          //   style: AppButtonStyle.tertiary,
          //   onPressed: () => context.go('/dashboard/settings'),
          // ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    final bool isVoice = _selectedChannel == 'voice';
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      if (isVoice) {
        return Center(child: _buildVoiceAgentVisual());
      } else {
        return _buildChatInterface();
      }
    }

    if (isVoice) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          width: double.infinity,
          child: _buildVoiceAgentVisual(),
        ),
      );
    } else {
      return _buildChatInterface();
    }
  }

  Widget _buildChatInterface() {
    final chatState = ref.watch(agentPreviewChatProvider);

    ref.listen(agentPreviewChatProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Container(
      color: AppColors.muted.withOpacity(0.3),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ChatMessageBubble(
                    message: msg.text,
                    isUser: msg.isUser,
                    timestamp: msg.timestamp,
                    agentAvatar: 'assets/images/agent-sarah.jpg',
                  ),
                );
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(children: [
                Text('Agent is typing...',
                    style: TextStyle(color: AppColors.mutedForeground))
              ]),
            ),
          _buildTextInput(chatState),
        ],
      ),
    );
  }

  Widget _buildTextInput(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              labelText: 'Your message',
              controller: _messageController,
              hintText: 'I would like to learn more...',
              onChanged: (val) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Send',
            icon: const Icon(LucideIcons.send),
            onPressed:
            _messageController.text.trim().isEmpty || chatState.isLoading
                ? null
                : _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMicAnimation() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return CustomPaint(
          painter: RipplePainter(
            animationValue: _rippleController.value,
            color: AppColors.primary,
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Center(
              child: Icon(
                _isPaused ? LucideIcons.pause : LucideIcons.mic,
                size: 32,
                color: _isPaused ? AppColors.mutedForeground : AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceAgentVisual() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageWidth = 300;
        double imageHeight = 400;

        if (constraints.maxWidth < 340) {
          imageWidth = constraints.maxWidth * 0.85;
          imageHeight = imageWidth * 1.33;
        }

        if (constraints.maxHeight < 700 && constraints.maxHeight > 100) {
          double availableForImage = constraints.maxHeight * 0.5;
          if(imageHeight > availableForImage) {
            imageHeight = availableForImage;
            imageWidth = imageHeight * 0.75;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/agent-sarah.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Ashley',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Customer Support Agent',
                  style: TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 24),

              if (!_isListening)
                GestureDetector(
                  onTap: _startListening,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.mic, color: Colors.white, size: 32),
                  ),
                )
              else
                Column(
                  children: [
                    // 1. Timer MOVED UP
                    Text(_formatTime(_callDuration),
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 18)),
                    const SizedBox(height: 24),

                    // 2. Real-time Transcription preview (Middle)
                    Text(
                      _isPaused ? "Paused" : "Listening...",
                      style: const TextStyle(color: AppColors.mutedForeground),
                    ),
                    if (_lastWords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_lastWords, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                      ),
                    const SizedBox(height: 24),

                    // 3. Row with End Button and Mic Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center, // Align vertically center
                      children: [
                        // End Call Button
                        GestureDetector(
                          onTap: _stopListening,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.phoneOff, color: Colors.white, size: 24),
                          ),
                        ),

                        const SizedBox(width: 32), // Spacing between buttons

                        // Google-style Mic Animation (Pause/Resume)
                        GestureDetector(
                          onTap: _pauseListening,
                          child: _buildGoogleMicAnimation(),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RipplePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < 3; i++) {
      final double opacity = (1.0 - (animationValue + i * 0.33) % 1.0).clamp(0.0, 1.0);
      final double radius = ((animationValue + i * 0.33) % 1.0) * maxRadius;

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}