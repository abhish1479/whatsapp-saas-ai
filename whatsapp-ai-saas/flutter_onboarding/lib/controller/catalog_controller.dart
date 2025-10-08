import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import '../api/api.dart';

class CatalogController extends GetxController {
  final Api api = Api(Api.baseUrl);

  final items = <dynamic>[].obs;
  final loading = false.obs;
  final selected = <int>[].obs;

  Future<void> fetchCatalog({String? q}) async {
    try {
      loading.value = true;
      final list = await api.getCatalog(q: q);
      items.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load catalog: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> importCatalog(String filename, List<int> bytes) async {
    try {
      final result = await api.importCatalogFile(path: filename, filename: filename, bytes: bytes);
      Get.snackbar('Import', 'Imported ${result['created']} items');
      await fetchCatalog();
    } catch (e) {
      Get.snackbar('Error', 'Import failed: $e');
    }
  }

  Future<void> addManual(Map<String, String> fields, {Uint8List? image, String? filename}) async {
    try {
      await api.createCatalogWithImage(fields: fields, imageBytes: image, filename: filename);
      await fetchCatalog();
      Get.snackbar('Success', 'Item added');
    } catch (e) {
      Get.snackbar('Error', 'Add failed: $e');
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> body) async {
    try {
      await api.updateCatalogItem(id, body);
      await fetchCatalog();
      Get.snackbar('Updated', 'Changes saved');
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await api.deleteCatalogItem(id);
      items.removeWhere((el) => el['id'] == id);
      Get.snackbar('Deleted', 'Item removed');
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: $e');
    }
  }

  Future<void> bulkDiscount(double discount) async {
    if (selected.isEmpty) {
      Get.snackbar('Select', 'Select at least one item');
      return;
    }
    try {
      await api.bulkUpdate(selected, {'discount': discount});
      await fetchCatalog();
      Get.snackbar('Updated', 'Applied $discount% discount');
    } catch (e) {
      Get.snackbar('Error', 'Bulk update failed: $e');
    }
  }
}
