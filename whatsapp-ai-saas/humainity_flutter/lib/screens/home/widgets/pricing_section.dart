import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  double _tabViewHeight = 600;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Initial height check
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleTabChange());
  }

  void _handleTabChange() {
    if (!mounted) return;
    final bool isMobile = Responsive.isMobile(context);
    double newHeight;

    if (_tabController.index == 0) {
      // WhatsApp Tab: 3 cards. Stacked on mobile, side-by-side on desktop.
      newHeight = isMobile ? 1650.0 : 620.0;
    } else {
      // Voice Tab: Setup card + 3 tier cards.
      newHeight = isMobile ? 2200.0 : 1050.0;
    }

    if (_tabViewHeight != newHeight) {
      setState(() {
        _tabViewHeight = newHeight;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Container(
      color: AppColors.muted.withOpacity(0.3),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 96, 
        horizontal: 16
      ),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'Simple, Transparent Pricing',
              style: TextStyle(
                fontSize: isMobile ? 32 : 40, 
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pay-per-usage pricing model. Choose what works best for your business.',
              style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppRadioGroup<String>(
              groupValue: _currency,
              onChanged: (val) {
                setState(() => _currency = val!);
                _handleTabChange();
              },
              items: const [
                AppRadioItem(label: Text('INR (₹)'), value: 'INR'),
                AppRadioItem(label: Text('USD (\$)'), value: 'USD'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: isMobile ? double.infinity : 450,
              child: AppTabs(
                controller: _tabController,
                tabs: const [
                  AppTab(text: 'WhatsApp Automation'),
                  AppTab(text: 'Voice Automation'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _tabViewHeight,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
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

  // ---------------------------------------------------------------------------
  // WHATSAPP PRICING
  // ---------------------------------------------------------------------------

  Widget _buildWhatsAppPricing(BuildContext context) {
    final isINR = _currency == 'INR';
    final isDesktop = !Responsive.isMobile(context);

    // Future use: _buildDynamicINRPlans(isDesktop: isDesktop)
    return isINR
        ? _buildHardcodedWhatsAppINR(isDesktop: isDesktop)
        : _buildHardcodedWhatsAppUSD(isDesktop: isDesktop);
  }

  // PRESERVED COMMENTED CODE FOR FUTURE USE
  /*
  Widget _buildDynamicINRPlans({required bool isDesktop}) {
    return Consumer(builder: (context, ref, _) {
      final plansAsync = ref.watch(plansProvider);

      return plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Failed to load plans: $err")),
        data: (plans) {
          if (plans.isEmpty) return const Center(child: Text("No plans found."));

          return Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: plans.map((plan) => SizedBox(
              width: isDesktop ? 340 : double.infinity,
              height: 550,
              child: _buildPriceCard(
                title: plan.name,
                price: "₹${plan.price.toStringAsFixed(0)}",
                description: "${plan.credits} credits • ${plan.durationDays} days",
                features: plan.features,
                isPopular: plan.isPopular,
              ),
            )).toList(),
          );
        },
      );
    });
  }
  */

  Widget _buildHardcodedWhatsAppINR({required bool isDesktop}) {
    final plans = [
      _WhatsAppPlan(
        title: 'Starter', price: '₹999',
        description: 'Perfect for small businesses getting started',
        features: ['1,000 WhatsApp conversations', '1 WhatsApp Channel', 'Basic AI training'],
      ),
      _WhatsAppPlan(
        title: 'Growth', price: '₹1,499',
        description: 'For growing businesses with higher volume',
        features: ['3,000 WhatsApp conversations', '2 WhatsApp Channels', 'Advanced AI training'],
        isPopular: true,
      ),
      _WhatsAppPlan(
        title: 'Professional', price: '₹2,499',
        description: 'For established businesses scaling up',
        features: ['5,000 WhatsApp conversations', '3 WhatsApp Channels', 'Custom integrations'],
      ),
    ];

    return _buildPlanWrap(plans, isDesktop);
  }

  Widget _buildHardcodedWhatsAppUSD({required bool isDesktop}) {
    final plans = [
      _WhatsAppPlan(
        title: 'Starter', price: '\$12',
        description: 'Perfect for small businesses getting started',
        features: ['1,000 WhatsApp conversations', '1 WhatsApp Channel', 'Basic AI training'],
      ),
      _WhatsAppPlan(
        title: 'Growth', price: '\$18',
        description: 'For growing businesses with higher volume',
        features: ['3,000 WhatsApp conversations', '2 WhatsApp Channels', 'Advanced AI training'],
        isPopular: true,
      ),
      _WhatsAppPlan(
        title: 'Professional', price: '\$30',
        description: 'For established businesses scaling up',
        features: ['5,000 WhatsApp conversations', '3 WhatsApp Channels', 'Custom integrations'],
      ),
    ];

    return _buildPlanWrap(plans, isDesktop);
  }

  Widget _buildPlanWrap(List<_WhatsAppPlan> plans, bool isDesktop) {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: plans.map((plan) => SizedBox(
          width: isDesktop ? 340 : double.infinity,
          height: 520,
          child: _buildPriceCard(
            title: plan.title,
            price: plan.price,
            description: plan.description,
            features: plan.features,
            isPopular: plan.isPopular,
          ),
        )).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VOICE PRICING
  // ---------------------------------------------------------------------------

  Widget _buildVoicePricing(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isINR = _currency == 'INR';
    final setupPrice = isINR ? '₹2,00,000' : '\$2,400';
    final tiers = _getVoiceTiers(isINR);

    return Column(
      children: [
        const Text(
          'Voice Automation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Per-minute pricing with one-time setup',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 24),
        _buildVoiceSetupCard(setupPrice, isMobile),
        const SizedBox(height: 32),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: tiers.map((tier) => SizedBox(
            width: isMobile ? double.infinity : 340,
            height: 520,
            child: _buildVoiceTierCard(tier),
          )).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildVoiceSetupCard(String setupPrice, bool isMobile) {
    return AppCard(
      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      padding: const EdgeInsets.all(24),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.phone, color: AppColors.primary, size: 32),
          ),
          SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 16 : 0),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                const Text('One-Time Setup & Integration', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(setupPrice, 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(
                  'Complete voice automation setup including integration and AI training',
                  style: const TextStyle(color: AppColors.mutedForeground),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12, runSpacing: 8,
                  alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
                  children: const [
                    _VoiceSetupPoint('Integration'),
                    _VoiceSetupPoint('Workflow Setup'),
                    _VoiceSetupPoint('AI Training'),
                    _VoiceSetupPoint('Onboarding'),
                  ],
                ),
              ],
            ),
          ),
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
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.check, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Get Started',
              onPressed: () {},
              style: isPopular ? AppButtonStyle.primary : AppButtonStyle.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTierCard(_VoiceTier tier) {
    return AppCard(
      border: tier.isPopular ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (tier.isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
              child: const Text('Most Popular', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
          ],
          Text(tier.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(tier.price, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const Text('/minute', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 4),
          Text(tier.limit, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...tier.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.check, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Get Started',
              onPressed: () {},
              style: tier.isPopular ? AppButtonStyle.primary : AppButtonStyle.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  List<_VoiceTier> _getVoiceTiers(bool isINR) {
    return isINR
        ? [
            _VoiceTier(title: 'Up to 2L Minutes', price: '₹7', limit: '200,000 minutes', features: ['HD voice quality', 'Call recording', 'Basic analytics']),
            _VoiceTier(title: '2L - 5L Minutes', price: '₹6', limit: '200-500k minutes', features: ['Advanced analytics', 'Priority routing'], isPopular: true),
            _VoiceTier(title: '5L+ Minutes', price: '₹5', limit: '500,000+ minutes', features: ['Premium quality', 'Dedicated support', 'Custom integrations']),
          ]
        : [
            _VoiceTier(title: 'Up to 2L Minutes', price: '\$0.08', limit: '200,000 minutes', features: ['HD voice quality', 'Call recording', 'Basic analytics']),
            _VoiceTier(title: '2L - 5L Minutes', price: '\$0.07', limit: '200-500k minutes', features: ['Advanced analytics', 'Priority routing'], isPopular: true),
            _VoiceTier(title: '5L+ Minutes', price: '\$0.06', limit: '500,000+ minutes', features: ['Premium quality', 'Dedicated support', 'Custom integrations']),
          ];
  }
}

// ---------------------------------------------------------------------------
// DATA CLASSES
// ---------------------------------------------------------------------------

class _WhatsAppPlan {
  final String title, price, description;
  final List<String> features;
  final bool isPopular;
  _WhatsAppPlan({required this.title, required this.price, required this.description, required this.features, this.isPopular = false});
}

class _VoiceTier {
  final String title, price, limit;
  final List<String> features;
  final bool isPopular;
  _VoiceTier({required this.title, required this.price, required this.limit, required this.features, this.isPopular = false});
}

class _VoiceSetupPoint extends StatelessWidget {
  final String text;
  const _VoiceSetupPoint(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.check, size: 14, color: AppColors.success),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}