import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';

class DashboardPreviewSection extends StatelessWidget {
  const DashboardPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const Text(
              'See the Impact of Every Conversation',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Monitor, analyze, and optimize your customer engagement in real-time',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                image: const DecorationImage(
                  image: AssetImage('assets/images/dashboard-preview.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'Explore Full Dashboard',
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}