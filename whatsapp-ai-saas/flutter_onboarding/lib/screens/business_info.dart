import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api.dart';
import '../theme/business_info_theme.dart';

class BusinessInfoScreen extends StatefulWidget {
  final Api api;
  final String tenantId;
  final VoidCallback onNext;

  const BusinessInfoScreen({
    required this.api,
    required this.tenantId,
    required this.onNext,
    super.key,
  });

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lang = ValueNotifier<String>('en');
  bool _loading = false;

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  BusinessInfoTheme get theme =>
      Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _lang.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);
  try {
    final response = await widget.api.postForm('/onboarding/business', {
      'business_name': _nameController.text.trim(),
      'owner_phone': _phoneController.text.trim(),
      'language': _lang.value,
    });

    final ok = response['ok'] == true;
    final message = response['message']?.toString() ?? 'Unexpected response';
    final tenantId = response['tenant_id']?.toString();

    if (!mounted) return;

    if (tenantId != null) {
      await widget.api.saveTenantId(tenantId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: ok ? Colors.green[600] : Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text("Failed to save. Please try again.")),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
        ),
      );
    }
  } catch (e, stack) {
    debugPrint('Business save error: $e\n$stack');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text("Something went wrong. Please try again.")),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (width > 1024) {
                  return Row(
                    children: [
                      Expanded(flex: 3, child: _buildForm(scrollable: true)),
                      Expanded(flex: 2, child: _buildWhatsAppPreview()),
                    ],
                  );
                } else if (width > 600) {
                  return Row(
                    children: [
                      Expanded(child: _buildForm(scrollable: true)),
                      Expanded(child: _buildWhatsAppPreview()),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        _buildForm(scrollable: false),
                        const SizedBox(height: 16),
                        _buildWhatsAppPreview(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool scrollable}) {
    final formContent = Padding(
      padding: theme.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: "Business Name",
            hint: "Enter your business name",
            icon: Icons.store,
            validator: (v) => v?.trim().isEmpty == true ? "Required" : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _phoneController,
            label: "Owner Phone (WhatsApp)",
            hint: "Indian 10-digit mobile number, e.g., 9876543210",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v?.trim().isEmpty == true) return "Required";
              if (v!.trim().length != 10) return "Enter a valid 10-digit phone number";
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLanguageDropdown(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(gradient: theme.formGradient),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: scrollable ? SingleChildScrollView(child: formContent) : formContent,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: theme.borderRadius,
          ),
          child: Icon(Icons.business, color: Colors.blue[700], size: 32),
        ),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Business Information",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tell us about your business to get started",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: theme.borderRadius,
        boxShadow: [theme.cardShadow],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: theme.borderRadius,
        boxShadow: [theme.cardShadow],
      ),
      child: DropdownButtonFormField<String>(
        value: _lang.value,
        decoration: InputDecoration(
          labelText: "Preferred Language",
          prefixIcon: Icon(Icons.language, color: Colors.purple[600]),
          border: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: const [
          DropdownMenuItem(
            value: 'en',
            child: Row(children: [Text('🇺🇸'), SizedBox(width: 8), Text('English')]),
          ),
          DropdownMenuItem(
            value: 'hi',
            child: Row(children: [Text('🇮🇳'), SizedBox(width: 8), Text('Hindi')]),
          ),
        ],
        onChanged: (v) => setState(() => _lang.value = v ?? 'en'),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: theme.borderRadius),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: theme.buttonGradient,
            borderRadius: theme.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _loading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text("Saving...",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                )
              : const Text(
                  "Save & Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppPreview() {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameController, _phoneController, _lang]),
      builder: (context, _) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [theme.cardShadow],
        ),
        child: Column(
          children: [
            _buildWhatsAppHeader(),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildWhatsAppChat(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppHeader() {
    final name = _nameController.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[600]!, Colors.green[700]!]),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(
              name.isEmpty ? "B" : name[0].toUpperCase(),
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? "Your Business" : name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Online", style: TextStyle(color: Colors.green[100], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.phone, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppChat() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final displayName = name.isEmpty ? "Your Business" : name;

    return Column(
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [theme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lang.value == 'hi'
                      ? "नमस्ते $displayName! 👋"
                      : "Hello $displayName! 👋",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  _lang.value == 'hi'
                      ? "हम आपसे WhatsApp पर संपर्क करेंगे। 📲"
                      : "We will reach you on WhatsApp 📲",
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("12:30 PM", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(width: 4),
                    Icon(Icons.done_all, color: Colors.blue[600], size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            child: Text(
              phone.isEmpty ? "+91 XXXXXXXXXX" : "+91 $phone",
              style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}