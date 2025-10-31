import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/business_info_theme.dart';
import 'campaigns/campaigns_list_screen.dart';
import 'leads/leads_hub_screen.dart';
import 'monitoring/live_board_screen.dart';

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({Key? key}) : super(key: key);

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int _selectedIndex = 0;

  final _pages = const [
    LeadsHubScreen(),
    CampaignListScreen(),
    LiveBoardScreen(),
  ];

  final _pageTitles = const ["Leads", "Campaigns", "Monitoring"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
        return isMobile ? _buildMobileLayout(theme) : _buildWebLayout(theme, sizingInfo);
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 🌐 WEB / DESKTOP LAYOUT
  // ───────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BusinessInfoTheme theme, SizingInformation sizingInfo) {
    final isExtended = sizingInfo.screenSize.width > 1200;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isExtended ? 220 : 80,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [theme.cardShadow],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildLogo(isExtended),
                const SizedBox(height: 24),
                Expanded(child: _buildSideNavigation(isExtended)),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                ),
              ),
              child: Column(
                children: [
                  _buildTopAppBar(theme),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 📱 MOBILE LAYOUT
  // ───────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BusinessInfoTheme theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [theme.cardShadow],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF3B82F6).withOpacity(0.15),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: Color(0xFF3B82F6)),
              label: "Leads",
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign, color: Color(0xFF3B82F6)),
              label: "Campaigns",
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart, color: Color(0xFF3B82F6)),
              label: "Monitoring",
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 🧭 Sidebar Navigation
  // ───────────────────────────────────────────────────────────────
  Widget _buildSideNavigation(bool isExtended) {
    final items = [
      _NavItem(
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: "Leads",
      ),
      _NavItem(
        icon: Icons.campaign_outlined,
        selectedIcon: Icons.campaign,
        label: "Campaigns",
      ),
      _NavItem(
        icon: Icons.monitor_heart_outlined,
        selectedIcon: Icons.monitor_heart,
        label: "Monitoring",
      ),
    ];

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = _selectedIndex == index;

        return InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                ),
                if (isExtended) ...[
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? const Color(0xFF3B82F6) : const Color(0xFF475569),
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 🧭 Top AppBar (Web)
  // ───────────────────────────────────────────────────────────────
  Widget _buildTopAppBar(BusinessInfoTheme theme) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [theme.cardShadow],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            _pageTitles[_selectedIndex],
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
            tooltip: "Notifications",
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person_outline, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // 🧭 Logo Section
  // ───────────────────────────────────────────────────────────────
  Widget _buildLogo(bool isExtended) {
    return Row(
      mainAxisAlignment: isExtended ? MainAxisAlignment.center : MainAxisAlignment.center,
      children: [
        const Icon(Icons.chat_bubble_outline, color: Color(0xFF3B82F6), size: 28),
        if (isExtended)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              "LeadBot AI",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
