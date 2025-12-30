import 'package:flutter/material.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';

class AppTabs extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const AppTabs({
    required this.controller,
    required this.tabs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        indicator: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1E293B),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.foreground,
        unselectedLabelColor: AppColors.mutedForeground,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
      ),
    );
  }
}

class AppTab extends StatelessWidget {
  final String text;
  final IconData? icon;

  const AppTab({required this.text, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Tab(text: text);
    }
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
