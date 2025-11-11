import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeNavigation extends StatelessWidget implements PreferredSizeWidget {
  const HomeNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.8),
      elevation: 0,
      title: WebContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            InkWell(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          color: AppColors.primaryForeground,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HumAInity.ai',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.foreground),
                  ),
                ],
              ),
            ),

            // Desktop Nav
            if (!isMobile(context))
              Row(
                children: [
                  _navLink(context, 'Features', '/#features'),
                  _navLink(context, 'Industries', '/industries'),
                  _navLink(context, 'Pricing', '/#pricing'),
                  _navLink(context, 'Testimonials', '/#testimonials'),
                  const SizedBox(width: 16),
                  AppButton(
                    text: 'Login',
                    // FIX: Replaced variant: AppButtonVariant.outline with style: AppButtonStyle.tertiary
                    style: AppButtonStyle.tertiary,
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Get Started',
                    onPressed: () => context.go('/dashboard'),
                  ),
                ],
              ),

            // Mobile Nav
            if (isMobile(context))
              IconButton(
                icon: const Icon(LucideIcons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String text, String path) {
    return TextButton(
      onPressed: () {
        if (path.startsWith('/#')) {
          // Handle scroll to section, not implemented in this conversion
          print('Scroll to ${path.substring(2)}');
        } else {
          context.go(path);
        }
      },
      child: Text(
        text,
        style: const TextStyle(
            color: AppColors.foreground, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}

// TODO: Implement a mobile drawer (EndDrawer) in home_screen.dart
