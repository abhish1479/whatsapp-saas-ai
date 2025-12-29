import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humainity_flutter/core/utils/responsive.dart'; 
import 'package:humainity_flutter/screens/home/widgets/features_section.dart'; // This import seems unused but kept for completeness
import 'package:humainity_flutter/widgets/ui/app_button.dart';
class AppColors { 
  static const Color primary = Color(0xFF009BFF);
}

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController floatCtrl;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();

    floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F0FE),
            Color(0xFFF7FAFF),
            Color(0xFFE9EEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// Main content layout
              Column(
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  // Pass context to the builder methods
                  isMobile
                      ? _buildMobileHero(context)
                      : _buildDesktopHero(context),

                  const SizedBox(height: 5),

                  const Text(
                    "- it's free! 🎉",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Pass context to the KPI section
                  _buildKPISection(context),
                ],
              ),

              /// Floating icons (desktop only)
              if (!isMobile)
                Positioned(
                  right: 0,
                  bottom: 40,
                  child: Column(
                    children: [
                      _floatingIcon(Icons.chat, Colors.green),
                      const SizedBox(height: 16),
                      _floatingIcon(Icons.phone, Colors.blue),
                      const SizedBox(height: 16),
                      _floatingIcon(Icons.message, Colors.red),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP HERO LAYOUT
  // ---------------------------------------------------------------------------
  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _leftHeroText(context)),
        const SizedBox(width: 40),
        Expanded(child: _rightHeroImageChats(context)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE HERO LAYOUT
  // ---------------------------------------------------------------------------
  Widget _buildMobileHero(BuildContext context) {
    return Column(
      children: [
        _leftHeroText(context),
        const SizedBox(height: 40),
        _rightHeroImageChats(context), // Pass context here
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT TEXT SECTION
  // ---------------------------------------------------------------------------
  Widget _leftHeroText(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          "HumAInise.ai",
          style: TextStyle(
            color: Color(0xFF009BFF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // Responsive font size for the main heading
        Text(
          "AI that Talks, Sells & Supports — Just Like You.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 40 : 66, // Reduced size on mobile
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "Automate your customer support and sales outreach with AI agents "
          "that understand your business, learn from your data, and engage "
          "across WhatsApp and Voice.",
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            height: 1.5,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 32),

        // Center button on mobile
        // if (isMobile)
        //   Center(
        //     child: AppButton(
        //       text: "Create Your AI Agent",
        //       onPressed: () => context.go('/auth'),
        //       isLg: true,
        //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        //     ),
        //   )
        // else
        //   AppButton(
        //     text: "Create Your AI Agent",
        //     onPressed: () => context.go('/auth'),
        //     isLg: true,
        //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        //   ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT IMAGE + CHAT BUBBLES (INSIDE IMAGE CLIPPED)
  // ---------------------------------------------------------------------------
  Widget _rightHeroImageChats(BuildContext context) { // Accepts context
    final isMobile = Responsive.isMobile(context);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Stack(
        children: [
          SizedBox(
            // FIX 1: Use full width on mobile, fixed width on desktop
            width: isMobile ? double.infinity : 550, 
            height: isMobile ? 400 : 620, // Adjusted height for mobile
            child: Image.asset(
              // NOTE: Ensure this asset path is correct in your project
              "assets/images/ai-sales-agent.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Chat bubbles (positioned relative to the responsive SizedBox)
          Positioned(
            top: 30,
            left: 20,
            child: _chatBubbleWhite(
              "Hi! 😊 I'm your AI Sales Agent. \n How can I help you today?",
            ),
          ),
          /// BLUE bubble (Top Right)
          Positioned(
            top: 120,
            right: 20,
            child: _chatBubbleBlue(
              "I'd like to schedule a property viewing.",
            ),
          ),

          /// WHITE bubble (Middle Left)
          Positioned(
            top: 200,
            left: 20,
            child: _chatBubbleWhite(
              "Got it! 👍 When would you like to book your appointment?",
            ),
          ),

          /// WHITE bubble (Bottom Right)
          Positioned(
            top: 300,
            right: 20,
            child: _chatBubbleBlue(
              "Tuesday works. Do you have any afternoon slots?",
            ),
          ),

          Positioned(
            top: 400,
            left: 20,
            child: _chatBubbleWhite(
              "Absolutely! Here are the available time slots for\n Tuesday afternoon:\n 02:00 PM and 02:30 PM",
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CHAT BUBBLES
  // ---------------------------------------------------------------------------
  Widget _chatBubbleBlue(String text) {
    return _animatedBubble(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5E9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _chatBubbleWhite(String text) {
    return _animatedBubble(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _animatedBubble(Widget child) {
    // This is working correctly for the floating animation
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, floatAnim.value),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI SECTION
  // ---------------------------------------------------------------------------
  Widget _buildKPISection(BuildContext context) { // Accepts context
    final isMobile = Responsive.isMobile(context);

    // FIX 2: Use Wrap on mobile to prevent overflow
    if (isMobile) {
      return Wrap(
        spacing: 40, // Horizontal spacing
        runSpacing: 20, // Vertical spacing
        alignment: WrapAlignment.center,
        children: [
          _kpi("24/7", "Always Available", true),
          _kpi("80%", "Faster Response", true),
          _kpi("45%", "More Bookings", true),
        ],
      );
    }
    
    // Desktop Row layout
    return Row(
      children: [
        _kpi("24/7", "Always Available", false),
        const SizedBox(width: 60),
        _kpi("80%", "Faster Response", false),
        const SizedBox(width: 60),
        _kpi("45%", "More Bookings", false),
      ],
    );
  }

  Widget _kpi(String number, String label, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.primary
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FLOATING RIGHT SIDE ICONS
  // ---------------------------------------------------------------------------
  Widget _floatingIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, floatAnim.value),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
              )
            ],
          ),
          child: Icon(icon, size: 26, color: color),
        ),
      ),
    );
  }
}