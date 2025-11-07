import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const AppHeader({this.onMenuPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (isMobile(context))
            IconButton(
              icon: const Icon(LucideIcons.menu),
              onPressed: onMenuPressed,
            ),
          const Spacer(),
          AppButton(
            text: 'Test Agent',
            onPressed: () => context.go('/dashboard/agent-preview'),
            variant: AppButtonVariant.outline,
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Go Live',
            onPressed: () {
              // TODO: Implement Go Live
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}