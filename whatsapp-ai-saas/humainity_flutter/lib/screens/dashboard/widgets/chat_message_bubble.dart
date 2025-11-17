import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // ADDED for rich text
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/responsive.dart'; // ADDED to open links

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
    final alignment =
    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? AppColors.primary : AppColors.card;
    final textColor =
    isUser ? AppColors.primaryForeground : AppColors.cardForeground;

    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isUser
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  border: isUser ? null : Border.all(color: AppColors.border),
                ),
                // MODIFIED: Replaced Text with MarkdownBody
                child: MarkdownBody(
                  data: message,
                  selectable: true,
                  styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: TextStyle(color: textColor, fontSize: 14),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      try {
                        launchUrl(Uri.parse(href));
                      } catch (e) {
                        print('Could not launch $href: $e');
                      }
                    }
                  },
                  // ADDED: imageBuilder to handle network images
                  imageBuilder: (uri, title, alt) {
                    // MODIFIED: Added constraints for responsive image size
                    final bool isMobile = Responsive.isMobile(context);
                    final double maxImageWidth = isMobile ? 250.0 : 350.0;
                    const double maxImageHeight = 400.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      // MODIFIED: Wrapped image in ConstrainedBox
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxImageWidth,
                          maxHeight: maxImageHeight,
                        ),
                        child: Image.network(
                          uri.toString(),
                          fit: BoxFit.contain, // Keeps aspect ratio
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                      null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              '[Failed to load image: $alt]\n(This can be a network or web CORS issue)',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(timestamp),
                style: const TextStyle(
                    color: AppColors.mutedForeground, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}