import 'package:flutter/material.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';

class ExperienceDemoScreen extends StatefulWidget {
  const ExperienceDemoScreen({super.key});

  @override
  State<ExperienceDemoScreen> createState() => _ExperienceDemoScreenState();
}

class _ExperienceDemoScreenState extends State<ExperienceDemoScreen> {
  int _selectedDemoIndex = 0;
  int _selectedQuestionIndex = -1;

  // ---------------------------------------------------------------------------
  // DEMO SCENARIOS
  // ---------------------------------------------------------------------------

  final List<_DemoScenario> _demos = const [
    _DemoScenario(
      title: 'Try Consumer Goods Support',
      imagePath: 'assets/images/consumer-goods-support.jpg',
      questions: [
        "How do I return a defective product?",
        "What's the warranty period for electronics?",
        "How can I track my order status?",
        "How do I register a product complaint?",
      ],
    ),
    _DemoScenario(
      title: 'Try BFSI Pre-sales',
      imagePath: 'assets/images/bfsi-presales.jpg',
      questions: [
        'What are the interest rates for home loans?',
        'How can I open a savings account?',
        'What documents are needed for KYC?',
        'What are the eligibility criteria for credit cards?',
      ],
    ),
    _DemoScenario(
      title: 'Try Healthcare Booking',
      imagePath: 'assets/images/healthcare-booking.jpg',
      questions: [
        'How do I book an appointment with a specialist?',
        'What are your clinic operating hours?',
        'Can I reschedule my appointment?',
        'How do I access my medical records?',
      ],
    ),
  ];

  _DemoScenario get _currentDemo => _demos[_selectedDemoIndex];

  // ---------------------------------------------------------------------------
  // SUCCESS SNACKBAR
  // ---------------------------------------------------------------------------

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: const Color(0xFFF5F7FB),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------
                // TITLE
                // ---------------------------------------
                RichText(
                  textAlign: TextAlign.left,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Experience Voice and Chat support by ",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: "AI Agents",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF009BFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                isMobile
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose Any Demo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: List.generate(
                  _demos.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 16),
                      child: _Hover(
                        child: _demoCard(i),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                "Click Any Question",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                  _currentDemo.questions.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _Hover(
                      child: _questionTile(i),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // RIGHT SIDE ACTION BUTTONS
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _Hover(
                scale: 1.03,
                child: _launchCard(
                  icon: Icons.call,
                  title: "Launch Voice",
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBgColor: const Color(0xFF8B5CF6),
                  onTap: () => _openDemoModal(context, _DemoType.voice),
                ),
              ),
              const SizedBox(height: 20),
              _Hover(
                scale: 1.03,
                child: _launchCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "Launch Chat",
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBgColor: const Color(0xFF3B82F6),
                  onTap: () => _openDemoModal(context, _DemoType.chat),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MOBILE = STACKED VERSION
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- TITLE --------
        const SizedBox(height: 20),
        const Text(
          "Choose Any Demo",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 14),

        // -------- DEMO CARDS (HORIZONTAL SCROLL) --------
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: _demos.length,
            itemBuilder: (context, index) => SizedBox(
              width: 260,
              child: _demoCard(index),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // -------- QUESTIONS LIST --------
        const Text(
          "Click Any Question",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: List.generate(
            _currentDemo.questions.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _questionTile(i),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // -------- LAUNCH BUTTONS --------
        _launchCard(
          onTap: () => _openDemoModal(context, _DemoType.voice),
          icon: Icons.call,
          title: "Launch Voice",
          gradient: const LinearGradient(
            colors: [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconBgColor: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        _launchCard(
          onTap: () => _openDemoModal(context, _DemoType.chat),
          icon: Icons.chat_bubble_outline_rounded,
          title: "Launch Chat",
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          iconBgColor: const Color(0xFF3B82F6),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DEMO CARD
  // ---------------------------------------------------------------------------

  Widget _demoCard(int index) {
    final demo = _demos[index];
    final selected = index == _selectedDemoIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() {
        _selectedDemoIndex = index;
        _selectedQuestionIndex = -1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0EA5E9) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? Colors.blue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: selected ? 18 : 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                demo.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                demo.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QUESTION TILE
  // ---------------------------------------------------------------------------

  Widget _questionTile(int index) {
    final selected = _selectedQuestionIndex == index;
    final q = _currentDemo.questions[index];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedQuestionIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF38BDF8) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? Colors.blue.withOpacity(0.12) : Colors.black12,
              blurRadius: selected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                q,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LAUNCH CARDS
  // ---------------------------------------------------------------------------

  Widget _launchCard({
    required IconData icon,
    required String title,
    required LinearGradient gradient,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN MODAL
  // ---------------------------------------------------------------------------

  Future<void> _openDemoModal(BuildContext context, _DemoType type) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _DemoFormDialog(
        demo: _currentDemo,
        type: type,
        onSuccess: (msg) => showSuccessSnackBar(context, msg),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FORM DIALOG
// -----------------------------------------------------------------------------

class _DemoFormDialog extends StatefulWidget {
  final _DemoScenario demo;
  final _DemoType type;
  final void Function(String) onSuccess;

  const _DemoFormDialog({
    required this.demo,
    required this.type,
    required this.onSuccess,
  });

  @override
  State<_DemoFormDialog> createState() => _DemoFormDialogState();
}

class _DemoFormDialogState extends State<_DemoFormDialog> {
  late TextEditingController _name;
  late TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == _DemoType.voice
        ? "Get a Voice Call Demo"
        : "Get a WhatsApp Demo";

    final btnLabel =
        widget.type == _DemoType.voice ? "Get Call Demo" : "Get WhatsApp Demo";

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------------------
              // HEADER
              // ------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // NAME FIELD
              // ------------------------------------------------------------
              const Text(
                "Name (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                style: const TextStyle(fontSize: 16),
                decoration: _blueInput("Your name"),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // PHONE
              // ------------------------------------------------------------
              const Text(
                "Phone Number *",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16),
                decoration: _blueInput("+1 (555) 123-4567"),
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------------------
              // BLUE INFO BAR
              // ------------------------------------------------------------
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFE5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "You'll experience: ",
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: widget.demo.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------
              // SUBMIT BUTTON
              // ------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_phone.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter your phone number."),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    widget.onSuccess(
                      "Success! You'll receive a WhatsApp message shortly to experience ${widget.demo.title}.",
                    );
                  },
                  child: Text(
                    btnLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------------------
              // TERMS TEXT
              // ------------------------------------------------------------
              const Center(
                child: Text(
                  "By submitting, you agree to receive a demo contact via your chosen method",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BLUE INPUT FIELD STYLE (Matches Screenshot)
  // ---------------------------------------------------------------------------

  InputDecoration _blueInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3BB2FF),
          width: 2.4,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------

class _DemoScenario {
  final String title;
  final String imagePath;
  final List<String> questions;

  const _DemoScenario({
    required this.title,
    required this.imagePath,
    required this.questions,
  });
}

enum _DemoType {
  voice,
  chat,
}

// -----------------------------------------------------------------------------
// HOVER EFFECT WRAPPER
// -----------------------------------------------------------------------------

class _Hover extends StatefulWidget {
  final Widget child;
  final double scale;

  const _Hover({
    required this.child,
    this.scale = 1.02,
  });

  @override
  State<_Hover> createState() => _HoverState();
}

class _HoverState extends State<_Hover> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: hover ? widget.scale : 1.0,
        child: widget.child,
      ),
    );
  }
}
