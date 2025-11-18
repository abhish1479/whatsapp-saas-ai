import 'package:flutter/material.dart';
// Assuming these are custom widgets you still need
import 'package:humainity_flutter/screens/home/widgets/interactive/hover_card.dart';
import 'package:humainity_flutter/screens/home/widgets/interactive/reveal_on_scroll.dart';

class MeetAgentsSection extends StatelessWidget {
  const MeetAgentsSection({super.key});

  // Helper method to dynamically set the title font size based on screen width
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 36; // Mobile font size
    }
    return 48; // Desktop/Tablet font size
  }

  @override
  Widget build(BuildContext context) {
    final titleFontSize = _getTitleFontSize(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              // ---------- Top Badge ----------
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 16,
                      color: Color(0xFF0286E0),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "AI-Powered Team",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0286E0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------- Title (Responsive) ----------
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Meet Your ",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: "AI Agents",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF009BFF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ---------- Sub-Heading (Max Width) ----------
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: const Text(
                  "Every agent is trained on your business knowledge, working 24/7 to support and sell for you",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF5C6B7A),
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ---------- 4 Agent Cards (Wrapped in LayoutBuilder for max width) ----------
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate width for single card on mobile (Total width - horizontal spacing)
                  final singleCardWidth = constraints.maxWidth;

                  // Use a dynamic card width that allows the cards to either stack or sit side-by-side
                  // When constraints.maxWidth is small (mobile), cardMaxWidth will be small.
                  // When constraints.maxWidth is large (desktop), cardMaxWidth defaults to 260.
                  final cardMaxWidth =
                      constraints.maxWidth < 540 // (260*2 + 22 spacing) approx
                          ? singleCardWidth
                          : 260.0; // Use original fixed width on larger screens

                  return Wrap(
                    spacing: 22,
                    runSpacing: 22,
                    alignment: WrapAlignment.center,
                    children: [
                      AgentCard(
                        cardWidth: cardMaxWidth, // Pass the calculated width
                        name: "Sarah",
                        role: "Customer Support Specialist",
                        department: "Support",
                        description:
                            "Handles queries, complaints, and FAQs with empathy",
                        avatar: "assets/images/agent-sarah.jpg",
                        stats: {
                          "Resolved": "2.4K",
                          "Satisfaction": "98%",
                          "Response Time": "12s",
                        },
                        badgeColor: Color(0xFF009BFF),
                        badgeIcon: Icons.message_rounded,
                      ),
                      AgentCard(
                        cardWidth: cardMaxWidth, // Pass the calculated width
                        name: "Alex",
                        role: "Sales Outreach Expert",
                        department: "Sales",
                        description:
                            "Nurtures leads and converts prospects 24/7",
                        avatar: "assets/images/agent-alex.jpg",
                        stats: {
                          "Calls": "1.8K",
                          "Conversion": "34%",
                          "Follow Ups": "892",
                        },
                        badgeColor: Color(0xFF16A34A),
                        badgeIcon: Icons.call_rounded,
                      ),
                      AgentCard(
                        cardWidth: cardMaxWidth, // Pass the calculated width
                        name: "Maya",
                        role: "Campaign Manager",
                        department: "Marketing",
                        description:
                            "Runs WhatsApp campaigns with personalization",
                        avatar: "assets/images/agent-maya.jpg",
                        stats: {
                          "Campaigns": "156",
                          "Reach": "45K",
                          "Engagement": "72%",
                        },
                        badgeColor: Color(0xFFFACC15),
                        badgeIcon: Icons.bolt_rounded,
                      ),
                      AgentCard(
                        cardWidth: cardMaxWidth, // Pass the calculated width
                        name: "David",
                        role: "Appointment Coordinator",
                        department: "Operations",
                        description:
                            "Schedules, reminds, and confirms bookings",
                        avatar: "assets/images/agent-david.jpg",
                        stats: {
                          "Booked": "3.2K",
                          "No Show": "8%",
                          "Rescheduled": "234",
                        },
                        badgeColor: Color(0xFFEF4444),
                        badgeIcon: Icons.star_border_rounded,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // ---------- Bottom Avatars + Link ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tinyAvatar("assets/images/agent-sarah.jpg"),
                  const SizedBox(width: 6),
                  _tinyAvatar("assets/images/agent-alex.jpg"),
                  const SizedBox(width: 6),
                  _tinyAvatar("assets/images/agent-maya.jpg"),
                  const SizedBox(width: 6),
                  _tinyAvatar("assets/images/agent-david.jpg"),
                  const SizedBox(width: 12),
                  const Text(
                    "+",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C6B7A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Your entire AI team",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                "All agents work together seamlessly, learning from every interaction",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5C6B7A),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tiny avatars at bottom
  static Widget _tinyAvatar(String asset) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundImage: AssetImage(asset),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//                          AGENT CARD COMPONENT (Revised)
// ---------------------------------------------------------------------------

class AgentCard extends StatelessWidget {
  final double cardWidth; // New required parameter for dynamic width
  final String name;
  final String role;
  final String department;
  final String description;
  final String avatar;
  final Map<String, String> stats;
  final Color badgeColor;
  final IconData badgeIcon;

  const AgentCard({
    super.key,
    required this.cardWidth, // Added to constructor
    required this.name,
    required this.role,
    required this.department,
    required this.description,
    required this.avatar,
    required this.stats,
    required this.badgeColor,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return RevealOnScroll(
      child: HoverCard(
        hoverTranslateY: -8,
        hoverElevation: 20,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          // --- FIX APPLIED HERE: Use dynamic width ---
          width: cardWidth,
          // ------------------------------------------
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0ECF7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ... (rest of the AgentCard implementation remains the same)
              // ---------- Avatar with Glow Badge + Online Dot ----------
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Double Ring Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2EAF3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage(avatar),
                    ),
                  ),

                  // Green online dot
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        border: Border.all(color: Colors.white, width: 3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Glow Badge bottom-right
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badgeIcon,
                        color: badgeColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ---------- Name ----------
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              // ---------- Department Badge ----------
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FA),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  department,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF556575),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ---------- Role Title ----------
              Text(
                role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0286E0),
                ),
              ),

              const SizedBox(height: 10),

              // ---------- Description ----------
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5C6B7A),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Stats Box ----------
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7EEF7)),
                ),
                child: Column(
                  children: stats.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF627889),
                            ),
                          ),
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0286E0),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Active Now ----------
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: Color(0xFF22C55E),
                    size: 12,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Active Now",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C5F6E),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
