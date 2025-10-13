import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';
import '../helper/ui_helper/custom_widget.dart';
import '../helper/ui_helper/progress_view.dart';
import '../helper/utils/app_loger.dart';
import '../helper/utils/shared_preference.dart';
import '../api/api.dart';
import '../theme/business_info_theme.dart';

class BusinessTypeScreen extends StatefulWidget {      
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BusinessTypeScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  final controller = Get.find<OnboardingController>();
  final _selectedType = ''.obs;
  final _isLoading = false.obs;
 BusinessInfoTheme get themeInfo =>
      Theme.of(context).extension<BusinessInfoTheme>() ??
      BusinessInfoTheme.light;
  final _descriptionController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingSelection();
  }

  Future<void> _loadExistingSelection() async {
    final tid = await StoreUserData().getTenantId();
    await controller.fetchOnboardingData(tid);
    final data = controller.data;
    if (data != null && data.businessType != null) {
      _selectedType(data.businessType ?? '');
      _descriptionController.text = data.businessDescription ?? '';
      _customTypeController.text = data.customBusinessType ?? '';
      _categoryController.text = data.businessCategory ?? '';
    }
  }

  Future<void> _submit() async {
    if (_selectedType.value.isEmpty) {
      Get.snackbar('Error', 'Please select a business type',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
          borderColor: Colors.red[500],
          borderWidth: 1.5);
      return;
    }

    if (_selectedType.value == 'other') {
      if (_customTypeController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your Business Type',
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
            borderColor: Colors.red[500],
            borderWidth: 1);
        return;
      }
      if (_categoryController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Please enter your Business Category');
        return;
      }
    }

    try {
      _isLoading(true);
      final tid = await StoreUserData().getTenantId();

      final result = await controller.submitBusinessType(
        tenantId: tid,
        businessType: _selectedType.value,
        description: _descriptionController.text.trim(),
        customBusinessType: _customTypeController.text.trim(),
        businessCategory: _categoryController.text.trim(),
      );

      if (result['status'] == 'success') {
        Get.snackbar('Success', 'Business type saved',
            backgroundColor: Colors.green[100],
            colorText: Colors.black,
            borderColor: Colors.green[500],
            borderWidth: 1);
        widget.onNext();
      } else {
        Get.snackbar(
          'Error',
          result['detail'] ?? 'Failed to save business type',
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
          borderColor: Colors.red[500],
          borderWidth: 1,
        );
      }
    } catch (e) {
      AppLogger.log('Error: $e');
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
          borderColor: Colors.red[500],
          borderWidth: 1);
    } finally {
      _isLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      {'key': 'products', 'label': 'Products'},
      {'key': 'services', 'label': 'Services'},
      {'key': 'professional', 'label': 'Professional'},
      {'key': 'other', 'label': 'Other'},
    ];

    final theme =
        Theme.of(context).extension<BusinessInfoTheme>() ?? BusinessInfoTheme.light;

    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF8B5CF6);

    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          widget.onBack();
          return false;
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.grey[50],
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(gradient: theme.formGradient),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: theme.borderRadius,
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      color: Colors.blue[700],
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Select Business Type",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Choose the category that best describes your business",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: types.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.5,
                                ),
                                itemBuilder: (context, index) {
                                  final item = types[index];
                                  final selected =
                                      _selectedType.value == item['key'];
                                  return GestureDetector(
                                    onTap: () => _selectedType(item['key']!),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: selected
                                            ? Colors.blue[100]!
                                            : Colors.grey.shade200,
                                        border: Border.all(
                                          color: selected
                                              ? Colors.blue[700]!
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item['label']!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              if (_selectedType.value.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selectedType.value == 'other') ...[
                                      const SizedBox(height: 20),
                                      CustomWidgets.buildTextField2(
                                        context: context,
                                        controller: _customTypeController,
                                        label: "Business Type *",
                                        hint: "Enter your business type",
                                      ),
                                      const SizedBox(height: 20),
                                      CustomWidgets.buildTextField2(
                                        context: context,
                                        controller: _categoryController,
                                        label: "Business Category *",
                                        hint: "Enter business category",
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    CustomWidgets.buildTextField2(
                                      context: context,
                                      controller: _descriptionController,
                                      label: "Description",
                                      hint: "Describe your business...",
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ✅ Add Bottom Navigation Row
                    _bottomNavigation(primaryColor, secondaryColor),
                  ],
                ),
              ),
            ),
            if (_isLoading.value)
              CustomProgressView(progressText: 'Saving Business Type...'),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation(Color primaryColor, Color secondaryColor) {
    return Container(
      decoration: BoxDecoration(gradient: themeInfo.formGradient),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text("Back"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [primaryColor, secondaryColor]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _isLoading.value ? null : _submit,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Save & Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
