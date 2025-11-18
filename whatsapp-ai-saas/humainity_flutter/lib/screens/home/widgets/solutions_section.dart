import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/hover_card.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/reveal_on_scroll.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SolutionsSection extends StatelessWidget {
  const SolutionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = !isMobile && !isTablet;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // ------------------ TITLE ------------------
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Comprehensive ",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: "Solutions",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF009BFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "From support to sales, we've got you covered with AI-powered automation",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5C6B7A),
                ),
              ),
              const SizedBox(height: 48),

              // ------------------ CARDS ------------------
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop) {
                    // Desktop -> row with equal height
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _SolutionCard.support(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _SolutionCard.sales(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Tablet / Mobile -> stacked, natural height
                    return Column(
                      children: [
                        _SolutionCard.support(),
                        const SizedBox(height: 16),
                        _SolutionCard.sales(),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 18),
              const Text(
                "Automate Support. Accelerate Sales.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E7A6E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// INTERNAL CARD WIDGET
// ----------------------------------------------------------------------

class _SolutionCard extends StatelessWidget {
  final Color accentColor;
  final IconData headerIcon;
  final String avatarAsset;
  final String title;
  final String subtitle;
  final List<_BulletItem> bullets;
  final List<_MetricItem> metrics;
  final String ctaText;
  final Color ctaColor;

  const _SolutionCard._({
    required this.accentColor,
    required this.headerIcon,
    required this.avatarAsset,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.metrics,
    required this.ctaText,
    required this.ctaColor,
    super.key,
  });

  /// Left card: Customer Support Automation
   _SolutionCard.support({Key? key})
      : this._(
          key: key,
          accentColor: const Color(0xFF009BFF),
          headerIcon: LucideIcons.headphones,
          avatarAsset: "assets/images/agent-sarah.jpg",
          title: "Customer Support Automation",
          subtitle:
              "Deliver instant, intelligent support that scales with your business — powered by AI agents like Sarah",
          bullets: [
            const _BulletItem(
              text: "Smart ticketing and instant FAQ handling",
              icon: LucideIcons.messageSquare,
              bgColor: Color(0xFFE6F3FF),
              iconColor: Color(0xFF009BFF),
            ),
            const _BulletItem(
              text: "RAG-based responses from uploaded documents & policies",
              icon: LucideIcons.fileText,
              bgColor: Color(0xFFE6F3FF),
              iconColor: Color(0xFF009BFF),
            ),
            const _BulletItem(
              text: "Escalation logic and contextual voice fallback",
              icon: LucideIcons.headphones,
              bgColor: Color(0xFFE6F3FF),
              iconColor: Color(0xFF009BFF),
            ),
            const _BulletItem(
              text: "Integration with CRM and Helpdesk tools",
              icon: LucideIcons.users,
              bgColor: Color(0xFFE6F3FF),
              iconColor: Color(0xFF009BFF),
            ),
          ],
          metrics: [
            const _MetricItem(
              label: "Avg. Resolution Time",
              value: "-75%",
            ),
            const _MetricItem(
              label: "Customer Satisfaction",
              value: "+60%",
            ),
          ],
          ctaText: "Explore Support Solutions",
          ctaColor: const Color(0xFF009BFF),
        );

   _SolutionCard.sales({Key? key})
      : this._(
          key: key,
          accentColor: const Color(0xFF16A34A),
          headerIcon: LucideIcons.trendingUp,
          avatarAsset: "assets/images/agent-alex.jpg",
          title: "Sales Outreach & Campaigns",
          subtitle:
              "Accelerate revenue with intelligent, personalized outreach at scale — powered by AI WhatsApp and Voice Agents for both Inbound and Outbound channels, like Alex",
          bullets: [
            const _BulletItem(
              text:
                  "WhatsApp and Voice campaigns with retry & personalization",
              icon: LucideIcons.messageCircle,
              bgColor: Color(0xFFE8FDF1),
              iconColor: Color(0xFF16A34A),
            ),
            const _BulletItem(
              text: "Dynamic templates for promotions & follow-ups",
              icon: LucideIcons.fileSpreadsheet,
              bgColor: Color(0xFFE8FDF1),
              iconColor: Color(0xFF16A34A),
            ),
            const _BulletItem(
              text: "Real-time analytics: Open rate, Response rate, Conversion",
              icon: LucideIcons.barChart3,
              bgColor: Color(0xFFE8FDF1),
              iconColor: Color(0xFF16A34A),
            ),
            const _BulletItem(
              text: "Payment and appointment workflow triggers",
              icon: LucideIcons.calendarClock,
              bgColor: Color(0xFFE8FDF1),
              iconColor: Color(0xFF16A34A),
            ),
          ],
          metrics: [
            const _MetricItem(
              label: "Campaign Response Rate",
              value: "+45%",
            ),
            const _MetricItem(
              label: "Sales Cycle Time",
              value: "-40%",
            ),
          ],
          ctaText: "Explore Sales Solutions",
          ctaColor: const Color(0xFF16A34A),
        );

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EEF7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header icon + avatar
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(headerIcon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(avatarAsset),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15.5,
              color: Color(0xFF53667A),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Bullets
          Column(
            children: bullets.map((b) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: b.bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        b.icon,
                        size: 18,
                        color: b.iconColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        b.text,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374955),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE7EEF7),
          ),
          const SizedBox(height: 16),

          // Metrics block
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE7EEF7)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              children: metrics.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          m.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF5C6B7A),
                          ),
                        ),
                      ),
                      Text(
                        m.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // CTA
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: ctaColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  ctaText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return RevealOnScroll(
      child: HoverCard(
        hoverTranslateY: -6,
        hoverElevation: 18,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      ),
    );
  }
}


class _BulletItem {
  final String text;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _BulletItem({
    required this.text,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class _MetricItem {
  final String label;
  final String value;

  const _MetricItem({
    required this.label,
    required this.value,
  });
}
