import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/data/industries_data.dart';
import 'package:humainity_flutter/data/industry_model.dart';
import 'package:humainity_flutter/screens/home/widgets/footer.dart';
import 'package:humainity_flutter/screens/home/widgets/navigation.dart';
import 'package:humainity_flutter/widgets/ui/app_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Extension to handle dynamic color shades safely
extension ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}

Industry? getIndustryById(String id) {
  try {
    return industries.firstWhere((i) => i.id == id);
  } catch (e) {
    return null;
  }
}

class IndustryDetailScreen extends StatelessWidget {
  final Industry industry;

  const IndustryDetailScreen({
    super.key,
    required this.industry,
  });

  factory IndustryDetailScreen.fromRoute(BuildContext context, GoRouterState s) {
    final extra = s.extra;
    if (extra is Industry) {
      return IndustryDetailScreen(industry: extra);
    }
    final id = s.pathParameters['id'] ?? '';
    final found = getIndustryById(id);
    if (found != null) {
      return IndustryDetailScreen(industry: found);
    }
    return IndustryDetailScreen(industry: industries.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(industry: industry),
            _ChallengesSection(industry: industry),
            _SolutionsSection(industry: industry),
            _KeyResultsSection(industry: industry),
            _ConversationFlowSection(industry: industry),
            _IntegrationsSection(industry: industry),
            _FinalCtaSection(industry: industry),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
//          HERO SECTION
// ------------------------------------
class _HeroSection extends StatelessWidget {
  final Industry industry;
  const _HeroSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 60, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFF5F3FF)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/industries'),
                  icon: const Icon(LucideIcons.arrowLeft, size: 18, color: Color(0xFF4B5563)),
                  label: const Text(
                    'Back to Industries',
                    style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // FIXED: Added Expanded to prevent tagline overflow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(industry.icon, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      industry.tagline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                industry.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 36 : 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                industry.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 32),
              const AppButton(
                text: 'Try Now',
                // onPressed: () => context.go('/auth'),
                isLg: true,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------
//      CHALLENGES SECTION
// ------------------------------------
class _ChallengesSection extends StatelessWidget {
  final Industry industry;
  const _ChallengesSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey.shade50,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Industry-Specific Challenges',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 30),
              // FIXED: Switched to Wrap to avoid GridView fixed-height overflow
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: industry.challenges.map((challenge) {
                  return Container(
                    width: isMobile ? double.infinity : 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.xCircle, color: Colors.red.shade600, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          challenge,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------
//      SOLUTIONS SECTION
// ------------------------------------
class _SolutionsSection extends StatelessWidget {
  final Industry industry;
  const _SolutionsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Solutions: Tailored for You',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _SolutionCard(
                    title: 'WhatsApp Automation',
                    icon: LucideIcons.messageSquare,
                    color: Colors.green,
                    solutions: industry.solutions['whatsapp'] ?? [],
                  ),
                  _SolutionCard(
                    title: 'Voice Automation',
                    icon: LucideIcons.phone,
                    color: Colors.blue,
                    solutions: industry.solutions['voice'] ?? [],
                  ),
                  _SolutionCard(
                    title: 'Outbound Campaigns',
                    icon: LucideIcons.megaphone,
                    color: Colors.deepOrange,
                    solutions: industry.solutions['campaigns'] ?? [],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> solutions;

  const _SolutionCard({required this.title, required this.icon, required this.color, required this.solutions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context) ? double.infinity : 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...solutions.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.checkCircle2, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

// ------------------------------------
//      KEY RESULTS SECTION
// ------------------------------------
class _KeyResultsSection extends StatelessWidget {
  final Industry industry;
  const _KeyResultsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: industry.results.map((result) {
              return Container(
                width: isMobile ? (MediaQuery.of(context).size.width / 2) - 36 : 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      result['value'] ?? '',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result['metric'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------
//      CONVERSATION FLOW SECTION
// ------------------------------------
class _ConversationFlowSection extends StatelessWidget {
  final Industry industry;
  const _ConversationFlowSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              const Text(
                'AI Conversation Flow',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              ...industry.conversationFlow.map((step) => Column(
                children: [
                  _Bubble(text: step['message']!, isUser: false),
                  if (step['response'] != null && step['response'] != '')
                    _Bubble(text: step['response']!, isUser: true),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE5E7EB) : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12).copyWith(
            topLeft: isUser ? const Radius.circular(12) : Radius.zero,
            topRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.black87 : AppColors.primary.shade700),
        ),
      ),
    );
  }
}

// ------------------------------------
//      INTEGRATIONS SECTION
// ------------------------------------
class _IntegrationsSection extends StatelessWidget {
  final Industry industry;
  const _IntegrationsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: industry.integrations.map((i) => Chip(
            label: Text(i),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade200),
          )).toList(),
        ),
      ),
    );
  }
}

// ------------------------------------
//      FINAL CTA SECTION
// ------------------------------------
class _FinalCtaSection extends StatelessWidget {
  final Industry industry;
  const _FinalCtaSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1024),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                'Ready to Automate ${industry.name}?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Join businesses scaling with AI-powered automation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              // FIXED: Ensuring button text doesn't overflow on small devices
              SizedBox(
                width: isMobile ? double.infinity : null,
                child: const AppButton(
                  text: 'Launch Your AI Agent Now',
                  // onPressed: () => context.go('/dashboard'),
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                  isLg: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}