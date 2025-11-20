import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:humainity_flutter/widgets/ui/app_card.dart';
import 'package:humainity_flutter/widgets/ui/app_radio_group.dart';
import 'package:humainity_flutter/widgets/ui/app_tabs.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainity_flutter/core/providers/plans_provider.dart';
import 'package:humainity_flutter/models/subscription_plan.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection>
    with SingleTickerProviderStateMixin {
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
              height: 550,
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

  // ---------------------------------------------------------------------------
  // WHATSAPP PRICING – INR dynamic, USD hardcoded
  // ---------------------------------------------------------------------------

  Widget _buildWhatsAppPricing(BuildContext context) {
    final isINR = _currency == 'INR';

    return ResponsiveLayout(
      mobile: isINR
          ? _buildDynamicINRPlans(isDesktop: false)
          : _buildHardcodedWhatsAppUSD(isDesktop: false),
      desktop: isINR
          ? _buildDynamicINRPlans(isDesktop: true)
          : _buildHardcodedWhatsAppUSD(isDesktop: true),
    );
  }

  Widget _buildDynamicINRPlans({required bool isDesktop}) {
    return Consumer(builder: (context, ref, _) {
      final plansAsync = ref.watch(plansProvider);

      return plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            "Failed to load plans: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(child: Text("No plans found."));
          }

          if (!isDesktop) {
            // FIX: Added SingleChildScrollView for vertical overflow on mobile
            return SingleChildScrollView(
              child: Column(
                children: plans
                    .map(
                      (plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPriceCard(
                          title: plan.name,
                          price: "₹${plan.price.toStringAsFixed(0)}",
                          description:
                              "${plan.credits} credits • ${plan.durationDays} days",
                          features: plan.features,
                          isPopular: plan.isPopular,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }

          return Row(
            children: [
              for (int i = 0; i < plans.length; i++) ...[
                Expanded(
                  child: _buildPriceCard(
                    title: plans[i].name,
                    price: "₹${plans[i].price.toStringAsFixed(0)}",
                    description:
                        "${plans[i].credits} credits • ${plans[i].durationDays} days",
                    features: plans[i].features,
                    isPopular: plans[i].isPopular,
                  ),
                ),
                if (i < plans.length - 1) const SizedBox(width: 16),
              ]
            ],
          );
        },
      );
    });
  }

  Widget _buildHardcodedWhatsAppUSD({required bool isDesktop}) {
    if (!isDesktop) {
      // FIX: Added SingleChildScrollView for vertical overflow on mobile
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildPriceCard(
              title: 'Starter',
              price: '\$12',
              description: 'Perfect for small businesses getting started',
              features: [
                '1,000 WhatsApp conversations',
                '1 WhatsApp Channel',
                'Basic AI training'
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceCard(
              title: 'Growth',
              price: '\$18',
              description: 'For growing businesses with higher volume',
              features: [
                '3,000 WhatsApp conversations',
                '2 WhatsApp Channels',
                'Advanced AI training'
              ],
              isPopular: true,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildPriceCard(
            title: 'Starter',
            price: '\$12',
            description: 'Perfect for small businesses getting started',
            features: [
              '1,000 WhatsApp conversations',
              '1 WhatsApp Channel',
              'Basic AI training'
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPriceCard(
            title: 'Growth',
            price: '\$18',
            description: 'For growing businesses with higher volume',
            features: [
              '3,000 WhatsApp conversations',
              '2 WhatsApp Channels',
              'Advanced AI training'
            ],
            isPopular: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPriceCard(
            title: 'Professional',
            price: '\$30',
            description: 'For established businesses scaling up',
            features: [
              '5,000 WhatsApp conversations',
              '3 WhatsApp Channels',
              'Custom integrations'
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoicePricing(BuildContext context) {
    final isINR = _currency == 'INR';

    final setupPrice = isINR ? '₹2,00,000' : '\$2,400';

    final List<_VoiceTier> tiers = isINR
        ? [
            _VoiceTier(
              title: 'Up to 2L Minutes',
              price: '₹7',
              limit: '200,000 minutes',
              estimated: 'Est. ₹14,00,000 at max usage',
              features: [
                '₹7 per minute',
                'Up to 200,000 minutes',
                'HD voice quality',
                'Call recording',
                'Basic analytics',
              ],
            ),
            _VoiceTier(
              title: '2L - 5L Minutes',
              price: '₹6',
              limit: '200,000 - 500,000 minutes',
              estimated: 'Est. ₹30,00,000 at max usage',
              isPopular: true,
              features: [
                '₹6 per minute',
                '200,000 - 500,000 minutes',
                'HD voice quality',
                'Call recording',
                'Advanced analytics',
                'Priority routing',
              ],
            ),
            _VoiceTier(
              title: '5L+ Minutes',
              price: '₹5',
              limit: '500,000+ minutes',
              estimated: 'Est. Custom at max usage',
              features: [
                '₹5 per minute',
                '500,000+ minutes',
                'Premium voice quality',
                'Call recording & transcription',
                'Advanced analytics',
                'Priority routing',
                'Dedicated support',
                'Custom integrations',
              ],
            ),
          ]
        : [
            _VoiceTier(
              title: 'Up to 2L Minutes',
              price: '\$0.08',
              limit: '200,000 minutes',
              estimated: 'Est. \$16,000 at max usage',
              features: [
                '\$0.08 per minute',
                'Up to 200,000 minutes',
                'HD voice quality',
                'Call recording',
                'Basic analytics',
              ],
            ),
            _VoiceTier(
              title: '2L - 5L Minutes',
              price: '\$0.07',
              limit: '200,000 - 500,000 minutes',
              estimated: 'Est. \$35,000 at max usage',
              isPopular: true,
              features: [
                '\$0.07 per minute',
                '200,000 - 500,000 minutes',
                'HD voice quality',
                'Call recording',
                'Advanced analytics',
                'Priority routing',
              ],
            ),
            _VoiceTier(
              title: '5L+ Minutes',
              price: '\$0.06',
              limit: '500,000+ minutes',
              estimated: 'Est. Custom at max usage',
              features: [
                '\$0.06 per minute',
                '500,000+ minutes',
                'Premium voice quality',
                'Call recording & transcription',
                'Advanced analytics',
                'Priority routing',
                'Dedicated support',
                'Custom integrations',
              ],
            ),
          ];

    return Column(
      children: [
        const SizedBox(height: 8),
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

        // One-time setup card
        _buildVoiceSetupCard(setupPrice),
        const SizedBox(height: 24),

        Expanded(
          child: ResponsiveLayout(
            mobile: SingleChildScrollView(
              child: Column(
                children: [
                  for (final tier in tiers) ...[
                    _buildVoiceTierCard(tier),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            desktop: Row(
              children: [
                for (int i = 0; i < tiers.length; i++) ...[
                  Expanded(
                    // Use Expanded to share space equally
                    child: _buildVoiceTierCard(tiers[i]),
                  ),
                  if (i < tiers.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSetupCard(String setupPrice) {
    return AppCard(
      border: Border.all(
        color: AppColors.primary.withOpacity(0.3),
        width: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.phone,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'One-Time Setup & Integration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  setupPrice,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Complete voice automation setup including integration, configuration, and training',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _VoiceSetupPoint('Complete system integration'),
                    _VoiceSetupPoint('Custom workflow setup'),
                    _VoiceSetupPoint('AI voice model training'),
                    _VoiceSetupPoint('Dedicated onboarding support'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTierCard(_VoiceTier tier) {
    return AppCard(
      border: tier.isPopular
          ? Border.all(color: AppColors.primary, width: 2)
          : Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (tier.isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            tier.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                tier.price,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/minute',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tier.limit,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tier.estimated,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.check,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Get Started',
              onPressed: () {},
              style: tier.isPopular
                  ? AppButtonStyle.primary
                  : AppButtonStyle.tertiary,
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
      border: isPopular
          ? Border.all(color: AppColors.primary, width: 2)
          : Border.all(color: AppColors.border),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Text(
                period,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.mutedForeground),
              ),
            ],
          ),
          Text(
            description,
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(LucideIcons.check,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Get Started',
              onPressed: () {},
              style:
                  isPopular ? AppButtonStyle.primary : AppButtonStyle.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceTier {
  final String title;
  final String price;
  final String limit;
  final String estimated;
  final List<String> features;
  final bool isPopular;

  _VoiceTier({
    required this.title,
    required this.price,
    required this.limit,
    required this.estimated,
    required this.features,
    this.isPopular = false,
  });
}

class _VoiceSetupPoint extends StatelessWidget {
  final String text;
  const _VoiceSetupPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          LucideIcons.check,
          size: 14,
          color: AppColors.success,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
