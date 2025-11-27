import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';


final onboardingStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final store = ref.watch(storeUserDataProvider);

  if (store == null) {
    return {
      'onboarding_steps': {
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

/// ---------------------------------------------------------------------------
/// SIDEBAR WIDGET
/// ---------------------------------------------------------------------------
class SidebarContent extends ConsumerWidget {
  const SidebarContent({super.key});

  // Completed Navigation
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
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle,
      'showStepIndicator': false,
    },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings,
      'showStepIndicator': false,
    },
  ];

  // In-process Navigation
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
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings,
      'showStepIndicator': false,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingStatusProvider);
    final store = ref.watch(storeUserDataProvider);
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Column(
      children: [
        _buildLogo(),
        Expanded(
          child: onboardingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text("Failed to load onboarding data"),
            ),
            data: (status) {
              final steps = Map<String, bool>.from(status['onboarding_steps']);

              final step1 = steps["AI_Agent_Configuration"] ?? false;
              final step2 = steps["Knowledge_Base_Ingestion"] ?? false;
              final step3 = steps["template_Messages_Setup"] ?? false;

              final completedSteps =
                  [step1, step2, step3].where((e) => e).length;

              final process = status["onboarding_process"] ?? "InProcess";

              final navItems = process == "Completed"
                  ? completedNavigation
                  : inProcessNavigation;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildStepTracker(completedSteps),
                  const SizedBox(height: 16),
                  ...navItems.map((item) {
                    final isActive =
                        currentLocation.startsWith(item["href"]);

                    bool completed = false;
                    bool clickable = false;

                    switch (item["name"]) {
                      case 'AI Agent':
                        completed = step1;
                        clickable = true;
                        break;
                      case 'Knowledge':
                        completed = step2;
                        clickable = step1;
                        break;
                      case 'Templates':
                        completed = step3;
                        clickable = step2;
                        break;
                      case 'Test Agent':
                        clickable = step1 && step2 && step3;
                        break;
                      default:
                        completed = true;
                        clickable = true;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildNavItem(
                        context,
                        icon: item["icon"],
                        text: item["name"],
                        href: item["href"],
                        isActive: isActive,
                        completed: completed,
                        clickable: clickable,
                        showStepIndicator: item["showStepIndicator"] ?? true,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        _buildUserSection(ref, store),
      ],
    );
  }

  /// ---------------------------------------------------------------------------
  /// LOGO
  /// ---------------------------------------------------------------------------
  Widget _buildLogo() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// ---------------------------------------------------------------------------
  /// STEP TRACKER
  /// ---------------------------------------------------------------------------
  Widget _buildStepTracker(int completedSteps) {
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
            "Get Your WhatsApp AI Agent Live",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "Steps $completedSteps out of 3 completed to go live",
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

  /// ---------------------------------------------------------------------------
  /// NAV ITEM
  /// ---------------------------------------------------------------------------
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String href,
    required bool isActive,
    required bool completed,
    required bool clickable,
    bool showStepIndicator = true,
  }) {
    final itemColor = !clickable
        ? AppColors.mutedForeground.withOpacity(0.3)
        : (isActive ? AppColors.primaryForeground : AppColors.mutedForeground);

    return Material(
      color: isActive && clickable ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: clickable
            ? () {
                if (Responsive.isMobile(context)) Navigator.pop(context);
                context.go(href);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
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
                    color: itemColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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

  /// ---------------------------------------------------------------------------
  /// USER SECTION
  /// ---------------------------------------------------------------------------
  Widget _buildUserSection(WidgetRef ref, StoreUserData? store) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: FutureBuilder<String?>(
              future: store?.getUserName(),
              builder: (_, snap) {
                final initial = (snap.data?.isNotEmpty ?? false)
                    ? snap.data![0].toUpperCase()
                    : "U";
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
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: store?.getUserName(),
                  builder: (_, snap) => Text(
                    snap.data ?? "User Name",
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                FutureBuilder<String?>(
                  future: store?.getEmail(),
                  builder: (_, snap) => Text(
                    snap.data ?? "user@example.com",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(LucideIcons.logOut,
                color: AppColors.mutedForeground),
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