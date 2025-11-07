import 'package:flutter/material.dart';
import 'package:leadbot_client/screens/dashboard/views/ai_agent_screen.dart';
import 'package:leadbot_client/screens/dashboard/views/test_agent_screen.dart';
import 'side_menu.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    DashboardHome(),
    AIAgentScreen(),
    KnowledgeScreen(),
    TrainAgentScreen(),
    TemplatesScreen(),
    CampaignsScreen(),
    CRMScreen(),
    IntegrationsScreen(),
    SettingsScreen(),
  ];

  bool _isWide(BuildContext c) => MediaQuery.of(c).size.width >= 1080;

  void _onSelect(int i) {
    setState(() => _selectedIndex = i);
    if (!_isWide(context)) Navigator.pop(context); // close mobile drawer
  }

  @override
  Widget build(BuildContext context) {
    final isWide = _isWide(context);
    final current = _pages[_selectedIndex];

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide
          ? null
          : SideMenu(
              selectedIndex: _selectedIndex,
              onSelect: _onSelect,
              isDrawer: true,
            ),
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // Add a bottom border to create the divider line
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant, // Use the outline color for the line
          ),
        ),
        leading: isWide
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: isWide
            ? Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HumAInity.ai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              )
            : Text(
                '',
              ),
        titleSpacing: 0,
        actions: [
          OutlinedButton(onPressed: () {}, child: const Text('Test Agent')),
          const SizedBox(width: 8),
          FilledButton(onPressed: () {}, child: const Text('Go Live')),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            SideMenu(
              selectedIndex: _selectedIndex,
              onSelect: _onSelect,
              isDrawer: false,
            ),
          Expanded(child: current),
        ],
      ),
    );
  }
}
