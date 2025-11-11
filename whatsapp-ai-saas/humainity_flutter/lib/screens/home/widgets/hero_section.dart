import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    final TextAlign textAlign = isMobile ? TextAlign.center : TextAlign.left;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      // FIX: Using WebContainer (defined in responsive.dart)
      child: WebContainer(
        child: Column(
          children: [
            Wrap(
              alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
              runSpacing: 20,
              spacing: 30,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondary),
                        ),
                        child: const Text(
                          'AI-Powered Customer Engagement',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Scale Your Customer Interactions with Smart AI Agents',
                        style: TextStyle(
                          fontSize: isMobile ? 36 : 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        // FIX: Removed const keyword since 'textAlign' is non-constant
                        textAlign: textAlign,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deploy autonomous WhatsApp and Voice agents that are trained on your business knowledge to handle support, sales, and outreach 24/7.',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.mutedForeground,
                        ),
                        textAlign: textAlign,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: isMobile
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          AppButton(
                            text: 'Start Free Trial',
                            onPressed: () => context.go('/auth'),
                          ),
                          const SizedBox(width: 16),
                          AppButton(
                            text: 'Book a Demo',
                            // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                            style: AppButtonStyle.tertiary,
                            icon: const Icon(LucideIcons.calendar),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: isMobile
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.check,
                              size: 18, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('No Credit Card Required',
                              style:
                                  TextStyle(color: AppColors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/dashboard-preview.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 350,
                          color: AppColors.border,
                          child: const Center(child: Text("Image Placeholder")),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
