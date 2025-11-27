import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class HomeNavigation extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onFeaturesTap;
  final VoidCallback? onSolutionsTap;
  final VoidCallback? onHowItWorksTap;
  final VoidCallback? onPricingTap;
  final VoidCallback? onTestimonialsTap;
  final VoidCallback? onAgentsTap;
  final VoidCallback? onExperienceTap;
  const HomeNavigation({
    super.key,
    this.onFeaturesTap,
    this.onSolutionsTap,
    this.onHowItWorksTap,
    this.onPricingTap,
    this.onTestimonialsTap,
    this.onAgentsTap,
    this.onExperienceTap
  });

  @override
  Widget build(BuildContext context) {
    return WebContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(context),
          if (!isMobile(context)) _buildDesktopNav(context),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/'),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'HumAInity.ai',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      children: [
        _navItem("Features", onFeaturesTap),
        _navItem("Solutions", onSolutionsTap),
        _navItem("How It Works", onHowItWorksTap),
        _navItem("Pricing", onPricingTap),
        _navItem("Testimonials", onTestimonialsTap),
        TextButton(
          onPressed: () => context.go('/industries'),
          child: const Text("Industries"),
        ),
        const SizedBox(width: 10),
        AppButton(
          text: "Get Started",
          onPressed: () => context.go('/dashboard/ai-agent'),
        ),
      ],
    );
  }

  Widget _navItem(String text, VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
