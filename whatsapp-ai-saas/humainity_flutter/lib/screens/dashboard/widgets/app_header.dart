import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'go_live_dialog.dart'; // Import the new dialog
import 'sidebar_content.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const AppHeader({this.onMenuPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingStatusProvider);

    bool goLiveEnabled = false;
    bool isCompleted = false;

    onboardingAsync.whenData((status) {
      // Check if process is fully completed
      if (status['onboarding_process'] == 'Completed') {
        isCompleted = true;
      }

      // Logic to enable button if steps are done but not yet 'Completed'
      final stepsMap = Map<String, dynamic>.from(status['onboarding_steps'] ?? {});
      final step1 = stepsMap['AI_Agent_Configuration'] == true;
      final step2 = stepsMap['Knowledge_Base_Ingestion'] == true;
      final step3 = stepsMap['template_Messages_Setup'] == true;
      goLiveEnabled = step1 && step2 && step3;
    });

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMobile(context))
            IconButton(
              icon: const Icon(LucideIcons.menu),
              onPressed: onMenuPressed,
            ),
          const Spacer(),

          // Only show button if NOT completed
          if (!isCompleted)
            SizedBox(
              height: 44,
              child: AppButton(
                text: 'Go Live',
                // Enable button only if steps are done
                onPressed: goLiveEnabled
                    ? () => showDialog(
                    context: context,
                    builder: (_) => const GoLiveDialog()
                )
                    : null,
                style: goLiveEnabled ? AppButtonStyle.primary : AppButtonStyle.secondary,
              ),
            )
          else
            SizedBox(
              height: 44,
              child: AppButton(
                text: 'Test Agent',
                icon: const Icon(LucideIcons.playCircle, size: 16),
                style: AppButtonStyle.primary, // Less prominent than Go Live
                onPressed: () => context.go('/dashboard/agent-preview'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}