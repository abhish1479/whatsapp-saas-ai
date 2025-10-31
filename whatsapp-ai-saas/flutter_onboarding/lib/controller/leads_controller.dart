import 'package:get/get.dart';
import '../api/api.dart';

class LeadsController extends GetxController {
  final Api api;
  LeadsController(this.api);
  var leads = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  final int tenantId = 1;

  Future<void> fetch() async {
    loading.value = true;
    try {
      // leads.value = await api.listLeads(tenantId);
      final rawData = await api.listLeads(tenantId);
      leads.value = rawData
          .where((item) => item is Map<String, dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load leads: ${e.toString()}");
      leads.value = [];
    } finally {
      loading.value = false;
    }
  }

  

  Future<void> addLead(Map<String, dynamic> lead) async {
    loading.value = true;
    try {
      lead['tenant_id'] = tenantId;
      final created = await api.createLead(lead);
      leads.insert(0, created);
    } finally {
      loading.value = false;
    }
  }
}
