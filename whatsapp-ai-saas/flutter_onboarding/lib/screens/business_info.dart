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
  State createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _userPhotoUrl;

  // controllers
  final _nameController = TextEditingController();
  final _personalController = TextEditingController();           // NEW
  final _phoneController = TextEditingController();              // Business WhatsApp Number

  // language value used by preview (UI dropdown removed as requested)
  final _lang = ValueNotifier<String>('en');

  bool _loading = false;
  int tenantId = -1;

  // originals for change detection
  String _originalName = '';
  String _originalPersonal = '';                                 // NEW
  String _originalPhone = '';

  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  BusinessInfoTheme get theme =>
      Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
    _initData();
  }

  Future _initData() async {
    tenantId = await StoreUserData().getTenantId();
    _userName = await StoreUserData().getUserName();
    _userPhotoUrl = await StoreUserData().getProfilePic();

    if (tenantId != -1) {
      final controller = Get.find<OnboardingController>();
      await controller.fetchOnboardingData(tenantId);
      final data = controller.data;

      if (data != null && data.hasBusinessProfile) {
        _nameController.text = data.businessName;
        _phoneController.text = data.businessWhatsapp;            // CHANGED (was ownerPhone)
        _personalController.text = data.personalNumber;           // NEW
        _originalName = data.businessName;
        _originalPhone = data.businessWhatsapp;                   // CHANGED
        _originalPersonal = data.personalNumber;                  // NEW
      }
    }
    if (mounted) {
      setState(() {
        // Triggers rebuild to show user info
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personalController.dispose();
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
                final screenWidth = constraints.maxWidth;
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
                        SizedBox(
                          width: screenWidth * 0.60,
                          child: _buildForm(inRow: true),
                        ),
                        SizedBox(
                          width: screenWidth * 0.40,
                          child: _buildWhatsAppPreview(inRow: true),
                        ),
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

          // Business Name
          CustomWidgets.buildTextField(
            context: context,
            controller: _nameController,
            label: "Business Name *",
            hint: "Enter your business name",
            icon: Icons.store,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              if (value.trim().length < 2) {
                return 'Please enter complete name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Personal Number (NEW)
          CustomWidgets.buildTextField(
            context: context,
            controller: _personalController,
            label: "Personal Number *",
            hint: "10 digit mobile number, e.g., 9876543210",
            icon: Icons.person,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Personal number is required';
              if (v.length != 10 || int.tryParse(v) == null) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Business WhatsApp Number (renamed)
          CustomWidgets.buildTextField(
            context: context,
            controller: _phoneController,
            label: "Business WhatsApp Number *",
            hint: "10 digit mobile number, e.g., 9876543210",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Business WhatsApp number is required';
              if (v.length != 10 || int.tryParse(v) == null) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Save & Continue
          CustomWidgets.buildGradientButton(
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
      return Container(decoration: BoxDecoration(gradient: theme.formGradient), child: formWidget);
    } else {
      return Container(decoration: BoxDecoration(gradient: theme.formGradient), child: formWidget);
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8), // Add some padding around the user info
          child: Row(
            mainAxisSize: MainAxisSize.min, // Make row as small as its content
            children: [
              if (_userPhotoUrl != null && _userPhotoUrl!.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(_userPhotoUrl!),
                  radius: 30, // Adjust size as needed
                  backgroundColor: Colors.grey[200],
                )
              else
                CircleAvatar( // Fallback if no photo URL
                  child: Icon(Icons.person, color: Colors.grey[700]),
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                ),
              const SizedBox(width: 12),
              if (_userName != null && _userName!.isNotEmpty)
                Text(
                  _userName!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],),
                )
              else
                const Text("User"), // Fallback if no name
            ],
          ),
        ),

        Visibility(
          visible: false,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: theme.borderRadius,
            ),
            child: Icon(Icons.business, color: Colors.blue[700], size: 32),
          ),
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  // submit (change detection kept, language excluded from checks as requested)
  Future _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final currentName = _nameController.text.trim();
    final currentPersonal = _personalController.text.trim();
    final currentPhone = _phoneController.text.trim();

    final hasChanged =
        currentName != _originalName || currentPersonal != _originalPersonal || currentPhone != _originalPhone;

    if (!hasChanged) {
      widget.onNext();
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await widget.api.postForm('/onboarding/business', {
        'tenant_id': tenantId.toString(),                          // ensure server receives tenant
        'business_name': currentName,
        'personal_number': currentPersonal,             // NEW
        'business_whatsapp': currentPhone,              // CHANGED (was owner_phone)
      });

      final ok = response['ok'] == true;
      final message = response['message']?.toString() ?? 'Unexpected response';
      final returnedTenantId = response['tenant_id'] ?? -1;

      if (!mounted) return;

      if (returnedTenantId != -1) {
        final controller = Get.find<OnboardingController>();
        await controller.refreshData(returnedTenantId);
        _originalName = currentName;
        _originalPersonal = currentPersonal;
        _originalPhone = currentPhone;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.warning_amber_rounded, color: Colors.white),
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
        AppUtils.errorToast(context, "Failed to save.\nPlease try again.", 3);
      }
    } catch (e, stack) {
      AppLogger.error('Business save error: $e\n$stack');
      if (mounted) {
        AppUtils.errorToast(context, "Something went wrong.\nPlease try again. \n$e", 3);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildWhatsAppPreview({required bool inRow}) {
    final preview = AnimatedBuilder(
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

    if (inRow) {
      return Flexible(child: preview);
    }
    return preview;
  }

  Widget _buildWhatsAppHeader() {
    final name = _nameController.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[600]!, Colors.green[700]!]),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                  _lang.value == 'hi' ? "नमस्ते $displayName! " : "Hello $displayName! ",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  _lang.value == 'hi' ? "हम आपसे WhatsApp पर संपर्क करेंगे। " : "We will reach you on WhatsApp ",
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
