// lib/screens/dashboard/dashboard_home_screen.dart
import 'package:flutter/material.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:humainise_ai/widgets/ui/app_dropdown.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  _DashboardHomeScreenState createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  String _selectedPeriod = 'Last 30 days';

  // FIX: Changed from const to final because Colors.blue.shade500 is not a constant.
  final List<Map<String, dynamic>> inboundStats = [
    {
      "name": "Inbound Messages",
      "value": "1,234",
      "change": "+12.5%",
      "icon": LucideIcons.messageSquare,
      "color": Colors.blue.shade500
    },
    {
      "name": "Incoming Calls",
      "value": "567",
      "change": "+8.2%",
      "icon": LucideIcons.phone,
      "color": Colors.blue.shade500
    },
    {
      "name": "New Enquiries",
      "value": "456",
      "change": "+15.3%",
      "icon": LucideIcons.fileText,
      "color": Colors.blue.shade500
    },
    {
      "name": "Inbound Conversion",
      "value": "38.5%",
      "change": "+6.2%",
      "icon": LucideIcons.trendingUp,
      "color": Colors.blue.shade500
    },
  ];

  final List<Map<String, dynamic>> outboundStats = [
    {
      "name": "Outbound Campaigns",
      "value": "23",
      "change": "+4",
      "icon": LucideIcons.arrowUpFromLine,
      "color": Colors.purple.shade500
    },
    {
      "name": "Messages Sent",
      "value": "8,901",
      "change": "+23.1%",
      "icon": LucideIcons.messageSquare,
      "color": Colors.purple.shade500
    },
    {
      "name": "Follow-ups",
      "value": "342",
      "change": "+18.7%",
      "icon": LucideIcons.phone,
      "color": Colors.purple.shade500
    },
    {
      "name": "Outbound Conversion",
      "value": "28.3%",
      "change": "+4.8%",
      "icon": LucideIcons.trendingUp,
      "color": Colors.purple.shade500
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          // ... Rest of your widgets
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // FIX: .headline4 is obsolete. Use .headlineMedium
        Text(
          'Welcome Back!',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 200,
          child: AppDropdown<String>(
            labelText: 'Period',
            value: _selectedPeriod,
            // FIX: Must provide DropdownMenuItem widgets, not just strings
            items: const [
              DropdownMenuItem(
                  value: 'Last 7 days', child: Text('Last 7 days')),
              DropdownMenuItem(
                  value: 'Last 30 days', child: Text('Last 30 days')),
              DropdownMenuItem(
                  value: 'Last 90 days', child: Text('Last 90 days')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedPeriod = val);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIX: .headline6 is obsolete. Use .titleLarge
        Text('Inbound Performance',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2,
          ),
          itemCount: inboundStats.length,
          itemBuilder: (context, index) => _buildStatCard(inboundStats[index]),
        ),
        const SizedBox(height: 24),
        // FIX: .headline6 is obsolete. Use .titleLarge
        Text('Outbound Performance',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2,
          ),
          itemCount: outboundStats.length,
          itemBuilder: (context, index) => _buildStatCard(outboundStats[index]),
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIX: AppColors.textSecondary does not exist. Use .mutedForeground
              Text(stat['name'],
                  style: TextStyle(color: AppColors.mutedForeground)),
              Icon(stat['icon'], color: stat['color'], size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX: .headline5 is obsolete. Use .headlineSmall
              Text(stat['value'],
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(stat['change'],
                  style: const TextStyle(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}
