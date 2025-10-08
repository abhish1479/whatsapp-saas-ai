import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../helper/utils/color_constant.dart';
import '../../helper/ui_helper/custom_text_style.dart';
import '../../helper/ui_helper/custom_widget.dart';
import '../api/api.dart';
import '../controller/catalog_controller.dart';

class InfoCaptureScreen extends StatelessWidget {
  InfoCaptureScreen({super.key});

  final CatalogController c = Get.put(CatalogController());
  final Api api = Api(Api.baseUrl);

  // Manual add fields
  final _formKey = GlobalKey<FormState>();
  final itemType = 'service'.obs;
  final name = TextEditingController();
  final desc = TextEditingController();
  final cat = TextEditingController();
  final price = TextEditingController();
  final discount = TextEditingController();
  final source = TextEditingController();
  final pickedImage = Rx<Uint8List?>(null);
  final pickedImageName = ''.obs;

  Future<void> _downloadTemplate() async {
    try {
      final bytes = await api.downloadCsvTemplate();
      final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/business_catalog_template.csv');
      await file.writeAsBytes(bytes);
      Get.snackbar('Download', 'Template saved to ${file.path}');
    } catch (e) {
      Get.snackbar('Error', 'Download failed: $e');
    }
  }

  Future<void> _pickAndImport() async {
    final res = await FilePicker.platform.pickFiles(withData: true, allowedExtensions: ['csv', 'xls', 'xlsx']);
    if (res == null) return;
    final f = res.files.first;
    if (f.bytes == null) return;
    await c.importCatalog(f.name, f.bytes!);
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res == null) return;
    pickedImage.value = res.files.first.bytes;
    pickedImageName.value = res.files.first.name;
  }

  Future<void> _submitManual() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'item_type': itemType.value,
      'name': name.text.trim(),
      'description': desc.text.trim(),
      'category': cat.text.trim(),
      'price': price.text.trim(),
      'discount': discount.text.trim(),
      'source_url': source.text.trim(),
    };
    await c.addManual(data, image: pickedImage.value, filename: pickedImageName.value);
    name.clear(); desc.clear(); cat.clear(); price.clear(); discount.clear(); source.clear();
    pickedImage.value = null; pickedImageName.value = '';
  }

  @override
  Widget build(BuildContext context) {
    c.fetchCatalog();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Business Catalog'),
        backgroundColor: ColorConstant.primaryColor,
      ),
      body: Obx(() {
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _actionRow(),
              const SizedBox(height: 16),
              _manualAddCard(context),
              const SizedBox(height: 16),
              _catalogTable(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _actionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 10,
          children: [
            CustomButton(
              label: 'Download CSV Template',
              icon: Icons.download,
              onTap: _downloadTemplate,
            ),
            CustomButton(
              label: 'Import CSV/XLSX',
              icon: Icons.upload_file,
              onTap: _pickAndImport,
            ),
          ],
        ),
        if (c.selected.isNotEmpty)
          CustomButton(
            label: 'Bulk Discount (${c.selected.length})',
            icon: Icons.percent,
            onTap: () => _promptDiscount(),
            color: ColorConstant.secondaryColor,
          ),
      ],
    );
  }

  void _promptDiscount() {
    final ctrl = TextEditingController();
    Get.defaultDialog(
      title: 'Apply Discount (%)',
      content: Column(
        children: [
          TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 15')),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Apply',
            onTap: () {
              final val = double.tryParse(ctrl.text) ?? 0;
              c.bulkDiscount(val);
              Get.back();
            },
          )
        ],
      ),
    );
  }

  Widget _manualAddCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add Service or Product', style: CustomTextStyle.headingTextStyle),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dropdown(['product','service','course','package','room','membership','other'], itemType),
                _field(name, 'Name *', required: true),
                _field(cat, 'Category'),
                _field(desc, 'Description'),
                _field(price, 'Price', numeric: true),
                _field(discount, 'Discount', numeric: true),
                _field(source, 'Source URL'),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: ColorConstant.secondaryColor),
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Obx(() => Text(pickedImageName.isEmpty ? 'Pick Image' : pickedImageName.value)),
              ),
              const SizedBox(width: 10),
              CustomButton(label: 'Add Item', onTap: _submitManual),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _catalogTable(BuildContext context) {
    if (c.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No items yet. Import or add manually.'),
      );
    }

    return Obx(() => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Sel')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Discount')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Image')),
            DataColumn(label: Text('Actions')),
          ],
          rows: c.items.map<DataRow>((e) {
            final id = e['id'] as int;
            final selected = c.selected.contains(id);
            return DataRow(
              selected: selected,
              onSelectChanged: (v) {
                if (v == true) {
                  c.selected.add(id);
                } else {
                  c.selected.remove(id);
                }
              },
              cells: [
                DataCell(Checkbox(value: selected, onChanged: (v) {
                  if (v == true) c.selected.add(id); else c.selected.remove(id);
                })),
                DataCell(Text(e['item_type'] ?? '')),
                DataCell(Text(e['name'] ?? '')),
                DataCell(Text('${e['price'] ?? ''}')),
                DataCell(Text('${e['discount'] ?? ''}')),
                DataCell(Text(e['category'] ?? '')),
                DataCell(_thumb(e['image_url'])),
                DataCell(Row(children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editDialog(e)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => c.deleteItem(id)),
                ])),
              ],
            );
          }).toList(),
        ),
      ),
    ));
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.image_not_supported);
    return SizedBox(width: 48, height: 48, child: Image.network(url, fit: BoxFit.cover));
  }

  Widget _dropdown(List<String> options, RxString value) {
    return SizedBox(
      width: 200,
      child: Obx(() => DropdownButtonFormField<String>(
        value: value.value,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => value.value = v!,
        decoration: const InputDecoration(labelText: 'Type'),
      )),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false, bool numeric = false}) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
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
      content: Column(
        children: [
          _dropdown(['product','service','course','package','room','membership','other'], type),
          _field(nameC, 'Name', required: true),
          _field(priceC, 'Price', numeric: true),
          _field(discountC, 'Discount', numeric: true),
          _field(catC, 'Category'),
          _field(descC, 'Description'),
          const SizedBox(height: 10),
          CustomButton(
            label: 'Save',
            onTap: () {
              final body = {
                'item_type': type.value,
                'name': nameC.text.trim(),
                'price': priceC.text.trim(),
                'discount': discountC.text.trim(),
                'description': descC.text.trim(),
                'category': catC.text.trim(),
              };
              c.updateItem(e['id'], body);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
