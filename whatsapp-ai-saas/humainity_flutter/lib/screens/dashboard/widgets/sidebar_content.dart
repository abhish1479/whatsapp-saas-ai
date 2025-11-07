import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key});

  static const List<Map<String, dynamic>> navigation = [
    {'name': 'Dashboard', 'href': '/dashboard', 'icon': LucideIcons.layoutDashboard},
    {'name': 'AI Agent', 'href': '/dashboard/ai-agent', 'icon': LucideIcons.bot},
    {'name': 'Test Agent', 'href': '/dashboard/agent-preview', 'icon': LucideIcons.playCircle},
    {'name': 'Train Agent', 'href': '/dashboard/train-agent', 'icon': LucideIcons.graduationCap},
    {'name': 'Knowledge', 'href': '/dashboard/knowledge', 'icon': LucideIcons.bookOpen},
    {'name': 'Actions', 'href': '/dashboard/actions', 'icon': LucideIcons.zap},
    {'name': 'Forms', 'href': '/dashboard/forms', 'icon': LucideIcons.fileText},
    {'name': 'Templates', 'href': '/dashboard/templates', 'icon': LucideIcons.messageSquare},
    {'name': 'Campaigns', 'href': '/dashboard/campaigns', 'icon': LucideIcons.megaphone},
    {'name': 'CRM', 'href': '/dashboard/crm', 'icon': LucideIcons.users},
    {'name': 'Integrations', 'href': '/dashboard/integrations', 'icon': LucideIcons.link2},
    {'name': 'Settings', 'href': '/dashboard/settings', 'icon': LucideIcons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    // FIX: Get location from GoRouterState
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
        // Navigation
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: navigation.map((item) {
              // FIX: Handle base route matching
              final bool isActive = (currentLocation == item['href']) ||
                  (item['href'] == '/dashboard' && currentLocation.startsWith('/dashboard') && currentLocation != '/dashboard/ai-agent' &&
                      !currentLocation.startsWith('/dashboard/agent-preview') && !currentLocation.startsWith('/dashboard/train-agent') &&
                      !currentLocation.startsWith('/dashboard/knowledge') && !currentLocation.startsWith('/dashboard/actions') &&
                      !currentLocation.startsWith('/dashboard/forms') && !currentLocation.startsWith('/dashboard/templates') &&
                      !currentLocation.startsWith('/dashboard/campaigns') && !currentLocation.startsWith('/dashboard/crm') &&
                      !currentLocation.startsWith('/dashboard/integrations') && !currentLocation.startsWith('/dashboard/settings')
                  );

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
          ),
        ),
        // User Section
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'user@example.com',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
    Color itemColor = isActive ? AppColors.primaryForeground : AppColors.mutedForeground;

    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () {
          // Close drawer if on mobile
          if (Responsive.isMobile(context)) {
            Navigator.of(context).pop();
          }
          context.go(href);
        },
        borderRadius: BorderRadius.circular(8.0),
        hoverColor: isActive ? AppColors.primary.withOpacity(0.9) : AppColors.muted,
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