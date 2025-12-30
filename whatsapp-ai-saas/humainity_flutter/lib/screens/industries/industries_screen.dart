import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/data/industries_data.dart';
import 'package:humainise_ai/screens/home/widgets/footer.dart';
import 'package:humainise_ai/screens/home/widgets/navigation.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainise_ai/data/industry_model.dart';

class IndustriesScreen extends StatelessWidget {
  const IndustriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: const HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE0F2FE),
                    Color(0xFFF5F3FF),
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // 1. TOP BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.sparkles,
                                size: 16, color: Color(0xFF0EA5E9)),
                            SizedBox(width: 8),
                            Text(
                              'Human + AI Collaboration Platform',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF0EA5E9)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 2. PRIMARY TITLE
                      const Text(
                        'Automate with Empathy, Across Every Industry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 3. SECONDARY TITLE
                      const Text(
                        'Industries & Use Cases',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 4. DESCRIPTION
                      const Text(
                        'Click on any industry to explore tailored automation solutions, conversational flows, and success metrics specific to your business needs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // INDUSTRIES GRID
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment:
                        isMobile ? WrapAlignment.center : WrapAlignment.start,
                    children: industries.map((industry) {
                      return _IndustryCard(
                          industry: industry, isMobile: isMobile);
                    }).toList(),
                  ),
                ),
              ),
            ),
            // FINAL CTA Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              margin: const EdgeInsets.only(bottom: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Ready to Transform Your Industry?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Launch AI-powered automation in your business today. No credit card required.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // DUAL CTA BUTTONS
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            const AppButton(
                              text: 'Launch Your AI Agent Now',
                              // onPressed: () => context.go('/auth'),
                              isLg: true,
                              backgroundColor: Colors.white,
                              textColor: AppColors.primary,
                            ),
                            // Secondary 'See Features' Button (ADDED)
                            AppButton(
                              text: 'See Features',
                              onPressed: () => context.go('/'),
                              isLg: true,
                              // Ghost button styling on primary background
                              backgroundColor: Colors.transparent,
                              textColor: Colors.white,
                              // Note: Assuming AppButton handles an outlined appearance
                              // when background is transparent and text is colored.
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _IndustryCard extends StatelessWidget {
  final Industry industry;
  final bool isMobile;

  const _IndustryCard({required this.industry, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = isMobile ? double.infinity : 380;

    return InkWell(
      onTap: () => context.go('/industries/${industry.id}', extra: industry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: cardWidth,
        height: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          // Left-alignment for exact card look
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(industry.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              industry.name,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              industry.tagline,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              industry.description,
              textAlign: TextAlign.start,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Explore Solutions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB), // Blue link color
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
