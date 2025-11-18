import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Placeholder utility class and color definition for standalone compilation
class AppColors {
  static const Color primary = Color(0xFF0BA5EC);
  static const Color muted = Color(0xFFF1F5F9); // slate-100
  static const Color mutedForeground = Color(0xFF64748b); // slate-600
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 768;
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  static const features = [
    {
      "icon": LucideIcons.messageSquare,
      "title": "Connect Channels in Minutes",
      "description":
          "Seamlessly integrate WhatsApp Business API and Voice channels. Get started with zero technical hassle.",
    },
    {
      "icon": LucideIcons.brain,
      "title": "Train Your AI on Business Knowledge",
      "description":
          "Upload PDFs, docs, FAQs, and media. Our RAG-based system learns your business inside out.",
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
    const titleBlack = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.1,
    );

    const titleBlue = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: Color(0xFF0BA5EC),
      height: 1.1,
    );

    return Container(
      color: AppColors.muted.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            children: [
              /// Title
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(text: "Everything You Need to ", style: titleBlack),
                    TextSpan(text: "Scale Communication", style: titleBlue),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Powerful features designed for SMBs who want to automate and grow',
                style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              /// GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile(context) ? 1 : 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  // Removed childAspectRatio and used mainAxisExtent for fixed, unclipped height
                  mainAxisExtent: 320, 
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _HoverFeatureCard(feature: features[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverFeatureCard extends StatefulWidget {
  final Map<String, dynamic> feature;

  const _HoverFeatureCard({required this.feature});

  @override
  State<_HoverFeatureCard> createState() => _HoverFeatureCardState();
}

class _HoverFeatureCardState extends State<_HoverFeatureCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: hovering
            ? (Matrix4.identity()..translate(0, -4)..scale(1.02))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hovering ? AppColors.primary : const Color(0xFFE5EAF0),
            width: hovering ? 1.8 : 1.4,
          ),
          boxShadow: hovering
              ? [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON BOX
            Container(
              width: 46,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.feature["icon"] as IconData,
                color: AppColors.primary,
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              widget.feature["title"] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 14),
            Text(
              widget.feature["description"] as String,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                height: 1.45,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}