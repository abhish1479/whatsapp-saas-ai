import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static final steps = [
    {
      "icon": LucideIcons.messageSquare,
      "title": "Connect Channels",
      "subtitle": "Link WhatsApp & Voice",
      "detail":
          "Integrate your communication channels in minutes with our seamless setup wizard.",
      "color": Color(0xFF009BFF),
      "step": "01",
      "bg": Color(0xFFE6F4FF),
    },
    {
      "icon": LucideIcons.upload,
      "title": "Train AI",
      "subtitle": "Upload FAQs, Docs, or CRM Data",
      "detail":
          "Feed your business knowledge to create intelligent, context-aware responses.",
      "color": Color(0xFF16A34A),
      "step": "02",
      "bg": Color(0xFFE9FFF3),
    },
    {
      "icon": LucideIcons.shieldCheck,
      "title": "Set Actions & Guardrails",
      "subtitle": "Configure automated responses & safety boundaries",
      "detail":
          "Define triggers, responses, escalation paths, and guardrails to ensure your AI agents stay on-brand, complaint, and within defined boundaries.",
      "color": Color(0xFFFFB800),
      "step": "03",
      "bg": Color(0xFFFFF4E6),
    },
    {
      "icon": LucideIcons.lineChart,
      "title": "Launch & Track",
      "subtitle": "Monitor campaigns, leads, and outcomes",
      "detail":
          "View real-time analytics and insights in one unified dashboard.",
      "color": Color(0xFFE11D48),
      "step": "04",
      "bg": Color(0xFFFFECEE),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 16),
      child: Stack(
        children: [
          if (!isMobile)
            Positioned(
              top: 340,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 3,
                  width: 850,
                  color: const Color(0xFFFFE9C2),
                ),
              ),
            ),
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "How It ",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: "Works",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF009BFF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Get started in 4 simple steps and transform your customer engagement",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5C6B7A),
                ),
              ),

              const SizedBox(height: 64),

              // ---- CARDS ----
              if (isMobile)
                Column(
                  children: steps
                      .map((step) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _HoverCard(step: step),
                          ))
                      .toList(),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < steps.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 16,
                          right: i == steps.length - 1 ? 0 : 16,
                        ),
                        child: _HoverCard(step: steps[i]),
                      ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Map<String, dynamic> step;

  const _HoverCard({required this.step});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.step["color"];
    final bg = widget.step["bg"];

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 280,
        height: 380,
        transform: hovering
            ? (Matrix4.identity()..translate(0.0, -5.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: hovering ? const Color(0xFF009BFF) : const Color(0xFFE7EEF7),
            width: 2,
          ),
          boxShadow: hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: AppCard(
          borderRadius: 15,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Stack(
            children: [
              Positioned(
                right: 7,
                child: Text(
                  widget.step["step"].toString(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF009BFF).withOpacity(0.09),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(widget.step["icon"], size: 38, color: color),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.step["title"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.step["subtitle"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.step["detail"],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C6B7A),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
