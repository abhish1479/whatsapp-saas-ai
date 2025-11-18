import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A mock widget to display a live preview of the AI agent's branding
/// and appearance within a chat interface.
class ChatPreview extends StatelessWidget {
  final String agentName;
  final ImageProvider agentImage;
  final Color primaryColor;

  const ChatPreview({
    super.key,
    required this.agentName,
    required this.agentImage,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine a text color that contrasts with the primary color
    final double luminance = primaryColor.computeLuminance();
    final Color headerTextColor =
        luminance > 0.5 ? Colors.black87 : Colors.white;

    return Container(
      // Removed fixed height here, as the parent (AIAgentScreen) is now managing height via Expanded/SizedBox,
      // allowing the widget to correctly fill the space provided by the outer Expanded.
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header (Branding Preview)
          _buildHeader(headerTextColor),

          // 2. Mock Chat Messages
          Expanded(
            // FIX: Ensures the chat area takes up all remaining vertical space
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAgentMessage(context),
                  const SizedBox(height: 12),
                  _buildUserMessage(context),
                ],
              ),
            ),
          ),

          // 3. Input Mock
          _buildInputMock(context),
        ],
      ),
    );
  }

  Widget _buildHeader(Color headerTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: agentImage,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            onBackgroundImageError: (exception, stackTrace) =>
                print('Failed to load image chat preview: $exception'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              agentName,
              style: TextStyle(
                color: headerTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Icon(LucideIcons.x, size: 20, color: headerTextColor),
        ],
      ),
    );
  }

  Widget _buildAgentMessage(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundImage: agentImage,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          onBackgroundImageError: (exception, stackTrace) =>
              print('Failed to load image chat preview: $exception'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius:
                  BorderRadius.circular(12).copyWith(topLeft: Radius.zero),
            ),
            child: const Text(
              'Hello! How can I help you find the perfect AI solution for your business today?',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor
                  .withOpacity(0.8), // User message bubble uses the brand color
              borderRadius:
                  BorderRadius.circular(12).copyWith(topRight: Radius.zero),
            ),
            child: const Text(
              'I\'m looking for a tool to handle lead qualification via WhatsApp.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputMock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.input),
              ),
              child: const Text(
                'Type a message...',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(LucideIcons.send, color: primaryColor, size: 24),
        ],
      ),
    );
  }
}
