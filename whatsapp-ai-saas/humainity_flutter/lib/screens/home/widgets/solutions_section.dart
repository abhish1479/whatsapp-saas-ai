import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_avatar.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SolutionsSection extends StatelessWidget {
  const SolutionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const Text(
              'Comprehensive Solutions',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'From support to sales, we\'ve got you covered with AI-powered automation',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildSolutionCard(
                    context,
                    icon: LucideIcons.headphones,
                    iconColor: AppColors.primary,
                    avatar: 'assets/images/agent-sarah.jpg',
                    title: 'Customer Support Automation',
                    description: 'Deliver instant, intelligent support that scales with your business.',
                    features: [
                      _buildFeatureItem(LucideIcons.messageSquare, 'Smart ticketing and instant FAQ handling', AppColors.primary),
                      _buildFeatureItem(LucideIcons.fileText, 'RAG-based responses from uploaded documents', AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSolutionCard(
                    context,
                    icon: LucideIcons.trendingUp,
                    iconColor: AppColors.success,
                    avatar: 'assets/images/agent-alex.jpg',
                    title: 'Sales Outreach & Campaigns',
                    description: 'Accelerate revenue with intelligent, personalized outreach at scale.',
                    features: [
                      _buildFeatureItem(LucideIcons.megaphone, 'WhatsApp and Voice campaigns with personalization', AppColors.success),
                      _buildFeatureItem(LucideIcons.barChart3, 'Real-time analytics: Open rate, Response rate', AppColors.success),
                    ],
                  ),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSolutionCard(
                      context,
                      icon: LucideIcons.headphones,
                      iconColor: AppColors.primary,
                      avatar: 'assets/images/agent-sarah.jpg',
                      title: 'Customer Support Automation',
                      description: 'Deliver instant, intelligent support that scales with your business.',
                      features: [
                        _buildFeatureItem(LucideIcons.messageSquare, 'Smart ticketing and instant FAQ handling', AppColors.primary),
                        _buildFeatureItem(LucideIcons.fileText, 'RAG-based responses from uploaded documents', AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildSolutionCard(
                      context,
                      icon: LucideIcons.trendingUp,
                      iconColor: AppColors.success,
                      avatar: 'assets/images/agent-alex.jpg',
                      title: 'Sales Outreach & Campaigns',
                      description: 'Accelerate revenue with intelligent, personalized outreach at scale.',
                      features: [
                        _buildFeatureItem(LucideIcons.megaphone, 'WhatsApp and Voice campaigns with personalization', AppColors.success),
                        _buildFeatureItem(LucideIcons.barChart3, 'Real-time analytics: Open rate, Response rate', AppColors.success),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String avatar,
        required String title,
        required String description,
        required List<Widget> features,
      }) {
    return AppCard(
      border: Border.all(color: AppColors.border, width: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              AppAvatar(imageUrl: avatar, fallbackText: title.substring(0, 2), radius: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          ...features,
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Explore Solutions',
              onPressed: () => context.go('/industries'),
              variant: AppButtonVariant.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }
}