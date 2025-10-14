import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadbot_client/helper/utils/app_loger.dart';
import 'package:leadbot_client/helper/utils/app_utils.dart';
import '../../helper/utils/color_constant.dart';
import '../../helper/ui_helper/custom_text_style.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../api/api.dart';
import '../controller/catalog_controller.dart';
import '../helper/utils/shared_preference.dart';
import '../theme/business_info_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // final _itemType = 'service'.obs;
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _cat = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _imageUrl = TextEditingController();
  late var _editImageUrl = TextEditingController();
  final _pickedImage = Rx<Uint8List?>(null);
  final _pickedImageName = ''.obs;
  final _uploadingImage = false.obs;

  final _pickedImageEdit = Rx<Uint8List?>(null);
  final _pickedImageNameEdit = ''.obs;
  final _uploadingImageEdit = false.obs;

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
    _imageUrl.dispose();
    _editImageUrl.dispose();
    _siteController.dispose();
    super.dispose();
  }

  // --- Actions ---
  Future<void> _downloadTemplate() async {
    try {
      final bytes = await widget.api.downloadCsvTemplate();

      // ✅ Pass bytes directly to saveFile (required on mobile)
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Template',
        fileName: 'business_catalog_template.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: bytes, // 👈 REQUIRED for Android/iOS
      );

      if (path == null) {
        // User canceled
        return;
      }

      // ✅ On web/desktop, you can optionally verify, but not needed
      AppUtils.showSuccess('Downloaded', 'Template saved successfully!');
    } catch (e) {
      AppUtils.showError('Error', 'Download failed: $e');
    }
  }

  Future<void> _pickAndImport() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom, // ✅ REQUIRED when using allowedExtensions
        allowedExtensions: ['csv'], // ✅ Now allowed
        withData: true,
      );
      if (res == null) return;
      final f = res.files.first;
      if (f.bytes == null) return;
      await controller.importCatalog(f.name, f.bytes!);
    } catch (e) {
      AppUtils.showError('Error', 'Import failed: $e');
    }
  }

  Future<void> _showManualAddDialog() async {
    // Reset fields
    // _itemType.value = 'service';
    _name.clear();
    _desc.clear();
    _cat.clear();
    _price.clear();
    _discount.clear();
    _imageUrl.clear();
    _pickedImage.value = null;
    _pickedImageName.value = '';

    await Get.dialog(
      AlertDialog(
        title: const Text('Add Service / Product'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: _manualFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _textField(_name, 'Name *', "Enter service name"),
                  _textField(_cat, 'Category *', "Enter service category"),
                  _textField(_price, 'Price *', "Enter service price",
                      numeric: true, maxLength: 5),
                  _textField(_discount, 'Discount %', "Enter discount on price",
                      numeric: true, maxLength: 2),
                  _textField(_desc, 'Description', "Enter service description"),
                  _textField(
                      _imageUrl, 'Service image URL', "Enter service image url",
                      maxLength: 1000),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _uploadingImage.value
                        ? null
                        : () {
                            _pickImageForDialog(false, _imageUrl)
                                .catchError((e, st) {
                              AppLogger.log('Error: $e');
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: Obx(() => _imagePreview()),
                    // ✅ Shows thumbnail or icon
                    label: Obx(() => Text(
                          _pickedImageName.value.isEmpty
                              ? 'Pick Image'
                              : 'Uploaded',
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Flexible(
                child: CustomWidgets.buildCustomButton(
                  onPressed: Get.back,
                  text: "Cancel",
                  icon: Icons.close,
                  backgroundColor: Colors.red[500],
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Obx(
                  () => CustomWidgets.buildGradientButton(
                    onPressed: controller.loading.value
                        ? null
                        : () async {
                            if (!_manualFormKey.currentState!.validate())
                              return;
                            final nameValue = _name.text.trim();
                            if (nameValue.isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Name is required');
                              return; // ✅ Exit early if name is empty
                            }
                            final price = _price.text.trim();
                            if (price.isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Price is required');
                              return; // ✅ Exit early if name is empty
                            }

                            final data = {
                              // 'item_type': _itemType.value,
                              'name': nameValue,
                              'category': _cat.text.trim(),
                              'price': AppUtils.emptyToZero(_price.text.trim()),
                              'discount':
                                  AppUtils.emptyToZero(_discount.text.trim()),
                              'description': _desc.text.trim(),
                              'image_url': _imageUrl.text.trim(),
                              'source_url': 'Manual Add',
                            };
                            try {
                              await controller.addManual(data);
                              // ✅ Only close dialog if successful
                              _name.clear();
                              _desc.clear();
                              _cat.clear();
                              _price.clear();
                              _discount.clear();
                              _imageUrl.clear();
                              _pickedImage.value = null;
                              _pickedImageName.value = '';
                              Navigator.of(Get.context!).pop();
                            } catch (e) {
                              // ❌ Do NOT close dialog on error – let user correct input
                              // Error is already shown by controller via _showError
                              AppLogger.log('Error: $e');
                            }
                          },
                    text: "Add",
                    isLoading: controller.loading.value,
                    icon: Icons.add,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editDialog(Map<String, dynamic> e) async {
    // ✅ Reset image picker state to avoid carryover from other dialogs
    _pickedImageEdit.value = null;
    _pickedImageNameEdit.value = '';
    _uploadingImageEdit.value = false;

    // ✅ Initialize controllers with existing data
    final nameC = TextEditingController(text: e['name']?.toString() ?? '');
    final priceC = TextEditingController(text: e['price']?.toString() ?? '');
    final discountC =
        TextEditingController(text: e['discount']?.toString() ?? '');
    final descC =
        TextEditingController(text: e['description']?.toString() ?? '');
    final catC = TextEditingController(text: e['category']?.toString() ?? '');
    final editImageUrl =
        TextEditingController(text: e['image_url']?.toString() ?? '');

    await Get.dialog(
      AlertDialog(
        title: const Text('Edit Item'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textField(nameC, 'Name *', "Enter service name"),
                  _textField(
                    catC,
                    'Category *',
                    "Enter service category",
                  ),
                  _textField(priceC, 'Price *', "Enter service price",
                      numeric: true, maxLength: 5),
                  _textField(discountC, 'Discount %', "Enter discount on price",
                      numeric: true, maxLength: 2),
                  _textField(descC, 'Description', "Enter service description"),
                  _textField(editImageUrl, 'Service Image URL',
                      "Enter service image url"),

                  const SizedBox(height: 16),

                  // Image Picker Button
                  ElevatedButton.icon(
                    onPressed: _uploadingImage.value
                        ? null
                        : () => _pickImageForDialog(true, editImageUrl),
                    // 👈 pass controller
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: Obx(() => _imagePreviewEdit()),
                    // 👈 now safe
                    label: Obx(() => Text(
                          _pickedImageName.value.isEmpty
                              ? 'Pick Image'
                              : 'Uploaded',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Flexible(
                child: CustomWidgets.buildCustomButton(
                  onPressed: Get.back,
                  text: "Cancel",
                  icon: Icons.close,
                  backgroundColor: Colors.red[500],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Obx(
                  () => CustomWidgets.buildGradientButton(
                    onPressed: controller.loading.value
                        ? null
                        : () async {
                            // ✅ Validation
                            if (nameC.text.trim().isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Name is required');
                              return;
                            }
                            if (priceC.text.trim().isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Price is required');
                              return;
                            }

                            final body = {
                              'item_id': e['id'],
                              'name': nameC.text.trim(),
                              'price': AppUtils.emptyToZero(priceC.text.trim()),
                              'discount':
                                  AppUtils.emptyToZero(discountC.text.trim()),
                              'description': descC.text.trim(),
                              'category': catC.text.trim(),
                              'image_url': editImageUrl.text.trim(),
                            };

                            try {
                              await controller.updateItem(e['id'], body);
                              Navigator.of(Get.context!).pop();
                            } catch (e) {
                              AppLogger.log('Edit error: $e');
                              // Error shown via controller or AppUtils already
                            }
                          },
                    text: "Save",
                    isLoading: controller.loading.value,
                    icon: Icons.save,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePreviewEdit() {
    if (_pickedImageEdit.value == null) {
      return const Icon(Icons.image, color: Colors.blue, size: 24);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          _pickedImageEdit.value!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _imagePreview() {
    if (_pickedImage.value == null) {
      return const Icon(Icons.image, color: Colors.blue);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          _pickedImage.value!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, color: Colors.blue),
        ),
      ),
    );
  }

  Future<void> _pickImageForDialog(bool isEdit,
      [TextEditingController? urlController]) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null) return;

    final file = res.files.first;
    if (file.bytes == null) return;

    if (isEdit) {
      _pickedImageEdit.value = file.bytes;
      _pickedImageNameEdit.value = file.name;
    } else {
      _pickedImage.value = file.bytes;
      _pickedImageName.value = file.name;
    }

    try {
      _uploadingImage.value = true;
      final imageUrl = await widget.api.uploadImage(file.bytes!, file.name);

      // ✅ Use passed controller or fallback (for add dialog)
      final targetController = urlController ?? _imageUrl;
      targetController.text = imageUrl;

      AppUtils.showSuccess('Image Uploaded', 'Image saved successfully!');
    } catch (e) {
      AppUtils.showError('Upload Failed', 'Could not upload image: $e');
      _pickedImage.value = null;
      _pickedImageName.value = '';
      (urlController ?? _imageUrl).clear();
    } finally {
      _uploadingImage.value = false;
    }
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
    String url = _siteController.text.trim();

    // --- Empty field check ---
    if (url.isEmpty) {
      Get.snackbar('Invalid URL', 'Please enter a website URL');
      return;
    }

    // --- Add https:// if missing ---
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // --- Add www. if missing and domain has no subdomain ---
    final uri = Uri.tryParse(url);
    if (uri != null &&
        (uri.host.isNotEmpty && !uri.host.startsWith('www.')) &&
        uri.host.split('.').length == 2) {
      // example: firstcry.com  →  www.firstcry.com
      final fixedHost = 'www.${uri.host}';
      url = uri.replace(host: fixedHost).toString();
    }

    // --- Correct, safe validation ---
    final parsed = Uri.tryParse(url);
    final isValid = parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.isNotEmpty;

    if (!isValid) {
      Get.snackbar('Invalid URL', 'Please enter a valid website URL');
      return;
    }

    // --- Proceed ---
    Get.back(); // close dialog
    await controller.fetchFromWebsite(url);
  }

  Widget _buildWebsiteItemList(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // --- Header Row ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ✅ Wrap in Obx so it reacts to selection changes
                      Obx(() => Checkbox(
                            value: controller.selectedWebsiteItems.length ==
                                    controller.websiteItems.length &&
                                controller.websiteItems.isNotEmpty,
                            onChanged: (v) => controller.selectAll(v ?? false),
                          )),
                      const Text(
                        'Select All',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  CustomWidgets.buildCustomButton(
                    onPressed: controller.saveSelectedWebsiteItems,
                    text: "Add",
                    icon: Icons.add,
                    height: 45,
                    backgroundColor: Colors.blue[800],
                  ),
                ],
              ),
            ),

            // --- List of items ---
            Expanded(
              child: Obx(() {
                final items = controller.websiteItems;
                if (items.isEmpty) {
                  return const Center(child: Text('No website data found'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];

                    return Obx(() {
                      final selected =
                          controller.selectedWebsiteItems.contains(index);
                      final name = (e['name'] ?? 'Unknown').toString();
                      final description = (e['description'] ?? '').toString();

                      String formatNumber(dynamic value) {
                        if (value == null) return '';
                        if (value is int) return value.toString();
                        if (value is double) {
                          return value == value.toInt()
                              ? value.toInt().toString()
                              : value.toStringAsFixed(2);
                        }
                        return value.toString();
                      }

                      final price = formatNumber(e['price']);
                      final discount = formatNumber(e['discount']);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected ? Colors.blue[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? Colors.blueAccent
                                : Colors.grey[300]!,
                            width: selected ? 1.5 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3))
                                ]
                              : [],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Checkbox ---
                              Checkbox(
                                value: selected,
                                onChanged: (v) =>
                                    controller.toggleSelect(index, v),
                              ),

                              const SizedBox(width: 4),

                              // --- Main content ---
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // --- Row: Name + Edit icon ---
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // ✅ Name with ellipsis
                                        Expanded(
                                          child: Text(
                                            name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue[800],
                                              size: 20),
                                          onPressed: () => _editWebsiteItem(
                                              context, index, e),
                                        ),
                                      ],
                                    ),

                                    // --- Row: Price + Discount ---
                                    if (price.isNotEmpty)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          
                                            Text(
                                              'Price ₹ $price',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Colors.blue[800],
                                              ),
                                            ),
                                          if (price.isNotEmpty &&
                                              discount.isNotEmpty)
                                            const SizedBox(width: 15),
                                          if (discount.isNotEmpty)
                                            Text(
                                              'Disc. $discount % off',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: Colors.green,
                                              ),
                                            ),
                                        ],
                                      ),

                                    const SizedBox(height: 6),

                                    // --- Description ---
                                    if (description.isNotEmpty)
                                      Text(
                                        description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          height: 1.3,
                                        ),
                                      ),

                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editWebsiteItem(
      BuildContext context, int index, Map<String, dynamic> item) async {
    _pickedImageEdit.value = null;
    _pickedImageNameEdit.value = '';
    _uploadingImageEdit.value = false;

    final nameC = TextEditingController(text: item['name'] ?? '');
    final descC = TextEditingController(text: item['description'] ?? '');
    final catC = TextEditingController(text: item['category'] ?? '');
    final priceC = TextEditingController(text: item['price']?.toString() ?? '');
    final discountC =
        TextEditingController(text: item['discount']?.toString() ?? '');
    final editWebImageUrl =
        TextEditingController(text: item['image_url']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Website Item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _textField(nameC, 'Name *', "Enter service name"),
              _textField(
                catC,
                'Category *',
                "Enter service category",
              ),
              _textField(priceC, 'Price *', "Enter service price",
                  numeric: true, maxLength: 5),
              _textField(discountC, 'Discount %', "Enter discount on price",
                  numeric: true, maxLength: 2),
              _textField(descC, 'Description', "Enter service description"),
              _textField(editWebImageUrl, 'Service Image URL',
                  "Enter service image url"),

              const SizedBox(height: 16),

              // Image Picker Button
              ElevatedButton.icon(
                onPressed: _uploadingImage.value
                    ? null
                    : () => _pickImageForDialog(true, editWebImageUrl),
                // 👈 pass controller
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: Obx(() => _imagePreviewEdit()),
                // 👈 now safe
                label: Obx(() => Text(
                      _pickedImageName.value.isEmpty
                          ? 'Pick Image'
                          : 'Uploaded',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Flexible(
                child: CustomWidgets.buildCustomButton(
                  onPressed: Get.back,
                  text: "Cancel",
                  icon: Icons.close,
                  backgroundColor: Colors.red[500],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Obx(
                  () => CustomWidgets.buildGradientButton(
                    onPressed: controller.loading.value
                        ? null
                        : () async {
                            // ✅ Validation
                            if (nameC.text.trim().isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Name is required');
                              return;
                            }
                            if (priceC.text.trim().isEmpty) {
                              AppUtils.showError(
                                  'Validation Error', 'Price is required');
                              return;
                            }

                            controller.websiteItems[index] = {
                              ...item,
                              'name': nameC.text.trim(),
                              'description': descC.text.trim(),
                              'category': catC.text.trim(),
                              'price': double.tryParse(priceC.text.trim()) ??
                                  item['price'],
                              'discount':
                                  double.tryParse(discountC.text.trim()) ??
                                      item['discount'],
                              'image_url': editWebImageUrl.text.trim(),
                            };

                            try {
                              controller.websiteItems.refresh();
                              Navigator.of(Get.context!).pop();
                            } catch (e) {
                              AppLogger.log('Edit error: $e');
                              // Error shown via controller or AppUtils already
                            }
                          },
                    text: "Save",
                    isLoading: controller.loading.value,
                    icon: Icons.save,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _textField(TextEditingController ctrl, String label, String hint,
      {bool numeric = false, int maxLength = 100}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: CustomWidgets.buildTextField2(
        context: context,
        controller: ctrl,
        label: label,
        hint: hint,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.words,
        maxLength: maxLength,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 👇 Custom back behavior
        if (controller.websiteListVisible.value) {
          controller.websiteListVisible.value = false; // hide list
          controller.websiteItems.clear();
          controller.selectedWebsiteItems.clear();
          return false; // prevent navigation
        } else {
          widget.onBack(); // go to previous onboarding step
          return false;
        }
      },
      child: Stack(
        children: [
          Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: _mainContent(context)),
                  // your existing screen
                  _bottomNavigation(context),
                ],
              ),
            ),
          ),

          // 👇 Overlay for website analysis animation
          /*Obx(() => controller.analyzing.value
              ? _buildWebsiteAnalysisOverlay(context)
              : const SizedBox.shrink()),*/

          // 👇 List view for analyzed website items
          Obx(() => controller.websiteListVisible.value &&
                  controller.websiteItems.isNotEmpty
              ? _buildWebsiteItemList(context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _mainContent(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF8B5CF6);

    return Obx(() {
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
              // --- Header ---
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
                "Choose how you'd like to add your offerings",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),

              // --- CSV Template download link ---
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
                        const Icon(Icons.download,
                            size: 18, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Download Template',
                          style: TextStyle(
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Add / Upload options ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildActionCard(
                      context,
                      icon: Icons.add,
                      title: 'Add Service/Product',
                      color: primaryColor,
                      onPressed: _showManualAddDialog,
                    ),
                  ),
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

              // --- Analyze Website option ---
              _buildActionCardWitTitle(
                context,
                icon: Icons.language_rounded,
                title: 'Analyze Website',
                subtitle: 'Extract Products & Services automatically',
                color: secondaryColor,
                onPressed: _showWebsiteDialog,
              ),

              const SizedBox(height: 20),

              // --- Catalog Table (existing) ---
              if (controller.items.isNotEmpty)
                _catalogTable(context)
              else
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No items yet. Use the options above to add your offerings.',
                  ),
                ),
            ],
          ),
        ),
      );
    });
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                                icon: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue[700]!,
                                ),
                                onPressed: () => _editDialog(e),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.blue[700]!,
                                ),
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
