import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/hover_card.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/reveal_on_scroll.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  static final _data = [
    const _Testimonial(
      quote:
          "HumAInity.ai transformed how we handle customer support. Our response time dropped from hours to minutes, and customer satisfaction increased by 45%.",
      name: "Rajesh Kumar",
      title: "CEO, TechStart Solutions",
      avatar: "assets/images/agent-david.jpg",
    ),
    const _Testimonial(
      quote:
          "The WhatsApp automation is incredible. We're now reaching 10x more students with personalized messages, and our enrollment rate has skyrocketed.",
      name: "Priya Sharma",
      title: "Marketing Director, EduLearn",
      avatar: "assets/images/agent-maya.jpg",
    ),
    const _Testimonial(
      quote:
          "Setting up was so easy! Within days, we had an AI agent handling appointment bookings and patient queries. It's like having a 24/7 team member.",
      name: "Amit Patel",
      title: "Founder, HealthCare Plus",
      avatar: "assets/images/agent-alex.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Trusted by ",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "SMBs Nationwide",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0BA5EC),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "See how businesses like yours are growing with HumAInity.ai",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5C6B7A),
                ),
              ),

              const SizedBox(height: 64),

              // ------------------------------ Layout
              isMobile
                  ? Column(
                      children: _data
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _TestimonialCard(data: t),
                              ))
                          .toList(),
                    )
                  : Row(
                      children: [
                        for (int i = 0; i < _data.length; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : 16,
                                right: i == _data.length - 1 ? 0 : 16,
                              ),
                              child: _TestimonialCard(data: _data[i]),
                            ),
                          ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// DATA MODEL
// =====================================================================

class _Testimonial {
  final String quote;
  final String name;
  final String title;
  final String avatar;

  const _Testimonial({
    required this.quote,
    required this.name,
    required this.title,
    required this.avatar,
  });
}

class _TestimonialCard extends StatefulWidget {
  final _Testimonial data;

  const _TestimonialCard({required this.data});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: MouseRegion(
        onEnter: (_) => setState(() => hovering = true),
        onExit: (_) => setState(() => hovering = false),
        child: HoverCard(
          hoverTranslateY: -6,
          hoverElevation: 16,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hovering
                    ? const Color(0xFF0BA5EC)
                    : const Color(0xFFE5EDF7),
                width: 2,
              ),
              boxShadow: hovering
                  ? [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.star_rounded,
                        color: Color(0xFF0BA5EC),
                        size: 30,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Quote
                Text(
                  '"${widget.data.quote}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Container(height: 1, color: const Color(0xFFE5EDF7)),
                const SizedBox(height: 20),

                // --- Avatar + Name + Title
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(widget.data.avatar),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.data.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
