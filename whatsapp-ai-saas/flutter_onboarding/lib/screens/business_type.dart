// lib/screens/business_type.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadbot_client/helper/utils/shared_preference.dart';
import '../api/api.dart';
import '../controller/onboarding_controller.dart';
import '../theme/business_info_theme.dart';

class BusinessTypeScreen extends StatelessWidget {
  final Api api;
  final VoidCallback onNext;
  final VoidCallback onBack;

  final _selectedType = ''.obs;
  final _isLoading = true.obs;

  BusinessTypeScreen({
    required this.api,
    required this.onNext,
    required this.onBack,
    super.key,
  }) {
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final tid = await StoreUserData().getTenantId();
    if (tid.isEmpty) {
      _isLoading(false);
      return;
    }

    try {
      final controller = Get.find<OnboardingController>();
      if (controller.data == null) {
        await controller.fetchOnboardingData(tid);
      }

      final data = controller.data;
      if (data != null && data.hasBusinessType) {
        _selectedType(data.businessType);
      }
    } catch (e) {
      debugPrint('Error loading business type: $e');
    } finally {
      _isLoading(false);
    }
  }

  Future<void> _choose(String type) async {
    _selectedType(type);

    final tid = await StoreUserData().getTenantId();
    if (tid.isEmpty) {
      onNext();
      return;
    }

    try {
      // ✅ जब आप तैयार हों, तो इन्हें अनकमेंट करें
      // await api.postForm('/onboarding/type', {
      //   'tenant_id': tid,
      //   'business_type': type,
      // });
      //
      // final controller = Get.find<OnboardingController>();
      // await controller.refreshData(tid);
      //
      // onNext();
      onNext(); // अस्थायी रूप से सीधे आगे बढ़ें
    } catch (e) {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(content: Text('Failed to save selection. Please try again.')),
        );
        final controller = Get.find<OnboardingController>();
        _selectedType(controller.data?.businessType ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final tiles = [
            _TypeTile(
              icon: Icons.shopping_bag,
              label: "Products",
              value: "products",
              isSelected: _selectedType.value == "products",
              onTap: _choose,
              theme: theme,
            ),
            _TypeTile(
              icon: Icons.build,
              label: "Services",
              value: "services",
              isSelected: _selectedType.value == "services",
              onTap: _choose,
              theme: theme,
            ),
            _TypeTile(
              icon: Icons.school,
              label: "Professional",
              value: "professional",
              isSelected: _selectedType.value == "professional",
              onTap: _choose,
              theme: theme,
            ),
            _TypeTile(
              icon: Icons.more_horiz,
              label: "Other",
              value: "other",
              isSelected: _selectedType.value == "other",
              onTap: _choose,
              theme: theme,
            ),
          ];

          return Container(
            decoration: BoxDecoration(gradient: theme.formGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Padding(
                  padding: theme.screenPadding,
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                /// Responsive Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (MediaQuery.of(context).orientation ==
                          Orientation.landscape ||
                          kIsWeb) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: kIsWeb ||
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 1.5
                              : 1.3,
                        ),
                        itemCount: tiles.length,
                        itemBuilder: (context, i) => tiles[i],
                      );
                    },
                  ),
                ),

                /// Sticky Footer (केवल वेब पर)
                if (kIsWeb)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onBack,
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 18,
                          ),
                          label: const Text("Back"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ✅ फिक्स्ड _TypeTile — Expanded हटाया गया, सेंटरिंग सुनिश्चित की गई
class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final Function(String) onTap;
  final BusinessInfoTheme theme;

  const _TypeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 5 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: theme.borderRadius,
        side: isSelected
            ? BorderSide(color: Colors.blue[600]!, width: 1.2)
            : BorderSide.none,
      ),
      color: isSelected ? Colors.blue[20] : Colors.white,
      child: InkWell(
        borderRadius: theme.borderRadius,
        onTap: () => onTap(value),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ सेंटर
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.blue[700] : Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),
              // ✅ Expanded हटाया गया — अब कार्ड स्क्रॉल होगा
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue[800] : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}