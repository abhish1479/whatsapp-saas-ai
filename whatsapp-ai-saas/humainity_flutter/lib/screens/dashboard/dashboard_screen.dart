import 'package:flutter/material.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/screens/dashboard/widgets/app_header.dart';
import 'package:humainise_ai/screens/dashboard/widgets/sidebar_content.dart';

class DashboardScreen extends StatefulWidget {
  final Widget child;
  const DashboardScreen({required this.child, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppHeader(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: const Drawer(
          child: SidebarContent(),
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 256, // 64 * 4
            child: SidebarContent(),
          ),
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
