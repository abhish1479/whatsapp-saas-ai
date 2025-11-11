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

class IndustriesScreen extends StatelessWidget {
  const IndustriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
              child: WebContainer(
                child: Column(
                  children: [
                    const AppBadge(
                      text: 'Human + AI Collaboration Platform',
                      icon: Icon(LucideIcons.sparkles,
                          size: 12, color: AppColors.primary),
                      color: AppColors.primaryLight,
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Industries & Use Cases',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Discover how HumAInity.AI helps SMBs across diverse industries automate customer interactions while maintaining the human touch.',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                            text: 'Start Free Trial',
                            onPressed: () => context.go('/dashboard')),
                        const SizedBox(width: 16),
                        // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                        AppButton(
                            text: 'See Features',
                            style: AppButtonStyle.tertiary,
                            onPressed: () => context.go('/#features')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Grid
            Container(
              color: AppColors.muted.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
              child: WebContainer(
                child: Column(
                  children: [
                    const Text(
                      'Automate with Empathy, Across Every Industry',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Click on any industry to explore tailored automation solutions, conversational flows, and success metrics.',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile(context) ? 1 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile(context) ? 1.5 : 1.2,
                      ),
                      itemCount: industries.length,
                      itemBuilder: (context, index) {
                        final industry = industries[index];
                        return InkWell(
                          onTap: () => context.go('/industries/${industry.id}'),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.gradientPrimary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(industry.icon,
                                          color: AppColors.primaryForeground,
                                          size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(industry.name,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600)),
                                          Text(industry.tagline,
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.mutedForeground,
                                                  fontSize: 12),
                                              maxLines: 2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(industry.description,
                                    style: const TextStyle(
                                        color: AppColors.mutedForeground),
                                    maxLines: 3),
                                const Spacer(),
                                Row(
                                  children: const [
                                    Text('Explore Solutions',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(width: 4),
                                    Icon(LucideIcons.arrowRight,
                                        color: AppColors.primary, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
}
