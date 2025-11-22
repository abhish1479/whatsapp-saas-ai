import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/repositories/auth_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class SidebarContent extends ConsumerStatefulWidget {
  const SidebarContent({super.key});

  @override
  ConsumerState<SidebarContent> createState() => _SidebarContentState();
}

class _SidebarContentState extends ConsumerState<SidebarContent> {
  late Future<Map<String, dynamic>> _onboardingStatusFuture;
  late Future<String?> _userNameFuture;
  late Future<String?> _emailFuture;

  @override
  void initState() {
    super.initState();
    final storeUserData = ref.read(storeUserDataProvider);

    // Fetch onboarding status from API using tenant_id
    _onboardingStatusFuture = storeUserData!.getTenantId().then((tenantId) {
      if (tenantId == null || tenantId.isEmpty) {
        return <String, dynamic>{};
      }
      final id = int.tryParse(tenantId) ?? 0;
      if (id == 0) {
        return <String, dynamic>{};
      }
      return ref.read(authRepositoryProvider).getOnboardingStatus(id);
    });

    _userNameFuture = storeUserData.getUserName();
    _emailFuture = storeUserData.getEmail();
  }

  // Navigation when onboarding is Completed
  static const List<Map<String, dynamic>> completedNavigation = [
    {
      'name': 'Dashboard',
      'href': '/dashboard',
      'icon': LucideIcons.layoutDashboard,
    },
    {
      'name': 'Campaigns',
      'href': '/dashboard/campaigns',
      'icon': LucideIcons.megaphone,
    },
    {
      'name': 'CRM',
      'href': '/dashboard/crm',
      'icon': LucideIcons.users,
    },
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot,
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen,
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare,
    },
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle,
    },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings,
    },
  ];

  // Navigation when onboarding is still in process
  static const List<Map<String, dynamic>> inProcessNavigation = [
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot,
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen,
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare,
    },
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle,
    },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).matchedLocation;

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
        ),

        // NAVIGATION + STEP TRACKER (scrollable)
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _onboardingStatusFuture,
            builder: (context, statusSnap) {
              if (statusSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final status = statusSnap.data ?? <String, dynamic>{};
              final stepsMap =
                  Map<String, dynamic>.from(status['onboarding_steps'] ?? {});

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

              final navItems = process == 'Completed'
                  ? completedNavigation
                  : inProcessNavigation;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // ---- TOP STEP TRACKER ----
                  _buildStepTracker(completedSteps),

                  const SizedBox(height: 16),

                  // ---- NAV ITEMS ----
                  ...navItems.map((item) {
                    final bool isActive =
                        currentLocation.startsWith(item['href'] as String);

                    bool completed = false;
                    bool clickable = false;

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
                        final allDone = step1 && step2 && step3;
                        completed = allDone;
                        clickable = allDone; // unlock only when all 3 done
                        break;

                      case 'Settings':
                        completed = true;
                        clickable = true;
                        break;

                      default:
                        completed = true;
                        clickable = true;
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
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),

        // USER SECTION
        _buildUserSection(),
      ],
    );
  }

  // ---------- STEP TRACKER (Top of sidebar) ----------

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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String href,
    required bool isActive,
    required bool completed,
    required bool clickable,
  }) {
    final bool disabled = !clickable;

    final Color itemColor = disabled
        ? AppColors.mutedForeground.withOpacity(0.3)
        : (isActive
            ? AppColors.primaryForeground
            : AppColors.mutedForeground);

    return Material(
      color:
          isActive && clickable ? AppColors.primary : Colors.transparent,
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
            ? (isActive
                ? AppColors.primary.withOpacity(0.9)
                : AppColors.muted)
            : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: itemColor,
              ),
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
              Icon(
                completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
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

  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: AppColors.primaryForeground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: _userNameFuture,
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
                  future: _emailFuture,
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
