import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/leads_controller.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  // final ctrl = Get.put(LeadsController());
  final ctrl = Get.find<LeadsController>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final product = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads Hub'),
        actions: [
          IconButton(onPressed: () => Get.toNamed('/campaigns/create'), icon: const Icon(Icons.campaign)),
          IconButton(onPressed: () => Get.toNamed('/monitor/live'), icon: const Icon(Icons.monitor)),
        ],
      ),
      body: Obx(() {
        if (ctrl.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: ctrl.leads.length,
          itemBuilder: (_, i) {
            final L = ctrl.leads[i];
            return ListTile(
              title: Text(L['name'] ?? L['phone'] ?? '-'),
              subtitle: Text("${L['product_service'] ?? '-'} · ${L['status']}"),
              trailing: Text(L['phone'] ?? ''),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddLead(context),
        label: const Text("Add Lead"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _openAddLead(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone*')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: product, decoration: const InputDecoration(labelText: 'Product/Service')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(onPressed: () {
                  ctrl.addLead({
                    "name": name.text.isEmpty ? null : name.text,
                    "phone": phone.text,
                    "email": email.text.isEmpty ? null : email.text,
                    "product_service": product.text.isEmpty ? null : product.text,
                  });
                  Get.back();
                }, child: const Text("Save"))
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}