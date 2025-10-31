import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/campaign_controller.dart';

class CampaignCreateScreen extends StatefulWidget {
  const CampaignCreateScreen({super.key});

  @override
  State<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends State<CampaignCreateScreen> {
  // final ctrl = Get.put(CampaignController());
  final ctrl = Get.find<CampaignController>();
  final name = TextEditingController();
  final templateId = TextEditingController();
  final defaultPitch = TextEditingController();
  final tenantId = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: tenantId, decoration: const InputDecoration(labelText: 'Tenant ID')),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Campaign name*')),
            TextField(controller: templateId, decoration: const InputDecoration(labelText: 'Template ID (optional)')),
            TextField(controller: defaultPitch, decoration: const InputDecoration(labelText: 'Default pitch (optional)')),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton.icon(
                  onPressed: ctrl.creating.value
                      ? null
                      : () async {
                          await ctrl.createAndLaunch({
                            "tenant_id": int.tryParse(tenantId.text) ?? 1,
                            "name": name.text,
                            "template_id": templateId.text.isEmpty ? null : int.tryParse(templateId.text),
                            "default_pitch": defaultPitch.text.isEmpty ? null : defaultPitch.text
                          });
                          if (context.mounted) Get.snackbar("Campaign", "Created & launched");
                        },
                  icon: const Icon(Icons.rocket_launch),
                  label: ctrl.creating.value ? const Text("Launching...") : const Text("Create & Launch"),
                )),
          ],
        ),
      ),
    );
  }
}
