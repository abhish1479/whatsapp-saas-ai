import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const features = [
    {
      "icon": LucideIcons.messageSquare,
      "title": "Connect Channels in Minutes",
      "description":
          "Seamlessly integrate WhatsApp Business API and Voice channels.",
    },
    {
      "icon": LucideIcons.brain,
      "title": "Train Your AI on Business Knowledge",
      "description":
          "Upload PDFs, docs, FAQs, and media. Our RAG-based system learns your business.",
    },
    {
      "icon": LucideIcons.zap,
      "title": "Automate Customer Journeys",
      "description":
          "Set up intelligent workflows, forms, and actions. Let AI handle routine conversations 24/7.",
    },
    {
      "icon": LucideIcons.barChart3,
      "title": "Track Everything from One Dashboard",
      "description":
          "Monitor conversions, appointments, payments, and campaign performance in real-time.",
    },
    {
      "icon": LucideIcons.users,
      "title": "Smart Campaign Management",
      "description":
          "Create targeted WhatsApp and Voice campaigns with intelligent retries and follow-ups.",
    },
    {
      "icon": LucideIcons.settings,
      "title": "Personalize Your AI Agent",
      "description":
          "Customize avatar, tone, voice, and conversation style to match your brand perfectly.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const Text(
              'Everything You Need to Scale',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Powerful features designed for SMBs who want to automate and grow',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile(context) ? 1 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(feature['icon'] as IconData,
                            color: AppColors.primaryForeground, size: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(feature['title'] as String,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // FIX: Wrap the description in Expanded to resolve the RenderFlex overflow in the grid cell
                      Expanded(
                        child: Text(
                          feature['description'] as String,
                          style:
                              const TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
