import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/hover_card.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/reveal_on_scroll.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WhyHumainitySection extends StatelessWidget {
  const WhyHumainitySection({super.key});

  static const _items = [
    {
      "icon": LucideIcons.bot,
      "title": "Conversational AI",
      "desc":
          "Handles FAQs, service requests, and lead nurturing naturally with context-aware responses.",
      "color": Color(0xFF009BFF),
      "bg": Color(0xFFE6F3FF),
    },
    {
      "icon": LucideIcons.messageSquare,
      "title": "Voice + WhatsApp Integration",
      "desc":
          "Unified dashboard for inbound and outbound interactions across all your communication channels.",
      "color": Color(0xFF23C96B),
      "bg": Color(0xFFE8FDF1),
    },
    {
      "icon": LucideIcons.link2,
      "title": "Universal Integrator Layer",
      "desc":
          "Connects with any CRM, ERP, or payment system through natural-language API configuration.",
      "color": Color(0xFFFFB547),
      "bg": Color(0xFFFFF6E5),
    },
    {
      "icon": LucideIcons.heart,
      "title": "Human + AI Synergy",
      "desc":
          "Your agents focus on empathy while AI handles efficiency, creating the perfect balance.",
      "color": Color(0xFFFF5C5C),
      "bg": Color(0xFFFFE9EB),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFF),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Heading
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Why ",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: "HumAInity.AI",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF009BFF),
                      ),
                    ),
                    TextSpan(
                      text: "?",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Empower your business with Conversational AI that supports, sells, and connects —\n"
                "24×7, across WhatsApp, Voice, and every channel your customers use.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5C5C5C),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 64),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth < 1000;

                  final cardWidth = isMobile
                      ? double.infinity
                      : isTablet
                          ? (constraints.maxWidth / 2) - 24
                          : (constraints.maxWidth / 4) - 24;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: _items.map((item) {
                      final color = item["color"] as Color;
                      final bg = item["bg"] as Color;
                      final icon = item["icon"] as IconData;
                      final title = item["title"] as String;
                      final desc = item["desc"] as String;

                      return RevealOnScroll(
                        child: HoverCard(
                          hoverTranslateY: -6,
                          hoverElevation: 14,
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: cardWidth,
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: color, size: 28),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    desc,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      color: Color(0xFF4A4A4A),
                                      height: 1.55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
