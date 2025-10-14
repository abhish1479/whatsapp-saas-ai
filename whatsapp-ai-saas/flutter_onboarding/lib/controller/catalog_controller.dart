import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api.dart';
import '../helper/utils/shared_preference.dart';

class CatalogController extends GetxController {
  final Api api;
  CatalogController(this.api);

  final items = <dynamic>[].obs;
  final loading = false.obs;
  final loadingCSV = false.obs;
  final selected = <int>[].obs;
  final websiteItems = <Map<String, dynamic>>[].obs;
  final selectedWebsiteItems = <int>[].obs;
  final loadingWebsite = false.obs;
  final websiteListVisible = false.obs;
  final websiteAnalysisStep = 0.obs;
  final analyzing = false.obs;


  /// --- Snackbar Helpers ---
  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green[100],
      colorText: Colors.black,
      borderColor: Colors.green[500],
      borderWidth: 1,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.black,
      borderColor: Colors.red[500],
      borderWidth: 1,
      duration: const Duration(seconds: 3),
    );
  }

  /// --- Fetch Catalog ---
  Future<void> fetchCatalog({String? q}) async {
    try {
      loading.value = true;
      final store = StoreUserData();
      final tenantId = await store.getTenantId();
      if (tenantId == null) {
        _showError('Error', 'Tenant not found in session');
        return;
      }

      final list = await api.getCatalog(tenantId: tenantId, query: q);
      items.assignAll(list);
      // _showSuccess('Success', 'Catalog loaded successfully');
    } catch (e) {
      _showError('Error', 'Failed to load catalog: $e');
    } finally {
      loading.value = false;
    }
  }

  /// --- Import via CSV Upload ---
  Future<void> importCatalog(String filename, List<int> bytes) async {
    try {
      loadingCSV.value = true;
      final store = StoreUserData();
      final tenantId = await store.getTenantId();
      if (tenantId == null) {
        _showError('Error', 'Tenant not found in session');
        return;
      }

      final result = await api.uploadCsv(
        tenantId: tenantId,
        bytes: bytes as Uint8List,
        filename: filename,
      );

      _showSuccess('Success', 'Imported ${result['created']} items');
      await fetchCatalog();
    } catch (e) {
      _showError('Error', 'Import failed: $e');
    } finally {
      loadingCSV.value = false;
    }
  }

  /// --- Add Manual Item with Optional Image ---
  Future<void>  addManual(Map<String, String> fields) async {
    try {
      final store = StoreUserData();
      final tenantId = await store.getTenantId();
      if (tenantId == null) {
        _showError('Error', 'Tenant not found in session');
        return;
      }

      await api.addCatalog(
        tenantId: tenantId,
        name: fields['name'] ?? '',
        itemType: fields['item_type']??'test',//comment test
        category: fields['category'],
        price: fields['price'],
        discount: fields['discount']??'0',
        description: fields['description'],
        imageUrl: fields['image_url'],
        sourceUrl: fields['source_url'],
      );

      await fetchCatalog();
      _showSuccess('Success', 'Item added successfully');
    } catch (e) {
      _showError('Error', 'Add failed: $e');
    }
  }


  /// --- Add Manual Item with Optional Image ---
  Future<void> addManualWithImage(Map<String, String> fields,
      {Uint8List? image, String? filename}) async {
    try {
      final store = StoreUserData();
      final tenantId = await store.getTenantId();
      if (tenantId == null) {
        _showError('Error', 'Tenant not found in session');
        return;
      }

      await api.addCatalogWithMedia(
        tenantId: tenantId,
        itemType: fields['item_type'] ?? 'service',
        name: fields['name'] ?? '',
        description: fields['description'],
        category: fields['category'],
        price: fields['price'],
        discount: fields['discount'],
        sourceUrl: fields['source_url'],
        imageBytes: image,
        imageName: filename,
      );

      await fetchCatalog();
      _showSuccess('Success', 'Item added successfully');
    } catch (e) {
      _showError('Error', 'Add failed: $e');
    }
  }

  /// --- Update Item ---
  Future<void> updateItem(int itemId, Map<String, dynamic> body) async {
    try {
      final payload = {'item_id': itemId, ...body};
      await api.updateCatalogItem(payload);
      await fetchCatalog();
      _showSuccess('Success', 'Changes saved successfully');
    } catch (e) {
      _showError('Error', 'Update failed: $e');
    }
  }

  /// --- Delete Item ---
  Future<void> deleteItem(int itemId) async {
    try {
      await api.deleteCatalogItem(itemId);
      items.removeWhere((el) => el['id'] == itemId);
      _showSuccess('Success', 'Item deleted successfully');
    } catch (e) {
      _showError('Error', 'Delete failed: $e');
    }
  }

  /// --- Bulk Discount ---
  Future<void> bulkDiscount(double discount) async {
    if (selected.isEmpty) {
      _showError('Select', 'Select at least one item');
      return;
    }

    try {
      final store = StoreUserData();
      final tenantId = await store.getTenantId();
      if (tenantId == null) {
        _showError('Error', 'Tenant not found in session');
        return;
      }

      final body = {
        'ids': selected,
        'update': {
          'tenant_id': tenantId,
          'discount': discount,
        }
      };

      await api.bulkUpdate(body);
      await fetchCatalog();
      _showSuccess(
          'Success', 'Applied $discount% discount to ${selected.length} items');
    } catch (e) {
      _showError('Error', 'Bulk update failed: $e');
    }
  }

  // --- Fetch from website
  Future<void> fetchFromWebsite(String url) async {
    analyzing.value = true;
    websiteAnalysisStep.value = 1; // Step 1: analyzing

    final tenantId = await StoreUserData().getTenantId();
    if (tenantId == null) {
      _showError('Error', 'Tenant not found');
      analyzing.value = false;
      return;
    }

    try {
      // --- Start progress animation (in background)
      _runProgressTimer();

      // --- Run the API request
      final response = await api.fetchWebsiteCatalog(tenantId: tenantId, url: url);

      // --- Once API returns, handle result ---
      websiteAnalysisStep.value = 3; // Filtering data

      if (response['ok'] == true) {
        final list =
        (response['Bussiness_Catalog'] as List).cast<Map<String, dynamic>>();
        websiteAnalysisStep.value = 4; // Preparing results
        _showSuccess('Website Parsed', 'Fetched ${list.length} items');
        if (list.isNotEmpty) {
          websiteItems.assignAll(list);
          websiteListVisible.value = true;
        }
      } else {
        _showError('Error', 'Website ingestion failed');
      }
    } catch (e) {
      _showError('Error', 'Website ingestion failed: $e');
    } finally {
      analyzing.value = false;
      websiteAnalysisStep.value = 0;
    }
  }


  Future<void> _runProgressTimer() async {
    const phases = [
      {'step': 1, 'label': 'Analyzing Website', 'duration': 10},
      {'step': 2, 'label': 'Fetching Data', 'duration': 15},
      {'step': 3, 'label': 'Filtering Data', 'duration': 10},
      {'step': 4, 'label': 'Preparing Results', 'duration':10},
    ];

    for (final phase in phases) {
      if (!analyzing.value) break;
      websiteAnalysisStep.value = phase['step'] as int;
      await Future.delayed(Duration(seconds: phase['duration'] as int));
    }
  }



// --- Toggle item selection
  void toggleSelect(int index, bool? selected) {
    if (selected == true) {
      if (!selectedWebsiteItems.contains(index)) selectedWebsiteItems.add(index);
    } else {
      selectedWebsiteItems.remove(index);
    }
  }

// --- Select all items
  void selectAll(bool select) {
    if (select) {
      selectedWebsiteItems.assignAll(List.generate(websiteItems.length, (i) => i));
    } else {
      selectedWebsiteItems.clear();
    }
  }

// --- Save selected (bulk upload)
  Future<void> saveSelectedWebsiteItems() async {
    if (selectedWebsiteItems.isEmpty) {
      _showError('Error', 'No items selected');
      return;
    }
    try {
      loading.value = true;
      final selected = selectedWebsiteItems.map((i) => websiteItems[i]).toList();
      final result = await api.bulkUploadCatalog(selected);
      _showSuccess('Success', 'Uploaded ${result['created']} items');
      websiteItems.clear();
      selectedWebsiteItems.clear();
      websiteListVisible.value = false; // 👈 Hide website list
      await fetchCatalog();
    } catch (e) {
      _showError('Error', 'Bulk upload failed: $e');
    } finally {
      loading.value = false;
    }
  }
}
