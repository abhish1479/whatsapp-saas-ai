import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/providers/business_profile_provider.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/models/business_profile.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:humainise_ai/widgets/ui/app_dropdown.dart';
import 'package:humainise_ai/widgets/ui/app_switch.dart';
import 'package:humainise_ai/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';

const List<String> _kIndustryList = [
  'Technology',
  'Retail & E-commerce',
  'Healthcare',
  'Real Estate',
  'Education',
  'Financial Services',
  'Hospitality',
  'Automotive',
  'Other'
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Controllers
  final _businessNameCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _personalCtrl = TextEditingController();
  final _otherIndustryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // State
  String _selectedIndustry = 'Technology';
  bool _isSavingProfile = false;
  bool _dataLoaded = false;

  // Settings
  String _llmModel = "google/gemini-2.5-flash";
  String _voiceModel = "eleven_turbo_v2_5";
  String _selectedVoice = "Sarah";
  String _currency = "INR";
  bool _emailNotifications = true;
  bool _campaignAlerts = true;
  bool _lowBalanceAlert = true;
  bool _twoFactor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessProfileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _whatsappCtrl.dispose();
    _personalCtrl.dispose();
    _otherIndustryCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(businessProfileProvider);

    if (profileState.profile != null && !_dataLoaded) {
      final p = profileState.profile!;
      _businessNameCtrl.text = p.businessName;
      _whatsappCtrl.text = p.businessWhatsapp;
      _personalCtrl.text = p.personalNumber ?? '';
      _descriptionCtrl.text = p.description ?? '';

      final apiIndustry = p.businessType ?? 'Technology';
      if (_kIndustryList.contains(apiIndustry)) {
        _selectedIndustry = apiIndustry;
      } else {
        _selectedIndustry = 'Other';
        _otherIndustryCtrl.text = apiIndustry;
      }
      _dataLoaded = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Manage your business details and configurations.',
              style: TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 24),
          _buildBusinessInfo(profileState),
          const SizedBox(height: 24),
          _buildBillingPayment(),
          const SizedBox(height: 24),
          _buildAiModelConfig(),
          const SizedBox(height: 24),
          _buildNotificationsAndSecurity(),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo(BusinessProfileState state) {
    if (state.isLoading) {
      return const AppCard(
          child: SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())));
    }

    // --- Field Definitions ---
    final nameField = AppTextField(
      labelText: 'Business Name',
      controller: _businessNameCtrl,
      prefixIcon: const Icon(LucideIcons.building, size: 16),
    );

    final industryField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String>(
          labelText: 'Industry',
          value: _selectedIndustry,
          items: _kIndustryList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedIndustry = val);
          },
        ),
        if (_selectedIndustry == 'Other') ...[
          const SizedBox(height: 12),
          AppTextField(
            labelText: 'Specify Industry',
            controller: _otherIndustryCtrl,
            prefixIcon: const Icon(LucideIcons.penTool, size: 16),
          ),
        ],
      ],
    );

    final whatsappField = AppTextField(
      labelText: 'Business WhatsApp',
      controller: _whatsappCtrl,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(LucideIcons.messageCircle, size: 16),
    );

    final personalField = AppTextField(
      labelText: 'Personal WhatsApp',
      controller: _personalCtrl,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(LucideIcons.phone, size: 16),
    );

    final descriptionField = AppTextField(
      labelText: 'Business Description',
      controller: _descriptionCtrl,
      maxLines: 3,
      prefixIcon: const Icon(LucideIcons.fileText, size: 16),
    );

    // --- Layout Logic ---
    // ✅ Fix: Use !isMobile to catch Tablets & Desktop (Web) for the 2-column layout
    final isWideScreen = !Responsive.isMobile(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.briefcase, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Business Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          if (isWideScreen) ...[
            // --- Desktop / Web (2 Columns) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // ✅ Fix alignment
              children: [
                Expanded(child: nameField),
              ],
            ),
            const SizedBox(height: 16),
            industryField,
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // ✅ Fix alignment
              children: [
                Expanded(child: whatsappField),
                const SizedBox(width: 16),
                Expanded(child: personalField),
              ],
            ),
            const SizedBox(height: 16),
            descriptionField,
          ] else ...[
            // --- Mobile (1 Column) ---
            nameField,
            const SizedBox(height: 16),
            industryField,
            const SizedBox(height: 16),
            whatsappField,
            const SizedBox(height: 16),
            personalField,
            const SizedBox(height: 16),
            descriptionField,
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: _isSavingProfile ? 'Saving...' : 'Save Changes',
              onPressed: _isSavingProfile
                  ? null
                  : () => _updateProfile(state.profile?.id),
            ),
          ),
        ],
      ),
    );
  }

  // --- Other Sections (Grouped nicely) ---

  Widget _buildNotificationsAndSecurity() {
    // Reuse layout logic: 2 columns on web, 1 on mobile
    final isWideScreen = !Responsive.isMobile(context);

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildNotifications()),
          const SizedBox(width: 16),
          Expanded(child: _buildSecurity()),
        ],
      );
    } else {
      return Column(
        children: [
          _buildNotifications(),
          const SizedBox(height: 16),
          _buildSecurity(),
        ],
      );
    }
  }

  Future<void> _updateProfile(int? id) async {
    if (id == null) return;
    setState(() => _isSavingProfile = true);
    try {
      final finalIndustry = _selectedIndustry == 'Other'
          ? _otherIndustryCtrl.text.trim()
          : _selectedIndustry;
      final updatePayload = BusinessProfileUpdate(
        id: id,
        businessName: _businessNameCtrl.text.trim(),
        businessWhatsapp: _whatsappCtrl.text.trim(),
        personalNumber: _personalCtrl.text.trim(),
        businessType: finalIndustry,
        description: _descriptionCtrl.text.trim(),
      );
      await ref
          .read(businessProfileProvider.notifier)
          .updateProfile(updatePayload);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Widget _buildBillingPayment() {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(LucideIcons.creditCard,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text('Billing & Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
              ]),
              ToggleSwitch(
                minWidth: 60.0,
                initialLabelIndex: _currency == 'INR' ? 0 : 1,
                cornerRadius: 8.0,
                activeFgColor: AppColors.foreground,
                inactiveBgColor: AppColors.muted,
                inactiveFgColor: AppColors.mutedForeground,
                activeBgColor: const [AppColors.background],
                totalSwitches: 2,
                labels: const ['INR', 'USD'],
                onToggle: (index) =>
                    setState(() => _currency = (index == 0 ? 'INR' : 'USD')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 48),
          AppButton(text: 'Recharge Wallet', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildAiModelConfig() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(LucideIcons.bot, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('AI Model Configuration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 24),
          AppDropdown<String>(
            labelText: 'LLM Model',
            value: _llmModel,
            onChanged: (val) => setState(() => _llmModel = val!),
            items: const [
              DropdownMenuItem(
                  value: 'google/gemini-2.5-flash',
                  child: Text('Gemini 2.5 Flash'))
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            labelText: 'Voice',
            value: _selectedVoice,
            onChanged: (val) => setState(() => _selectedVoice = val!),
            items: const [
              DropdownMenuItem(value: 'Sarah', child: Text('Sarah'))
            ],
          ),
          const SizedBox(height: 24),
          AppButton(text: 'Save Model Settings', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(LucideIcons.bell, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 24),
          _buildSwitchTile(
              title: 'Email Notifications',
              value: _emailNotifications,
              onChanged: (val) => setState(() => _emailNotifications = val)),
          const Divider(height: 24),
          _buildSwitchTile(
              title: 'Campaign Alerts',
              value: _campaignAlerts,
              onChanged: (val) => setState(() => _campaignAlerts = val)),
        ],
      ),
    );
  }

  Widget _buildSecurity() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(LucideIcons.shield, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
          ]),
          const SizedBox(height: 24),
          AppTextField(labelText: 'New Password', obscureText: true),
          const SizedBox(height: 16),
          AppButton(text: 'Update', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      {required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      AppSwitch(value: value, onChanged: onChanged)
    ]);
  }
}
