import 'package:flutter/material.dart';
import 'package:leadbot_client/helper/utils/app_loger.dart';
import '../api/api.dart';
import '../controller/onboarding_controller.dart';
import '../helper/ui_helper/custom_widget.dart';
import '../helper/utils/app_utils.dart';
import '../helper/utils/shared_preference.dart';
import '../theme/business_info_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

class BusinessInfoScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onNext;

  const BusinessInfoScreen({
    required this.api,
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
  String? _selectedLanguage = 'en';
  int tenantId = -1;

  // ✅ NEW: पहले से सेव डेटा की कॉपी (बदलाव चेक करने के लिए)
  String _originalName = '';
  String _originalPhone = '';
  String _originalLanguage = 'en';

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  BusinessInfoTheme get theme =>
      Theme.of(context).extension<BusinessInfoTheme>() ??
          BusinessInfoTheme.light;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();

    _initData();
  }

  Future<void> _initData() async {
    tenantId = await StoreUserData().getTenantId();


    if (tenantId!= -1) {
      // ✅ NEW: GetX कंट्रोलर से डेटा लोड करें
      final controller = Get.find<OnboardingController>();
      await controller.fetchOnboardingData(tenantId);

      final data = controller.data;
      if (data != null && data.hasBusinessProfile) {
        // ✅ NEW: फील्ड्स में डेटा सेट करें
        _nameController.text = data.businessName;
        _phoneController.text = data.ownerPhone;
        _selectedLanguage = data.language;

        // ✅ NEW: ओल्ड वैल्यूज सेव करें (बदलाव चेक के लिए)
        _originalName = data.businessName;
        _originalPhone = data.ownerPhone;
        _originalLanguage = data.language;
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final width = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (kIsWeb) {
                  if (width > 1024) {
                    return Row(
                      children: [
                        Flexible(flex: 3, child: _buildForm(inRow: true)),
                        Flexible(flex: 2, child: _buildWhatsAppPreview(inRow: true)),
                      ],
                    );
                  } else if (width > 600) {
                    return Row(
                      children: [
                        Flexible(flex: 3, child: _buildForm(inRow: true)),
                        Flexible(flex: 2, child: _buildWhatsAppPreview(inRow: true)),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          _buildForm(inRow: false),
                          const SizedBox(height: 16),
                          _buildWhatsAppPreview(inRow: false),
                        ],
                      ),
                    );
                  }
                } else {
                  if (isPortrait) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          _buildForm(inRow: false),
                          const SizedBox(height: 16),
                          _buildWhatsAppPreview(inRow: false),
                        ],
                      ),
                    );
                  } else {
                    return Row(
                      children: [
                        Flexible(flex: 3, child: _buildForm(inRow: true)),
                        Flexible(flex: 2, child: _buildWhatsAppPreview(inRow: true)),
                      ],
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool inRow}) {
    final formContent = Padding(
      padding: theme.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          CustomWidgets.buildTextField(
            context: context,
            controller: _nameController,
            label: "Business Name *",
            hint: "Enter your business name",
            icon: Icons.store,
            keyboardType: TextInputType.text,
            maxLength: 50,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  value.trim().length < 2) {
                return 'Please enter complete name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          CustomWidgets.buildTextField(
            context: context,
            controller: _phoneController,
            label: "Owner Phone (WhatsApp) *",
            hint: "10 Digit mobile number, e.g., 9876543210",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value?.isEmpty == false && value?.trim().length != 10) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomWidgets.buildDropdown(
            context: context,
            value: _selectedLanguage,
            label: "Preferred Language",
            icon: Icons.language,
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Text('🇺🇸'),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'hi',
                child: Row(
                  children: [
                    Text('🇮🇳'),
                    SizedBox(width: 8),
                    Text('Hindi'),
                  ],
                ),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
          ),
          const SizedBox(height: 32),
          CustomWidgets.buildGradientButton(
            context: context,
            onPressed: _loading ? null : _submit,
            text: "Save & Continue",
            isLoading: _loading,
            icon: Icons.save,
          ),
        ],
      ),
    );

    Widget formWidget = Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: formContent,
    );

    if (inRow) {
      formWidget = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: formWidget,
      );
      return Container(
        decoration: BoxDecoration(gradient: theme.formGradient),
        child: formWidget,
      );
    } else {
      return Container(
        decoration: BoxDecoration(gradient: theme.formGradient),
        child: formWidget,
      );
    }
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

  // ✅ UPDATED: _submit में बदलाव चेक लॉजिक ऐड किया गया
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final currentName = _nameController.text.trim();
    final currentPhone = _phoneController.text.trim();
    final currentLang = _selectedLanguage ?? 'en';

    // ✅ NEW: चेक करें कि क्या कोई फील्ड बदला गया है
    final hasChanged =
        currentName != _originalName ||
            currentPhone != _originalPhone ||
            currentLang != _originalLanguage;

    if (!hasChanged) {
      // ✅ NEW: डेटा नहीं बदला → सीधे अगले स्क्रीन पर जाएं
      widget.onNext();
      return;
    }

    // ✅ NEW: डेटा बदला है → API कॉल करें
    setState(() => _loading = true);
    try {
      final response = await widget.api.postForm('/onboarding/business', {
        'business_name': currentName,
        'owner_phone': currentPhone,
        'language': currentLang,
      });

      final ok = response['ok'] == true;
      final message = response['message']?.toString() ?? 'Unexpected response';
      final tenantId = response['tenant_id']?? -1;

      if (!mounted) return;

      if (tenantId != -1) {

        // ✅ NEW: GetX कंट्रोलर को अपडेट करें
        final controller = Get.find<OnboardingController>();
        await controller.refreshData(tenantId);

        // ✅ NEW: नए डेटा को "ओल्ड" मान लें
        _originalName = currentName;
        _originalPhone = currentPhone;
        _originalLanguage = currentLang;

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
        AppUtils.errorToast(context, "Failed to save. Please try again.", 3);
      }
    } catch (e, stack) {
      AppLogger.error('Business save error: $e\n$stack');
      if (mounted) {
        AppUtils.errorToast(
            context, "Something went wrong. Please try again.", 3);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildWhatsAppPreview({required bool inRow}) {
    if (inRow) {
      return AnimatedBuilder(
        animation: Listenable.merge([_nameController, _phoneController, _lang]),
        builder: (context, _) => Flexible(
          child: Container(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _buildWhatsAppChat(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildWhatsAppHeader(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildWhatsAppChat(),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildWhatsAppHeader() {
    final name = _nameController.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient:
        LinearGradient(colors: [Colors.green[600]!, Colors.green[700]!]),
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
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? "Your Business" : name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text("Online",
                    style: TextStyle(color: Colors.green[100], fontSize: 12)),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  _lang.value == 'hi'
                      ? "हम आपसे WhatsApp पर संपर्क करेंगे। 📲"
                      : "We will reach you on WhatsApp 📲",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("12:30 PM",
                        style:
                        TextStyle(color: Colors.grey[500], fontSize: 11)),
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
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
            child: Text(
              phone.isEmpty ? "+91 XXXXXXXXXX" : "+91 $phone",
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}