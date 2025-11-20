import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/providers/auth_provider.dart';
import 'package:humainity_flutter/core/providers/chat_provider.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class SidebarContent extends ConsumerStatefulWidget {
  const SidebarContent({super.key});

  @override
  ConsumerState<SidebarContent> createState() => _SidebarContentState();
}

class _SidebarContentState extends ConsumerState<SidebarContent> {
  late Future<String?> _onboardingProcessFuture;
  late Future<String?> _userNameFuture; // ADDED
  late Future<String?> _emailFuture; // ADDED

  @override
  void initState() {
    super.initState();
    final storeUserData = ref.read(storeUserDataProvider);

    // Initialize futures for onboarding status
    _onboardingProcessFuture =
        storeUserData?.getOnboardingProcess() ?? Future.value(null);

    // ADDED: Initialize futures for user details
    _userNameFuture = storeUserData?.getUserName() ?? Future.value("User Name");
    _emailFuture = storeUserData?.getEmail() ?? Future.value("user@gmail.com");
  }

  // 1. Navigation for "Completed" status
  static const List<Map<String, dynamic>> completedNavigation = [
    {
      'name': 'Dashboard',
      'href': '/dashboard',
      'icon': LucideIcons.layoutDashboard
    },
    {
      'name': 'Campaigns',
      'href': '/dashboard/campaigns',
      'icon': LucideIcons.megaphone
    },
    {'name': 'CRM', 'href': '/dashboard/crm', 'icon': LucideIcons.users},
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare
    },
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle
    },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings
    },
  ];

  // 2. Navigation for "InProcess" status
  static const List<Map<String, dynamic>> inProcessNavigation = [
    {
      'name': 'AI Agent',
      'href': '/dashboard/ai-agent',
      'icon': LucideIcons.bot
    },
    {
      'name': 'Knowledge',
      'href': '/dashboard/knowledge',
      'icon': LucideIcons.bookOpen
    },
    {
      'name': 'Templates',
      'href': '/dashboard/templates',
      'icon': LucideIcons.messageSquare
    },
    {
      'name': 'Test Agent',
      'href': '/dashboard/agent-preview',
      'icon': LucideIcons.playCircle
    },
    {
      'name': 'Settings',
      'href': '/dashboard/settings',
      'icon': LucideIcons.settings
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

        // Navigation - Wrapped in FutureBuilder
        Expanded(
          child: FutureBuilder<String?>(
            future: _onboardingProcessFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final onboardingProcess = snapshot.data;
              List<Map<String, dynamic>> navigationItems;

              if (onboardingProcess == 'Completed') {
                navigationItems = completedNavigation;
              } else {
                navigationItems = inProcessNavigation;
              }

              return ListView(
                padding: const EdgeInsets.all(12),
                children: navigationItems.map((item) {
                  final bool isActive =
                  currentLocation.startsWith(item['href']);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: _buildNavItem(
                      context,
                      icon: item['icon'] as IconData,
                      text: item['name'] as String,
                      href: item['href'] as String,
                      isActive: isActive,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        // User Section - UPDATED to use Futures
        Container(
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
                    // Dynamic User Name
                    FutureBuilder<String?>(
                      future: _userNameFuture,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'User Name',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    // Dynamic Email
                    FutureBuilder<String?>(
                      future: _emailFuture,
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'user@example.com',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.mutedForeground),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Logout Button
              IconButton(
                icon: const Icon(LucideIcons.logOut,
                    color: AppColors.mutedForeground),
                tooltip: 'Logout',
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                  ref.read(agentPreviewChatProvider.notifier).clearChat();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String text,
        required String href,
        required bool isActive,
      }) {
    Color itemColor =
    isActive ? AppColors.primaryForeground : AppColors.mutedForeground;

    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () {
          if (Responsive.isMobile(context)) {
            Navigator.of(context).pop();
          }
          context.go(href);
        },
        borderRadius: BorderRadius.circular(8.0),
        hoverColor:
        isActive ? AppColors.primary.withOpacity(0.9) : AppColors.muted,
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
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}