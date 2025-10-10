import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadbot_client/helper/utils/app_utils.dart';
import 'package:path_provider/path_provider.dart';
import '../../helper/utils/color_constant.dart';
import '../../helper/ui_helper/custom_text_style.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../api/api.dart';
import '../controller/catalog_controller.dart';
import '../helper/utils/shared_preference.dart';
import '../theme/business_info_theme.dart';

class InfoCaptureScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const InfoCaptureScreen({
    super.key,
    required this.api,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<InfoCaptureScreen> createState() => _InfoCaptureScreenState();
}

class _InfoCaptureScreenState extends State<InfoCaptureScreen> {
  late final CatalogController controller = Get.find<CatalogController>();

  BusinessInfoTheme get themeInfo =>
      Theme.of(context).extension<BusinessInfoTheme>() ??
      BusinessInfoTheme.light;

  // For Manual Add Dialog
  final _manualFormKey = GlobalKey<FormState>();
  final _itemType = 'service'.obs;
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _cat = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _source = TextEditingController();
  final _pickedImage = Rx<Uint8List?>(null);
  final _pickedImageName = ''.obs;

  // For Website Analysis Dialog
  final _siteController = TextEditingController();
  final _ingestingSite = false.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchCatalog();
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _cat.dispose();
    _price.dispose();
    _discount.dispose();
    _source.dispose();
    _siteController.dispose();
    super.dispose();
  }

  // --- Actions ---
  Future<void> _downloadTemplate() async {
    try {
      final bytes = await widget.api.downloadCsvTemplate();
      final dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/business_catalog_template.csv');
      await file.writeAsBytes(bytes);
      AppUtils.showSuccess('Download', 'Template saved to ${file.path}');
    } catch (e) {
      AppUtils.showError('Error', 'Download failed: $e');
    }
  }

  Future<void> _pickAndImport() async {
    final res = await FilePicker.platform.pickFiles(
      withData: true,
      allowedExtensions: ['csv'],
    );
    if (res == null) return;
    final f = res.files.first;
    if (f.bytes == null) return;
    await controller.importCatalog(f.name, f.bytes!);
  }

  Future<void> _showManualAddDialog() async {
    // Reset fields
    _itemType.value = 'service';
    _name.clear();
    _desc.clear();
    _cat.clear();
    _price.clear();
    _discount.clear();
    _source.clear();
    _pickedImage.value = null;
    _pickedImageName.value = '';

    await Get.dialog(
      AlertDialog(
        title: const Text('Add Item Manually'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: _manualFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dropdownField([
                    'product',
                    'service',
                    'course',
                    'package',
                    'room',
                    'membership',
                    'other'
                  ], _itemType),
                  _textField(_name, 'Name *', required: true),
                  _textField(_cat, 'Category'),
                  _textField(_desc, 'Description'),
                  _textField(_price, 'Price', numeric: true),
                  _textField(_discount, 'Discount', numeric: true),
                  _textField(_source, 'Source URL'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.black),
                    onPressed: _pickImageForDialog,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: Obx(() => Text(
                          _pickedImageName.value.isEmpty
                              ? 'Pick Image'
                              : _pickedImageName.value,
                          style: const TextStyle(color: Colors.white),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.loading.value
                    ? null
                    : () async {
                        if (!_manualFormKey.currentState!.validate()) return;
                        final data = {
                          'item_type': _itemType.value,
                          'name': _name.text.trim(),
                          'description': _desc.text.trim(),
                          'category': _cat.text.trim(),
                          'price': _price.text.trim(),
                          'discount': _discount.text.trim(),
                          'source_url': _source.text.trim(),
                        };
                        await controller.addManual(
                          data,
                          image: _pickedImage.value,
                          filename: _pickedImageName.value,
                        );
                        Get.back(); // Close dialog
                      },
                child: const Text('Add'),
              )),
        ],
      ),
    );
  }

  Future<void> _pickImageForDialog() async {
    final res = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (res == null) return;
    _pickedImage.value = res.files.first.bytes;
    _pickedImageName.value = res.files.first.name;
  }

  Future<void> _showWebsiteDialog() async {
    _siteController.clear();
    _ingestingSite.value = false;

    await Get.dialog(
      AlertDialog(
        title: const Text('Analyze Website'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We\'ll automatically extract products and services from your website',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _siteController,
                decoration: InputDecoration(
                  labelText: 'Website URL',
                  hintText: 'www.yourwebsite.com',
                  prefixIcon: const Icon(Icons.link_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _submitWebsite(),
              ),
              const SizedBox(height: 16),
              Obx(() => ElevatedButton.icon(
                    onPressed: _ingestingSite.value ? null : _submitWebsite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: _ingestingSite.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white),
                    label: Text(
                      _ingestingSite.value ? 'Analyzing...' : 'Analyze Website',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _submitWebsite() async {
    final url = _siteController.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      Get.snackbar('Invalid URL',
          'Please enter a valid URL starting with http:// or https://');
      return;
    }

    try {
      _ingestingSite.value = true;
      final tenantId = await StoreUserData().getTenantId();
      if (tenantId == null) {
        Get.snackbar('Error', 'Tenant not found');
        return;
      }

      await widget.api.postForm('/onboarding/items/website', {
        'tenant_id': tenantId,
        'url': url,
      });

      Get.snackbar('Success', 'Website queued for analysis');
      Get.back(); // Close dialog
    } catch (e) {
      Get.snackbar('Error', 'Website ingestion failed: $e');
    } finally {
      _ingestingSite.value = false;
    }
  }

  // --- Reusable Widgets ---
  Widget _dropdownField(List<String> options, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: Obx(() => DropdownButtonFormField<String>(
              value: value.value,
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => value.value = v!,
              decoration: const InputDecoration(labelText: 'Type'),
            )),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label,
      {bool required = false, bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF8B5CF6);
    const cardColor = Colors.white;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Container(
                  decoration: BoxDecoration(gradient: themeInfo.formGradient),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Add Products & Services',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose how you\'d like to add your offerings',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: _downloadTemplate,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.download,
                                    size: 18,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                  Text(
                                    'Download Template',
                                    style: TextStyle(
                                      color: const Color(0xFF3B82F6),
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color(0xFF3B82F6),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ✅ 4 Action Buttons in Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //  Manual Add
                            Flexible(
                              child: _buildActionCard(
                                context,
                                icon: Icons.add,
                                title: 'Add Service/Product',
                                color: primaryColor,
                                onPressed: _showManualAddDialog,
                              ),
                            ),


                            // 2. Upload CSV File
                            Flexible(
                              child: _buildActionCard(
                                context,
                                icon: Icons.upload_file_rounded,
                                title: 'Upload CSV File',
                                color: primaryColor,
                                onPressed: _pickAndImport,
                              ),
                            ),
                          ],
                        ),



                        const SizedBox(height: 10),

                        // 4. Analyze Website
                        _buildActionCardWitTitle(
                          context,
                          icon: Icons.language_rounded,
                          title: 'Analyze Website',
                          subtitle: 'Extract service/Product from your site',
                          color: secondaryColor,
                          onPressed: _showWebsiteDialog,
                        ),

                        const SizedBox(height: 15),

                        // Catalog Table
                        if (controller.items.isNotEmpty)
                          _catalogTable(context)
                        else
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'No items yet. Use the options above to add your offerings.'),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            _bottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCardWitTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _catalogTable(BuildContext context) {
    return Obx(() => SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 5),
                child: Text(
                  'Added Service (${controller.items.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),

              Card(
                elevation: 2,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Actions')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Discount %')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Image')),
                    ],
                    rows: controller.items.map<DataRow>((e) {
                      final id = e['id'] as int;
                      return DataRow(
                        cells: [
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 18, color: Colors.blue[700]!,),
                                onPressed: () => _editDialog(e),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 18 ,color: Colors.blue[700]!,),
                                onPressed: () => controller.deleteItem(id),
                              ),
                            ],
                          )),
                          DataCell(Text(e['name'] ?? '')),
                          DataCell(Text('${e['price'] ?? ''}')),
                          DataCell(Text('${e['discount'] ?? ''}')),
                          DataCell(Text(e['category'] ?? '')),
                          DataCell(_thumb(e['image_url'])),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty)
      return const Icon(Icons.image_not_supported, size: 20);
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 20),
        ),
      ),
    );
  }

  Future<void> _editDialog(Map e) async {
    final nameC = TextEditingController(text: e['name']);
    final priceC = TextEditingController(text: e['price']?.toString() ?? '');
    final discountC = TextEditingController(text: e['discount']?.toString() ?? '');
    final descC = TextEditingController(text: e['description'] ?? '');
    final catC = TextEditingController(text: e['category'] ?? '');
    final type = (e['item_type'] ?? 'service').obs;

    Get.defaultDialog(
      title: 'Edit Item',
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dropdownField([
              'product',
              'service',
              'course',
              'package',
              'room',
              'membership',
              'other'
            ], type),
            _textField(nameC, 'Name', required: true),
            _textField(priceC, 'Price', numeric: true),
            _textField(discountC, 'Discount', numeric: true),
            _textField(catC, 'Category'),
            _textField(descC, 'Description'),
            const SizedBox(height: 10),
            CustomWidgets.buildGradientButton(
              onPressed: () {
                final body = {
                  'item_id': e['id'],
                  'item_type': type.value,
                  'name': nameC.text.trim(),
                  'price': priceC.text.trim(),
                  'discount': discountC.text.trim(),
                  'description': descC.text.trim(),
                  'category': catC.text.trim(),
                };
                controller.updateItem(e['id'], body);
                Get.back();
              },
              text: "Save",
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF8B5CF6);

    return Container(
      decoration: BoxDecoration(gradient: themeInfo.formGradient),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ⬅️ Back button
          OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text("Back"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: const Color(0xFF64748B),
            ),
          ),

          // ➡️ Continue button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
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
              onPressed: widget.onNext,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon:
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              label: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
