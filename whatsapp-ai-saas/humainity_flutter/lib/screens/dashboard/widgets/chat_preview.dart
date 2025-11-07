import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/screens/dashboard/widgets/chat_message_bubble.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

// This is a STATIC preview, as seen in AIAgent.tsx
class ChatPreview extends StatelessWidget {
  final String agentName;
  final String agentImagePath;
  final String greetingMessage;

  const ChatPreview({
    this.agentName = "OmniBot",
    this.agentImagePath = 'assets/images/agent-sarah.jpg', // Default
    this.greetingMessage = "Hi! I'm your virtual assistant. How can I assist you today?",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: agentImagePath,
                  fallbackText: agentName,
                  radius: 16,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.primaryForeground)),
                    const Text("Online",
                        style: TextStyle(
                            color: AppColors.primaryForeground, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Messages
          Container(
            height: 400,
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ChatMessageBubble(
                  message: greetingMessage,
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
                const SizedBox(height: 16),
                ChatMessageBubble(
                  message: "I need help with my order",
                  isUser: true,
                  timestamp: DateTime.now(),
                ),
                const SizedBox(height: 16),
                ChatMessageBubble(
                  message: "I'd be happy to help you with your order! Could you please share your order number?",
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              ],
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: AppColors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}