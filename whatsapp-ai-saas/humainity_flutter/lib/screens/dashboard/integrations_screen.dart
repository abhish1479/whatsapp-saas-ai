import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Integrations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Connect your favorite tools and platforms to streamline your workflows',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          _buildIntegrationCategory(
            context: context,
            title: 'E-Commerce & Retail',
            icon: LucideIcons.shoppingCart,
            integrations: [
              _buildIntegrationCard(
                title: 'Shopify',
                description: 'E-commerce platform',
                icon: LucideIcons.shoppingCart,
                isConnected: false,
                onConnect: () {},
              ),
              _buildIntegrationCard(
                title: 'WooCommerce',
                description: 'WordPress e-commerce',
                icon: LucideIcons.database,
                isConnected: false,
                onConnect: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildIntegrationCategory(
            context: context,
            title: 'CRM Systems',
            icon: LucideIcons.users,
            integrations: [
              _buildIntegrationCard(
                title: 'Salesforce',
                description: 'Cloud CRM platform',
                icon: LucideIcons.users,
                isConnected: false,
                onConnect: () {},
                apiKeyField: 'Salesforce API key',
              ),
              _buildIntegrationCard(
                title: 'Zoho CRM',
                description: 'Customer management',
                icon: LucideIcons.users,
                isConnected: false,
                onConnect: () {},
                apiKeyField: 'Zoho API key',
              ),
            ],
          ),
          // Add other categories...
        ],
      ),
    );
  }

  Widget _buildIntegrationCategory({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> integrations,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile(context) ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile(context) ? 2.5 : 1.5,
            ),
            itemCount: integrations.length,
            itemBuilder: (context, index) => integrations[index],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isConnected,
    required VoidCallback onConnect,
    String? apiKeyField,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(description, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(isConnected ? LucideIcons.checkCircle : LucideIcons.xCircle,
                        size: 12, color: isConnected ? AppColors.success : AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'Not Connected',
                      style: TextStyle(
                          fontSize: 10,
                          color: isConnected ? AppColors.success : AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (apiKeyField != null) ...[
            AppTextField(
                labelText: '$title API Key',
                hintText: apiKeyField),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: isConnected ? 'Disconnect' : 'Connect',
              variant: AppButtonVariant.outline,
              onPressed: onConnect,
            ),
          ),
        ],
      ),
    );
  }
}