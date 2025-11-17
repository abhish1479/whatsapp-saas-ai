import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_message_bubble.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AgentPreviewScreen extends ConsumerStatefulWidget {
  const AgentPreviewScreen({super.key});

  @override
  ConsumerState<AgentPreviewScreen> createState() => _AgentPreviewScreenState();
}

class _AgentPreviewScreenState extends ConsumerState<AgentPreviewScreen> {
  String _selectedChannel = "voice";
  bool _isListening = true;
  int _callDuration = 8;
  bool _isMuted = false;
  Timer? _callTimer;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    if (_isListening && _selectedChannel == "voice") {
      _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _callDuration++);
      });
    }
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectChannel(String channelId) {
    setState(() {
      _selectedChannel = channelId;
      if (channelId == 'voice') {
        _isListening = true;
        _callDuration = 0;
        _startCallTimer();
      } else {
        _isListening = false;
        _stopCallTimer();
      }
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
        initialLabelIndex: _selectedChannel == 'voice' ? 0 : 1,
        cornerRadius: 8.0,
        activeBgColor: const [AppColors.primary],
        activeFgColor: AppColors.primaryForeground,
        inactiveBgColor: AppColors.muted,
        inactiveFgColor: AppColors.mutedForeground,
        totalSwitches: 2,
        labels: const ['Voice Agent', 'WhatsApp Agent'],
        icons: const [LucideIcons.volume2, LucideIcons.messageSquare],
        onToggle: (index) {
          _selectChannel(index == 0 ? 'voice' : 'whatsapp');
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
            id: 'voice',
            name: 'VOICE AGENT',
            description: 'Add voice Agent to your website',
            icon: LucideIcons.volume2,
          ),
          const SizedBox(height: 12),
          _buildChannelButton(
            id: 'whatsapp',
            name: 'WHATSAPP AGENT',
            description: 'Connect your business number',
            icon: LucideIcons.messageSquare,
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
          AppButton(
            text: 'Settings',
            icon: const Icon(LucideIcons.settings),
            style: AppButtonStyle.tertiary,
            onPressed: () => context.go('/dashboard/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    final bool isVoice = _selectedChannel == 'voice';
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      if (isVoice) {
        return _buildVoiceAgentVisual();
      } else {
        return _buildChatInterface();
      }
    }

    // MODIFIED: Web layout now conditionally shows voice or chat interface
    return Row(
      children: [
        // --- THIS IS THE FIX ---
        if (isVoice)
          Expanded(child: _buildVoiceInterface())
        else
          Expanded(child: _buildChatInterface()),
        // -----------------------

        if (isVoice)
          Container(
            width: 480,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.05)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(left: BorderSide(color: AppColors.border)),
            ),
            child: _buildVoiceAgentVisual(),
          )
        else
          Container(
            width: 480,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(left: BorderSide(color: AppColors.border)),
            ),
            child: _buildWhatsAppAgentVisual(),
          ),
      ],
    );
  }

  // ADDED: New widget for the voice-only interface (web)
  Widget _buildVoiceInterface() {
    return Container(
      color: AppColors.muted.withOpacity(0.3),
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.phone,
                    size: 64,
                    color: AppColors.mutedForeground,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Voice Agent Panel',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    'Press "Start" to begin',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildVoiceControls(), // The existing Start/Pause/Decline buttons
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    final chatState = ref.watch(agentPreviewChatProvider);
    // REMOVED: Unnecessary bool `isVoice` as this widget is now only for chat

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

          // MODIFIED: Simplified this logic. It will now only show text input.
          // The voice controls are handled by _buildVoiceInterface() on web
          // and _buildVoiceAgentVisual() on mobile.
          if (Responsive.isMobile(context) && _selectedChannel == 'voice')
            const SizedBox() // On mobile, voice controls are elsewhere
          else
            _buildTextInput(chatState), // Show text input for whatsapp
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

  Widget _buildVoiceControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppButton(
            text: 'Start',
            icon: const Icon(LucideIcons.play),
            style: AppButtonStyle.primary,
            onPressed: () {},
          ),
          AppButton(
            text: 'Pause',
            icon: const Icon(LucideIcons.pause),
            style: AppButtonStyle.secondary,
            onPressed: () {},
          ),
          AppButton(
            text: 'Decline',
            icon: const Icon(LucideIcons.phoneOff),
            style: AppButtonStyle.destructive,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAgentVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 400,
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
        if (_isListening) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Listening...',
                    style: TextStyle(
                        color: AppColors.mutedForeground, fontSize: 12)),
                const SizedBox(width: 8),
                Text(_formatTime(_callDuration),
                    style: const TextStyle(fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text('Ashley',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Customer Support Agent',
            style: TextStyle(color: AppColors.mutedForeground)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isMuted ? LucideIcons.micOff : LucideIcons.mic),
              iconSize: 24,
              color: _isMuted ? AppColors.warning : AppColors.foreground,
              style: IconButton.styleFrom(
                backgroundColor: _isMuted
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.muted,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => setState(() => _isMuted = !_isMuted),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(LucideIcons.phoneCall),
              iconSize: 28,
              color: AppColors.destructiveForeground,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.destructive,
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () => setState(() {
                _isListening = false;
                _stopCallTimer();
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhatsAppAgentVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 400,
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
        SizedBox(
          width: 250,
          child: Column(
            children: [
              AppButton(
                  text: 'Popular Destinations',
                  style: AppButtonStyle.tertiary,
                  onPressed: () {}),
              const SizedBox(height: 8),
              AppButton(
                  text: 'Flight Information',
                  style: AppButtonStyle.tertiary,
                  onPressed: () {}),
              const SizedBox(height: 8),
              AppButton(
                  text: 'Hotel Recommendations',
                  style: AppButtonStyle.tertiary,
                  onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}