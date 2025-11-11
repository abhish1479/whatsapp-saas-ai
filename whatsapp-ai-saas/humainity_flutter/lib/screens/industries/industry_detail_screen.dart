import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/data/industries_data.dart';
import 'package:humainity_flutter/screens/home/widgets/footer.dart';
import 'package:humainity_flutter/screens/home/widgets/navigation.dart';
import 'package:humainity_flutter/widgets/ui/app_badge.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IndustryDetailScreen extends StatelessWidget {
  final String industryId;
  const IndustryDetailScreen({required this.industryId, super.key});

  @override
  Widget build(BuildContext context) {
    final industry = industries.firstWhere(
      (i) => i.id == industryId,
      orElse: () => industries.first, // Fallback, consider a 404
    );

    return Scaffold(
      appBar: const HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
              color: AppColors.primary,
              child: WebContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppButton(
                      text: 'Back to Industries',
                      icon: const Icon(LucideIcons.arrowLeft),
                      // FIX: Replaced variant: AppButtonVariant.ghost with style: AppButtonStyle.tertiary
                      style: AppButtonStyle.tertiary,
                      textColor: Colors.white,
                      onPressed: () => context.go('/industries'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(industry.icon,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(industry.name,
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 8),
                              Text(industry.tagline,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white.withOpacity(0.9))),
                              const SizedBox(height: 16),
                              Text(industry.description,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        // FIX: Replaced variant: AppButtonVariant.secondary with style: AppButtonStyle.secondary
                        AppButton(
                            text: 'Start Free Trial',
                            onPressed: () => context.go('/dashboard'),
                            style: AppButtonStyle.secondary),
                        const SizedBox(width: 16),
                        // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                        AppButton(
                            text: 'Book a Demo',
                            style: AppButtonStyle.tertiary,
                            onPressed: () => context.go('/auth'),
                            textColor: Colors.white,
                            borderColor: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Challenges
            Container(
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
              child: WebContainer(
                child: Column(
                  children: [
                    Text('Key Challenges in ${industry.name}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile(context) ? 1 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3,
                      ),
                      itemCount: industry.challenges.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withOpacity(0.05),
                            border: Border.all(
                                color: AppColors.destructive.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                              child: Text(
                            industry.challenges[index],
                            textAlign: TextAlign.center,
                          )),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Solutions
            Container(
              color: AppColors.muted.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
              child: WebContainer(
                child: Column(
                  children: [
                    const Text('How HumAInity.AI Helps',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    const Text(
                        'Automate with empathy using our three-pillar approach',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.mutedForeground),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    ResponsiveLayout(
                      mobile: Column(
                        children: [
                          _buildSolutionCard(
                              'WhatsApp Automation',
                              LucideIcons.messageSquare,
                              AppColors.success,
                              industry.solutions['whatsapp']!),
                          const SizedBox(height: 16),
                          _buildSolutionCard(
                              'Voice Automation',
                              LucideIcons.phone,
                              AppColors.primary,
                              industry.solutions['voice']!),
                          const SizedBox(height: 16),
                          _buildSolutionCard(
                              'Campaign Automation',
                              LucideIcons.megaphone,
                              AppColors.warning,
                              industry.solutions['campaigns']!),
                        ],
                      ),
                      desktop: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildSolutionCard(
                                  'WhatsApp Automation',
                                  LucideIcons.messageSquare,
                                  AppColors.success,
                                  industry.solutions['whatsapp']!)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildSolutionCard(
                                  'Voice Automation',
                                  LucideIcons.phone,
                                  AppColors.primary,
                                  industry.solutions['voice']!)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildSolutionCard(
                                  'Campaign Automation',
                                  LucideIcons.megaphone,
                                  AppColors.warning,
                                  industry.solutions['campaigns']!)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Conversation Flow
            Container(
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
              child: WebContainer(
                maxWidth: 800,
                child: Column(
                  children: [
                    const AppBadge(text: 'Sample Conversational Flow'),
                    const SizedBox(height: 16),
                    const Text('See It In Action',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(
                        'Here\'s how a typical AI conversation works for ${industry.name}',
                        style: const TextStyle(
                            fontSize: 18, color: AppColors.mutedForeground),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    ...industry.conversationFlow
                        .map((step) => _buildFlowStep(step))
                        .toList(),
                  ],
                ),
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(
      String title, IconData icon, Color color, List<String> solutions) {
    return AppCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...solutions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.checkCircle2, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s)),
                ],
              ),
            )),
      ],
    ));
  }

  Widget _buildFlowStep(Map<String, dynamic> step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPrimary,
            ),
            child: Center(
                child: Text(step['step'].toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  color: AppColors.primary.withOpacity(0.05),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  child: Text(step['message']),
                ),
                if (step['response'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 32.0),
                    child: AppCard(
                      color: AppColors.muted,
                      child: Text(step['response'],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
