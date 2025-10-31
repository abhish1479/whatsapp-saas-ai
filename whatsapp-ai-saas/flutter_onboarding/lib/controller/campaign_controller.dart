import 'package:get/get.dart';
import '../api/api.dart';

class CampaignController extends GetxController {
  final Api api;
  CampaignController(this.api);

  var creating = false.obs;
  var lastCampaign = Rxn<Map<String, dynamic>>();

  Future<void> createAndLaunch(Map<String, dynamic> payload) async {
    creating.value = true;
    try {
      final created = await api.createCampaign(payload);
      lastCampaign.value = created;
      await api.launchCampaign(created['id']);
    } finally {
      creating.value = false;
    }
  }
}
