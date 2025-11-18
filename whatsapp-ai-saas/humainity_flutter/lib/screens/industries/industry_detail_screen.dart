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

  /// Helper: build from route extra or id param
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
    // Fallback: This should ideally route to a 404/Error screen, 
    // but for non-crashing behavior, we return the first industry.
    return IndustryDetailScreen(industry: industries.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO Section (Contains the Back button)
            _HeroSection(industry: industry),
            // CHALLENGES Section
            _ChallengesSection(industry: industry),
            // SOLUTIONS Section
            _SolutionsSection(industry: industry),
            // KEY RESULTS Section
            _KeyResultsSection(industry: industry),
            // CONVERSATION FLOW Section
            _ConversationFlowSection(industry: industry),
            // INTEGRATIONS Section
            _IntegrationsSection(industry: industry),
            // FINAL CTA Section
            _FinalCtaSection(industry: industry),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
//          SECTION WIDGETS
// ------------------------------------

class _HeroSection extends StatelessWidget {
  final Industry industry;
  const _HeroSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 60, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFF5F3FF),
          ],
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Icon and Tagline
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(industry.icon,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    industry.tagline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Name and Description
              Text(
                industry.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                industry.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 32),
              // CTA Buttons
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(
                    text: 'Try Now',
                    onPressed: () => context.go('/auth'),
                    isLg: true,
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
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
      color: Colors.grey.shade50, // Added background color for separation
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Industry-Specific Challenges',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Common pain points in the industry that demand automation.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 30),
              // Challenges Grid
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3, // 1 for mobile, 3 for web/tablet
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: isMobile ? 4.0 : 1.5, // Adjusted for better aspect ratio
                ),
                itemCount: industry.challenges.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.xCircle,
                          color: Colors.red.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            industry.challenges[index],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _SolutionsSection extends StatelessWidget {
  final Industry industry;
  const _SolutionsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
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
                'AI Solutions: Tailored for You',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A breakdown of how AI agents solve your specific challenges across different communication channels.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 30),
              // Solutions Tabs/Cards
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

  const _SolutionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.solutions,
  });

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          // Solution List
          ...solutions.map((solution) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.checkCircle2, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solution,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ------------------------------------
//     KEY RESULTS SECTION 
// ------------------------------------
class _KeyResultsSection extends StatelessWidget {
  final Industry industry;
  const _KeyResultsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
                'Key Results and Success Metrics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Proven outcomes businesses achieve using our AI platform.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 30),
              // Key Results Grid
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, 
                ),
                itemCount: industry.results.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final result = industry.results[index];
                  return Container(
                    padding: const EdgeInsets.all(16), 
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100), 
                      boxShadow: [ 
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          result['value'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 36, 
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result['metric'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14, 
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ------------------------------------
//  CONVERSATION FLOW SECTION 
// ------------------------------------
class _ConversationFlowSection extends StatelessWidget {
  final Industry industry;
  const _ConversationFlowSection({required this.industry});

  @override
  Widget build(BuildContext context) {
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
                'AI Conversation Flow Example',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A sample conversation flow showing the AI\'s empathy and intelligence in action.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 30),
              // Conversation Flow Visualizer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: industry.conversationFlow.map((stepData) {
                    final isUserResponse = stepData['response'] != null && stepData['response'] != '';
                    
                    List<Widget> steps = [];

                    // 1. Always display the AI message (the message property)
                    steps.add(_ConversationBubble(
                      text: stepData['message'] as String,
                      isUser: false,
                    ));

                    // 2. If a user response exists, display it immediately after
                    if (isUserResponse) {
                      steps.add(_ConversationBubble(
                        text: stepData['response'] as String,
                        isUser: true,
                      ));
                    }
                    
                    return Column(children: steps);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ConversationBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    // Styling based on AI (Left) or User (Right)
    final bubbleColor = isUser ? const Color(0xFFE5E7EB) : AppColors.primary.withOpacity(0.1);
    final textColor = isUser ? const Color(0xFF4B5563) : AppColors.primary.shade700;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final icon = isUser ? LucideIcons.user : LucideIcons.bot;
    final iconColor = isUser ? const Color(0xFF4B5563) : AppColors.primary;
    final iconBgColor = isUser ? Colors.grey.shade300 : AppColors.primary.withOpacity(0.1);
    
    // Bubble max width constraint to prevent filling the whole screen
    final bubbleMaxConstraint = BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7);

    // Padding for spacing between bubbles
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Constrain Row to content width
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: isUser ? TextDirection.rtl : TextDirection.ltr, // Flips order for User side
          children: [
            // Icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            // Message Bubble
            ConstrainedBox(
              constraints: bubbleMaxConstraint,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(10).copyWith(
                    topLeft: isUser ? const Radius.circular(10) : Radius.zero,
                    topRight: isUser ? Radius.zero : const Radius.circular(10),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  get shade700 => null;
}


// ------------------------------------
//   INTEGRATIONS SECTION 
// ------------------------------------
class _IntegrationsSection extends StatelessWidget {
  final Industry industry;
  const _IntegrationsSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Universal Integration Capabilities',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect seamlessly with your existing systems',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 30),
              // Integrations Wrap (Badges/Chips)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: industry.integrations.map((integration) {
                  return Chip(
                    label: Text(integration),
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Pill shape
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
//       FINAL CTA SECTION
// ------------------------------------
class _FinalCtaSection extends StatelessWidget {
  final Industry industry;
  const _FinalCtaSection({required this.industry});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to Automate ${industry.name}?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Launch an AI-powered agent tailored for your industry today. Join businesses transforming their customer interactions with AI-powered automation that maintains the human touch.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      if (isMobile) const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (!isMobile) const SizedBox(width: 30),
                Flexible(
                  flex: 2,
                  child: AppButton(
                    text: 'Launch Your AI Agent Now',
                    onPressed: () => context.go('/dashboard'),
                    isLg: true,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary, 
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}