import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// ---------------------------------------------------------------------------
/// Onboarding status provider
/// ---------------------------------------------------------------------------
final onboardingStatusProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  // Recompute whenever onboardingRefreshProvider is bumped
  ref.watch(onboardingRefreshProvider);

  final store = ref.watch(storeUserDataProvider);
  if (store == null) {
    return {
      'onboarding_steps': <String, bool>{
        'AI_Agent_Configuration': false,
        'Knowledge_Base_Ingestion': false,
        'template_Messages_Setup': false,
      },
      'onboarding_process': 'InProcess',
    };
  }

  final steps = await store.getOnboardingSteps();
  final process = await store.getOnboardingProcess() ?? 'InProcess';

  return {
    'onboarding_steps': steps,
    'onboarding_process': process,
  };
});

class SidebarContent extends ConsumerWidget {
  const SidebarContent({super.key});

  // Navigation when onboarding is Completed
  static const List<Map<String, dynamic>> completedNavigation = [
    {
      'name': 'Dashboard',
      'href': '/dashboard',
      'icon': LucideIcons.layoutDashboard,
      'showStepIndicator': false,
    },
    {
      'name': 'Campaigns',
      'href': '/dashboard/campaigns',
      'icon': LucideIcons.megaphone,
      'showStepIndicator': false,
    },
    {
      'name': 'CRM',
      'href': '/dashboard/crm',
      'icon': LucideIcons.users,
      'showStepIndicator': false,
    },
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot,
      'showStepIndicator': false,
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen,
      'showStepIndicator': false,
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare,
      'showStepIndicator': false,
    },
    // {
    //   'name': 'Test Agent',
    //   'href': '/dashboard/agent-preview',
    //   'icon': LucideIcons.playCircle,
    //   'showStepIndicator': false,
    // },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings,
      'showStepIndicator': false,
    },
  ];

  // Navigation when onboarding is still in process
  static const List<Map<String, dynamic>> inProcessNavigation = [
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot,
      'showStepIndicator': true,
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen,
      'showStepIndicator': true,
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare,
      'showStepIndicator': true,
    },
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle,
      'showStepIndicator': false,
    },
    // {
    //   'name': 'Settings',
    //   'href': '/dashboard/settings',
    //   'icon': LucideIcons.settings,
    //   'showStepIndicator': false,
    // },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentLocation = GoRouterState.of(context).matchedLocation;

    final onboardingAsync = ref.watch(onboardingStatusProvider);

    return Column(
      children: [
        // Logo
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: const [
              _LogoBox(),
              SizedBox(width: 8),
              Text(
                'HumAInity.ai',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),

        // NAVIGATION + STEP TRACKER (scrollable)
        Expanded(
          child: onboardingAsync.when(
            loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, stack) => Center(
              child: Text(
                'Failed to load menu',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            data: (status) {
              final stepsMap = Map<String, dynamic>.from(
                status['onboarding_steps'] ?? {},
              );

              final bool step1 =
                  (stepsMap['AI_Agent_Configuration'] ?? false) == true;
              final bool step2 =
                  (stepsMap['Knowledge_Base_Ingestion'] ?? false) == true;
              final bool step3 =
                  (stepsMap['template_Messages_Setup'] ?? false) == true;

              final int completedSteps =
                  [step1, step2, step3].where((e) => e).length;

              final String process =
                  (status['onboarding_process'] as String?) ?? 'InProcess';

              final bool isCompleted = process == 'Completed';

              final navItems = isCompleted
                  ? completedNavigation
                  : inProcessNavigation;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // ✅ Hide Step Tracker if Completed
                  if (!isCompleted) ...[
                    _buildStepTracker(completedSteps),
                    const SizedBox(height: 16),
                  ],
                  ...navItems.map((item) {
                    final bool isActive =
                    currentLocation.startsWith(item['href'] as String);

                    bool completed = false;
                    bool clickable = false;

                    // If globally completed, everything is clickable
                    if (isCompleted) {
                      completed = true;
                      clickable = true;
                    } else {
                      switch (item['name']) {
                        case 'AI Agent':
                          completed = step1;
                          clickable = true; // first step always clickable
                          break;
                        case 'Knowledge':
                          completed = step2;
                          clickable = step1; // unlock after step 1
                          break;
                        case 'Templates':
                          completed = step3;
                          clickable = step2; // unlock after step 2
                          break;
                        case 'Test Agent':
                          clickable =
                              step1 && step2 && step3; // unlock when all done
                          break;
                        default:
                          completed = true;
                          clickable = true;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildNavItem(
                        context,
                        icon: item['icon'] as IconData,
                        text: item['name'] as String,
                        href: item['href'] as String,
                        isActive: isActive,
                        completed: completed,
                        clickable: clickable,
                        showStepIndicator:
                        item['showStepIndicator'] as bool? ?? true,
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),

        _buildUserSection(ref),
      ],
    );
  }

  // ---------- STEP TRACKER ----------
  static Widget _buildStepTracker(int completedSteps) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get Your WhatsApp AI Agent Live',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Steps $completedSteps out of 3 completed to go live',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completedSteps / 3,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // ---------- NAV ITEM ----------
  static Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        required String href,
        required bool isActive,
        required bool completed,
        required bool clickable,
        bool showStepIndicator = true,
      }) {
    final bool disabled = !clickable;
    final Color itemColor = disabled
        ? AppColors.mutedForeground.withOpacity(0.3)
        : (isActive ? AppColors.primaryForeground : AppColors.mutedForeground);

    return Material(
      color: isActive && clickable ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: clickable
            ? () {
          if (Responsive.isMobile(context)) {
            Navigator.of(context).pop();
          }
          context.go(href);
        }
            : null,
        borderRadius: BorderRadius.circular(8.0),
        hoverColor: clickable
            ? (isActive ? AppColors.primary.withOpacity(0.9) : AppColors.muted)
            : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: itemColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: itemColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showStepIndicator)
                Icon(
                  completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? Colors.green : Colors.grey,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- USER SECTION ----------
  Widget _buildUserSection(WidgetRef ref) {
    final store = ref.watch(storeUserDataProvider);

    final nameFuture = store?.getUserName();
    final emailFuture = store?.getEmail();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Avatar
          SizedBox(
            width: 40,
            height: 40,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
              ),
              child: FutureBuilder<String?>(
                future: nameFuture,
                builder: (context, snap) {
                  final name = snap.data;
                  final initial = (name?.trim().isNotEmpty == true)
                      ? name!.trim()[0].toUpperCase()
                      : 'U';
                  return Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: nameFuture,
                  builder: (context, snap) {
                    return Text(
                      snap.data ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                FutureBuilder<String?>(
                  future: emailFuture,
                  builder: (context, snap) {
                    return Text(
                      snap.data ?? 'user@example.com',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.logOut,
              color: AppColors.mutedForeground,
            ),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              ref.read(agentPreviewChatProvider.notifier).clearChat();
            },
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}