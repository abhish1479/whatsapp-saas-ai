import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/hover_card.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/reveal_on_scroll.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPreviewSection extends StatelessWidget {
  const DashboardPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ---------------- TITLE ----------------
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "See the ",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Impact",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF009BFF),
                      ),
                    ),
                    TextSpan(
                      text: " of Every Conversation",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Monitor, analyze, and optimize your customer engagement in real-time",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5C6B7A),
                ),
              ),
              const SizedBox(height: 48),

              /// ---------------- TOP CARDS ROW ----------------
              LayoutBuilder(
                builder: (context, constraints) {
                  if (mobile) {
                    return const Column(
                      children: [
                        _CampaignPerformanceCard(),
                        SizedBox(height: 20),
                        _TodaysActivityCard(),
                      ],
                    );
                  }

                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6, // 60%
                        child: _CampaignPerformanceCard(),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 4, // 40%
                        child: _TodaysActivityCard(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              /// ---------------- CONNECTED INTEGRATIONS ----------------
              const _ConnectedIntegrationsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================================================================
/// LEFT CARD – CAMPAIGN PERFORMANCE
/// ======================================================================

/// ======================================================================
/// LEFT CARD – CAMPAIGN PERFORMANCE
/// ======================================================================

class _CampaignPerformanceCard extends StatelessWidget {
  const _CampaignPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if it's a mobile layout
    final mobile = Responsive.isMobile(context);

    return RevealOnScroll(
      child: HoverCard(
        hoverTranslateY: -4,
        hoverElevation: 16,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EDF7), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header row
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Campaign Performance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FFF0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFF22C55E),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Live",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Metrics arrangement: Row for non-mobile, Column for mobile
              mobile
                  ? const Column(
                      children: [
                        _MetricTile(
                          label: "Sent",
                          value: "12,450",
                          footer: "+18% vs last week",
                          icon: LucideIcons.messageSquare,
                          gradient: LinearGradient(
                            colors: [Color(0xFFE6F2FF), Color(0xFFF1F7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          accentColor: Color(0xFF009BFF),
                          valueColor: Color(0xFF009BFF),
                        ),
                        SizedBox(height: 12),
                        _MetricTile(
                          label: "Responded",
                          value: "8,932",
                          footer: "72% response rate",
                          icon: LucideIcons.checkCircle2,
                          gradient: LinearGradient(
                            colors: [Color(0xFFE7FFF4), Color(0xFFF1FFF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          accentColor: Color(0xFF059669),
                          valueColor: Color(0xFF059669),
                        ),
                        SizedBox(height: 12),
                        _MetricTile(
                          label: "Converted",
                          value: "2,156",
                          footer: "24% conversion",
                          icon: LucideIcons.target,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFF2E4), Color(0xFFFFF8ED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          accentColor: Color(0xFFF97316),
                          valueColor: Color(0xFFF97316),
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: "Sent",
                            value: "12,450",
                            footer: "+18% vs last week",
                            icon: LucideIcons.messageSquare,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE6F2FF), Color(0xFFF1F7FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            accentColor: Color(0xFF009BFF),
                            valueColor: Color(0xFF009BFF),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(
                            label: "Responded",
                            value: "8,932",
                            footer: "72% response rate",
                            icon: LucideIcons.checkCircle2,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE7FFF4), Color(0xFFF1FFF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            accentColor: Color(0xFF059669),
                            valueColor: Color(0xFF059669),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(
                            label: "Converted",
                            value: "2,156",
                            footer: "24% conversion",
                            icon: LucideIcons.target,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFF2E4), Color(0xFFFFF8ED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            accentColor: Color(0xFFF97316),
                            valueColor: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 24),

              /// Campaign list rows
              const _CampaignRow(
                icon: LucideIcons.messageSquare,
                iconBgColor: Color(0xFFE5F4FF),
                iconColor: Color(0xFF009BFF),
                title: "Summer Sale Campaign",
                subtitle: "WhatsApp • 3,245 sent",
                statusLabel: "Active",
                statusColor: Color(0xFF16A34A),
              ),
              const _CampaignRow(
                icon: LucideIcons.phone,
                iconBgColor: Color(0xFFFFF3E8),
                iconColor: Color(0xFFF59E0B),
                title: "Follow-up Calls",
                subtitle: "Voice • 1,892 completed",
                statusLabel: "Active",
                statusColor: Color(0xFF16A34A),
              ),
              const _CampaignRow(
                icon: LucideIcons.users2,
                iconBgColor: Color(0xFFF3F4F6),
                iconColor: Color(0xFF6B7280),
                title: "Customer Feedback",
                subtitle: "WhatsApp • 5,678 sent",
                statusLabel: "Completed",
                statusColor: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String footer;
  final IconData icon;
  final Gradient gradient;
  final Color accentColor;
  final Color valueColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.footer,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // enough height to avoid overflow
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 14,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                footer,
                style: TextStyle(
                  fontSize: 13,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;

  const _CampaignRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================================
/// RIGHT CARD – TODAY'S ACTIVITY
/// ======================================================================

class _TodaysActivityCard extends StatelessWidget {
  const _TodaysActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: HoverCard(
        hoverTranslateY: -4,
        hoverElevation: 16,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EDF7), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              /// Total conversations
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Conversations",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    "1,847",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF009BFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  value: 0.78,
                  minHeight: 6,
                  color: Color(0xFF009BFF),
                  backgroundColor: Color(0xFFE5F2FF),
                ),
              ),

              const SizedBox(height: 20),

              const _ActivityRow(
                icon: LucideIcons.messageSquare,
                iconColor: Color(0xFF009BFF),
                label: "WhatsApp Messages",
                value: "1,234",
              ),
              const _ActivityRow(
                icon: LucideIcons.phone,
                iconColor: Color(0xFF22C55E),
                label: "Voice Calls",
                value: "613",
              ),
              const _ActivityRow(
                icon: LucideIcons.timer,
                iconColor: Color(0xFFF97316),
                label: "Avg. Response Time",
                value: "12s",
              ),

              const SizedBox(height: 24),
              Container(height: 1, color: const Color(0xFFE5EDF7)),
              const SizedBox(height: 18),

              const Text(
                "Conversion Funnel",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              const _FunnelBar(
                  label: "Opened", value: 1.0, percentLabel: "100%"),
              const _FunnelBar(
                  label: "Replied", value: 0.72, percentLabel: "72%"),
              const _FunnelBar(
                  label: "Converted", value: 0.24, percentLabel: "24%"),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelBar extends StatelessWidget {
  final String label;
  final double value;
  final String percentLabel;

  const _FunnelBar({
    required this.label,
    required this.value,
    required this.percentLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (label == "Opened") {
      barColor = const Color(0xFF009BFF);
    } else if (label == "Replied") {
      barColor = const Color(0xFF22C55E);
    } else {
      barColor = const Color(0xFFF97316);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                color: barColor,
                backgroundColor: const Color(0xFFE5F2FF),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              percentLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================================
/// CONNECTED INTEGRATIONS CARD
/// ======================================================================

class _ConnectedIntegrationsCard extends StatelessWidget {
  const _ConnectedIntegrationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = [
      "WhatsApp Business",
      "Voice API",
      "Salesforce CRM",
      "Payment Gateway",
      "Google Calendar",
      "Email Marketing",
      "Analytics",
      "Custom ERP",
    ];

    return RevealOnScroll(
      child: HoverCard(
        hoverTranslateY: -2,
        hoverElevation: 10,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5EDF7), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Connected Integrations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: chips
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.circle,
                              size: 8,
                              color: Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
