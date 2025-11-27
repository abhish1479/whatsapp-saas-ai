import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:humainity_flutter/core/utils/responsive.dart';

class FooterSection extends StatelessWidget {
  final VoidCallback? onFeaturesTap;
  final VoidCallback? onSolutionsTap;
  final VoidCallback? onHowItWorksTap;
  final VoidCallback? onPricingTap;
  final VoidCallback? onTestimonialsTap;
  final VoidCallback? onExperienceTap;

  const FooterSection({
    super.key,
    this.onFeaturesTap,
    this.onSolutionsTap,
    this.onHowItWorksTap,
    this.onPricingTap,
    this.onTestimonialsTap,
    this.onExperienceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1380),
          child: Column(
            crossAxisAlignment:
                isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              isMobile ? _mobileLayout() : _desktopLayout(),

              const SizedBox(height: 50),
              Container(height: 1, color: const Color(0xFFE6EAF1)),
              const SizedBox(height: 24),

              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 4, child: _LogoColumn()),

        const SizedBox(width: 90),

        Expanded(
          flex: 2,
          child: _FooterColumn(
            title: "Product",
            center: false,
            items: {
              "Features": onFeaturesTap,
              "Solutions": onSolutionsTap,
              "How It Works": onHowItWorksTap,
              "Pricing": onPricingTap,
              "Testimonials" : onTestimonialsTap,
              "Experience Demo": onExperienceTap,
            },
          ),
        ),

        const Expanded(flex: 3, child: _GetInTouchColumn()),
      ],
    );
  }

  // =================== MOBILE =======================
  Widget _mobileLayout() {
    return Column(
      children: [
        const _GetInTouchColumn(center: true),
        const SizedBox(height: 40),

        _FooterColumn(
          title: "Product",
          center: true,
          items: {
            "Features": onFeaturesTap,
            "Solutions": onSolutionsTap,
            "How It Works": onHowItWorksTap,
            "Pricing": onPricingTap,
          },
        ),
      ],
    );
  }

  // =================== BOTTOM COPYRIGHT =======================
  Widget _bottomBar() {
    return const Column(
      children: [
        Text(
          "© 2025 HumAInity.ai. All rights reserved.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7A8694),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Powered by Mymobiforce",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// LOGO COLUMN
// ============================================================================
class _LogoColumn extends StatelessWidget {
  const _LogoColumn();

  Future<void> open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0BA5EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "H",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              "HumAInity.ai",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          "Where Human Care Meets AI Efficiency. Automate customer support and sales outreach with AI that talks, sells & supports — 24×7.",
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF5F6C7A),
          ),
        ),

        const SizedBox(height: 26),

        const Row(
          children: [
            _HoverIconButton(
                icon: LucideIcons.linkedin,
                url: "https://linkedin.com/company/mymobiforce"),
            SizedBox(width: 16),
            _HoverIconButton(
                icon: LucideIcons.twitter,
                url: "https://twitter.com/mymobiforce"),
            SizedBox(width: 16),
            _HoverIconButton(
                icon: LucideIcons.youtube,
                url: "https://youtube.com/@mymobiforce"),
          ],
        ),
      ],
    );
  }
}
class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final String url;

  const _HoverIconButton({required this.icon, required this.url});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () =>
            launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
        child: AnimatedScale(
          scale: hover ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(widget.icon, size: 22, color: const Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }
}
class _FooterColumn extends StatelessWidget {
  final String title;
  final bool center;
  final Map<String, VoidCallback?> items;

  const _FooterColumn({
    required this.title,
    required this.items,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 18),

        for (final entry in items.entries)
          _HoverTextLink(
            label: entry.key,
            onTap: entry.value,
            center: center,
          ),
      ],
    );
  }
}
class _HoverTextLink extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool center;

  const _HoverTextLink({
    required this.label,
    required this.onTap,
    this.center = false,
  });

  @override
  State<_HoverTextLink> createState() => _HoverTextLinkState();
}

class _HoverTextLinkState extends State<_HoverTextLink> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final align = widget.center ? TextAlign.center : TextAlign.left;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: 16,
            color: hover ? const Color(0xFF0BA5EC) : const Color(0xFF6C7A89),
            fontWeight: hover ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(widget.label, textAlign: align),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GET IN TOUCH COLUMN
// ============================================================================
class _GetInTouchColumn extends StatelessWidget {
  final bool center;

  const _GetInTouchColumn({this.center = false});

  @override
  Widget build(BuildContext context) {
    final rowAlign =
        center ? MainAxisAlignment.center : MainAxisAlignment.start;

    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          "Get in Touch",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 18),

        const _HoverLinkRow(
          icon: LucideIcons.mail,
          label: "Dheeraj.khatter@mymobiforce.com",
          url: "mailto:Dheeraj.khatter@mymobiforce.com",
        ),
        const SizedBox(height: 12),

        const _HoverLinkRow(
          icon: LucideIcons.phone,
          label: "+91-9871777715",
          url: "tel:+919871777715",
        ),
        const SizedBox(height: 12),

        const _HoverLinkRow(
          icon: LucideIcons.messageCircle,
          label: "WhatsApp Support",
          url: "https://wa.me/919871777715",
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: rowAlign,
          children: const [
            Text(
              "In India Time Zone (IST)",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7A89),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// ICON + TEXT ROW WITH CLICK ACTION
// ============================================================================
class _HoverLinkRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String url;

  const _HoverLinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  State<_HoverLinkRow> createState() => _HoverLinkRowState();
}

class _HoverLinkRowState extends State<_HoverLinkRow> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () =>
            launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: hover ? const Color(0xFF0BA5EC) : const Color(0xFF0F172A),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                color: hover ? const Color(0xFF0BA5EC) : const Color(0xFF0F172A),
                fontWeight: hover ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
