import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_radio_group.dart';
import 'package:humainity_flutter/widgets/ui/app_tabs.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currency = 'INR';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: WebContainer(
        child: Column(
          children: [
            const Text(
              'Simple, Transparent Pricing',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pay-per-usage pricing model. Choose what works best for your business.',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppRadioGroup<String>(
              groupValue: _currency,
              onChanged: (val) => setState(() => _currency = val!),
              // *** FIX: The label must be a Widget (like Text) ***
              items: const [
                AppRadioItem(label: Text('INR (₹)'), value: 'INR'),
                AppRadioItem(label: Text('USD (\$)'), value: 'USD'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 400,
              child: AppTabs(
                controller: _tabController,
                tabs: const [
                  AppTab(text: 'WhatsApp Automation'),
                  AppTab(text: 'Voice Automation'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 550, // Height for TabBarView
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWhatsAppPricing(context),
                  _buildVoicePricing(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppPricing(BuildContext context) {
    // In a real app, this data would come from the maps in Pricing.tsx
    return ResponsiveLayout(
      mobile: Column(
        children: [
          _buildPriceCard(title: 'Starter', price: _currency == 'INR' ? '₹1,000' : '\$12', description: 'Perfect for small businesses getting started', features: ['1,000 WhatsApp conversations', '1 WhatsApp Channel', 'Basic AI training']),
          const SizedBox(height: 16),
          _buildPriceCard(title: 'Growth', price: _currency == 'INR' ? '₹1,500' : '\$18', description: 'For growing businesses with higher volume', features: ['3,000 WhatsApp conversations', '2 WhatsApp Channels', 'Advanced AI training'], isPopular: true),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPriceCard(title: 'Starter', price: _currency == 'INR' ? '₹1,000' : '\$12', description: 'Perfect for small businesses getting started', features: ['1,000 WhatsApp conversations', '1 WhatsApp Channel', 'Basic AI training'])),
          const SizedBox(width: 16),
          Expanded(child: _buildPriceCard(title: 'Growth', price: _currency == 'INR' ? '₹1,500' : '\$18', description: 'For growing businesses with higher volume', features: ['3,000 WhatsApp conversations', '2 WhatsApp Channels', 'Advanced AI training'], isPopular: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildPriceCard(title: 'Professional', price: _currency == 'INR' ? '₹2,500' : '\$30', description: 'For established businesses scaling up', features: ['5,000 WhatsApp conversations', '3 WhatsApp Channels', 'Custom integrations'])),
        ],
      ),
    );
  }

  Widget _buildVoicePricing(BuildContext context) {
    // In a real app, this data would come from the maps in Pricing.tsx
    return ResponsiveLayout(
      mobile: Column(
        children: [
          _buildPriceCard(title: 'Up to 2L Minutes', price: _currency == 'INR' ? '₹7' : '\$0.08', period: '/min', description: 'HD voice quality', features: ['Up to 200,000 minutes', 'Call recording', 'Basic analytics']),
          const SizedBox(height: 16),
          _buildPriceCard(title: '2L - 5L Minutes', price: _currency == 'INR' ? '₹6' : '\$0.07', period: '/min', description: 'Advanced analytics', features: ['200,000 - 500,000 minutes', 'Priority routing'], isPopular: true),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildPriceCard(title: 'Up to 2L Minutes', price: _currency == 'INR' ? '₹7' : '\$0.08', period: '/min', description: 'HD voice quality', features: ['Up to 200,000 minutes', 'Call recording', 'Basic analytics'])),
          const SizedBox(width: 16),
          Expanded(child: _buildPriceCard(title: '2L - 5L Minutes', price: _currency == 'INR' ? '₹6' : '\$0.07', period: '/min', description: 'Advanced analytics', features: ['200,000 - 500,000 minutes', 'Priority routing'], isPopular: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildPriceCard(title: '5L+ Minutes', price: _currency == 'INR' ? '₹5' : '\$0.06', period: '/min', description: 'Dedicated support', features: ['500,000+ minutes', 'Call transcription', 'Custom integrations'])),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    String period = '/month',
    required String description,
    required List<String> features,
    bool isPopular = false,
  }) {
    return AppCard(
      border: isPopular ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              Text(period, style: const TextStyle(fontSize: 16, color: AppColors.mutedForeground)),
            ],
          ),
          Text(description, style: const TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                const Icon(LucideIcons.check, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(feature),
              ],
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Get Started',
              onPressed: () {},
              variant: isPopular ? AppButtonVariant.primary : AppButtonVariant.outline,
            ),
          ),
        ],
      ),
    );
  }
}