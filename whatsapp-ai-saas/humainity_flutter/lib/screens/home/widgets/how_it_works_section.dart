import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const steps = [
    {
      "icon": LucideIcons.messageSquare,
      "title": "Connect Channels",
      "description": "Link WhatsApp & Voice",
      "detail": "Integrate your communication channels in minutes.",
      "color": AppColors.primary,
      "step": "01",
    },
    {
      "icon": LucideIcons.upload,
      "title": "Train AI",
      "description": "Upload FAQs, Docs, or CRM Data",
      "detail": "Feed your business knowledge to create intelligent responses.",
      "color": AppColors.success,
      "step": "02",
    },
    {
      "icon": LucideIcons.shieldCheck,
      "title": "Set Actions & Guardrails",
      "description": "Configure automated responses & safety boundaries.",
      "detail": "Define triggers, responses, and escalation paths.",
      "color": AppColors.warning,
      "step": "03",
    },
    {
      "icon": LucideIcons.lineChart,
      "title": "Launch & Track",
      "description": "Monitor campaigns, leads, and outcomes",
      "detail": "View real-time analytics and insights in one dashboard.",
      "color": AppColors.destructive,
      "step": "04",
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
              'How It Works',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Get started in 4 simple steps and transform your customer engagement',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ResponsiveLayout(
              mobile: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) => _buildStepCard(steps[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
              ),
              desktop: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: steps.length,
                itemBuilder: (context, index) => _buildStepCard(steps[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step) {
    final color = step['color'] as Color;
    return AppCard(
      border: Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              step['step'] as String,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(step['icon'] as IconData, color: color, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                step['title'] as String,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                step['description'] as String,
                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                step['detail'] as String,
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}