import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/providers/auth_provider.dart';
import 'package:humainise_ai/core/providers/business_profile_provider.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart';
import 'package:humainise_ai/models/business_profile.dart';
import 'package:humainise_ai/widgets/ui/app_button.dart';
import 'package:humainise_ai/widgets/ui/app_dropdown.dart';
import 'package:humainise_ai/widgets/ui/app_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

class GoLiveDialog extends ConsumerStatefulWidget {
  const GoLiveDialog({super.key});

  @override
  ConsumerState<GoLiveDialog> createState() => _GoLiveDialogState();
}

class _GoLiveDialogState extends ConsumerState<GoLiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _personalNumberCtrl = TextEditingController();
  final _otherIndustryCtrl = TextEditingController();

  String _selectedIndustry = 'Technology';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _whatsappCtrl.dispose();
    _personalNumberCtrl.dispose();
    _otherIndustryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final double dialogWidth = isDesktop ? 500 : double.infinity;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(LucideIcons.rocket,
                        size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Activate Your Agent',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _businessNameCtrl,
                        labelText: 'Business Name',
                        prefixIcon: const Icon(LucideIcons.building, size: 16),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        labelText: 'Industry',
                        value: _selectedIndustry,
                        items: _kIndustryList
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedIndustry = val);
                        },
                      ),
                      if (_selectedIndustry == 'Other') ...[
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _otherIndustryCtrl,
                          labelText: 'Specify Industry',
                          validator: (v) => _selectedIndustry == 'Other' &&
                                  (v == null || v.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _whatsappCtrl,
                        labelText: 'Business WhatsApp Number',
                        keyboardType: TextInputType.phone,
                        prefixIcon:
                            const Icon(LucideIcons.messageCircle, size: 16),
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Invalid number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _personalNumberCtrl,
                        labelText: 'Personal WhatsApp Number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(LucideIcons.phone, size: 16),
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Invalid number'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      style: AppButtonStyle.tertiary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _isSubmitting ? 'Activating...' : 'Go Live',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final store = ref.read(storeUserDataProvider);
      final tenantIdStr = await store?.getTenantId();
      if (tenantIdStr == null) throw Exception("Tenant ID not found.");

      final finalIndustry = _selectedIndustry == 'Other'
          ? _otherIndustryCtrl.text.trim()
          : _selectedIndustry;

      final payload = BusinessProfileCreate(
        tenantId: int.parse(tenantIdStr),
        businessName: _businessNameCtrl.text.trim(),
        businessWhatsapp: _whatsappCtrl.text.trim(),
        personalNumber: _personalNumberCtrl.text.trim(),
        businessType: finalIndustry,
        language: 'en',
      );

      // 1. Call API
      await ref.read(businessProfileProvider.notifier).createProfile(payload);

      // 2. ✅ Update Local Storage to "Completed"
      if (store != null) {
        await store.setOnboardingProcess('Completed');
        // 3. ✅ Trigger Global Refresh (Sidebar will listen to this)
        ref.read(onboardingRefreshProvider.notifier).state++;
      }

      // 4. ✅ Refresh Auth State (Optional, double check)
      await ref
          .read(authNotifierProvider.notifier)
          .maybeFetchOnboardingStatus();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Agent Activated! Dashboard updated.'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
