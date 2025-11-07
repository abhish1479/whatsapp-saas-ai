import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildBrandInfo(),
                  const SizedBox(height: 32),
                  _buildFooterLinks(),
                  const SizedBox(height: 32),
                  _buildContactInfo(),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildBrandInfo()),
                  Expanded(flex: 1, child: _buildFooterLinks()),
                  Expanded(flex: 1, child: _buildContactInfo()),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 32),
            ResponsiveLayout(
              mobile: Column(
                children: [
                  Text('© ${DateTime.now().year} HumAInity.ai. All rights reserved.', style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  const SizedBox(height: 8),
                  const Text('Powered by Mymobiforce', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
              desktop: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('© ${DateTime.now().year} HumAInity.ai. All rights reserved.', style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  const Text('Powered by Mymobiforce', style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Where Human Care Meets AI Efficiency. Automate customer support and sales outreach with AI that talks, sells & supports — 24×7.',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildFooterLink('Features'),
        _buildFooterLink('Industries'),
        _buildFooterLink('Solutions'),
        _buildFooterLink('Pricing'),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Get in Touch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildFooterLink('Dheeraj.khatter@mymobiforce.com', icon: LucideIcons.mail),
        _buildFooterLink('+91-9871777715', icon: LucideIcons.phone),
        _buildFooterLink('WhatsApp Support', icon: LucideIcons.messageSquare),
      ],
    );
  }

  Widget _buildFooterLink(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.mutedForeground),
            const SizedBox(width: 8),
          ],
          Text(text, style: const TextStyle(color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}