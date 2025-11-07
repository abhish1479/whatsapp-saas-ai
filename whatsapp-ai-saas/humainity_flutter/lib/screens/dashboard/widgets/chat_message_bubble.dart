// FIX: Removed all provider logic. This file should define the WIDGET.
import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:intl/intl.dart';

// FIX: Added the missing ChatMessageBubble widget definition
class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? agentAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.agentAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? AppColors.primary : AppColors.card;
    final textColor = isUser ? AppColors.primaryForeground : AppColors.cardForeground;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          AppAvatar(
            imageUrl: agentAvatar,
            fallbackText: 'AI',
            radius: 16,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                    bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                  ),
                  border: isUser ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(timestamp),
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}