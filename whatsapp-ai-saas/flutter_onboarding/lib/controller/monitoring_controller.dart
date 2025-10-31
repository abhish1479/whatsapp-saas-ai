import 'package:get/get.dart';
import '../api/api.dart';

class MonitoringController extends GetxController {
  final Api api;
  MonitoringController(this.api);
  var rows = <Map<String, dynamic>>[].obs;
  final int tenantId = 1;

  Future<void> fetch() async {
     try {
      final rawData = await api.liveBoard(tenantId);
      rows.value = rawData
          .where((item) => item is Map<String, dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load monitoring data: ${e.toString()}");
      rows.value = []; // Reset on error
    }
  }
}
