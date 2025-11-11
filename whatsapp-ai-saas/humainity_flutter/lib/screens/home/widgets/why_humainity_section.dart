import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WhyHumainitySection extends StatelessWidget {
  const WhyHumainitySection({super.key});

  static const values = [
    {
      "icon": LucideIcons.bot,
      "title": "Conversational AI",
      "description":
          "Handles FAQs, service requests, and lead nurturing naturally with context-aware responses.",
      "color": AppColors.primary,
    },
    {
      "icon": LucideIcons.messageSquare,
      "title": "Voice + WhatsApp Integration",
      "description":
          "Unified dashboard for inbound and outbound interactions across all your communication channels.",
      "color": AppColors.success,
    },
    {
      "icon": LucideIcons.link2,
      "title": "Universal Integrator Layer",
      "description":
          "Connects with any CRM, ERP, or payment system through natural-language API configuration.",
      "color": AppColors.warning,
    },
    {
      "icon": LucideIcons.heart,
      "title": "Human + AI Synergy",
      "description":
          "Your agents focus on empathy while AI handles efficiency, creating the perfect balance.",
      "color": AppColors.destructive,
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
              'Why HumAInity.AI?',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Empower your business with Conversational AI that supports, sells, and connects — 24×7, across WhatsApp, Voice, and every channel your customers use.',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ResponsiveLayout(
              mobile: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: values.length,
                itemBuilder: (context, index) => _buildValueCard(values[index]),
              ),
              desktop: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: values.length,
                itemBuilder: (context, index) => _buildValueCard(values[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(Map<String, dynamic> value) {
    return AppCard(
      border: Border.all(color: AppColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (value['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(value['icon'] as IconData,
                color: value['color'] as Color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(value['title'] as String,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          // FIX: Wrap the description text in an Expanded widget.
          // This forces the column to only take the necessary space and ensures the text flexes correctly within the limited card height.
          Expanded(
            child: Text(
              value['description'] as String,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
