import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../api.dart';

class InfoCaptureScreen extends StatefulWidget {
  final Api api; final String tenantId; final VoidCallback onNext; final VoidCallback onBack;
  const InfoCaptureScreen({required this.api, required this.tenantId, required this.onNext, required this.onBack});
  @override State<InfoCaptureScreen> createState()=> _InfoCaptureScreenState();
}

class _InfoCaptureScreenState extends State<InfoCaptureScreen> {
  final _manualName = TextEditingController();
  final _manualPrice = TextEditingController();
  final _manualDesc = TextEditingController();
  final _site = TextEditingController();

  @override void dispose(){ _manualName.dispose(); _manualPrice.dispose(); _manualDesc.dispose(); _site.dispose(); super.dispose(); }

  Future<void> _pickCsv() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'], withData: true);
    if (res != null && res.files.single.bytes != null) {
      final bytes = res.files.single.bytes as Uint8List;
      await widget.api.uploadCsv('/onboarding/items/csv', widget.tenantId, bytes, filename: res.files.single.name);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CSV uploaded")));
    }
  }

  Future<void> _addManual() async {
    await widget.api.postForm('/onboarding/items/manual', {
      'tenant_id': widget.tenantId,
      'name': _manualName.text.trim(),
      'price': _manualPrice.text.trim(),
      'description': _manualDesc.text.trim(),
    });
    _manualName.clear(); _manualPrice.clear(); _manualDesc.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item added")));
  }

  Future<void> _submitSite() async {
    await widget.api.postForm('/onboarding/items/website', {
      'tenant_id': widget.tenantId,
      'url': _site.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Website queued for analysis")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Add Products / Services", style: Theme.of(context).textTheme.headline6),
        const SizedBox(height: 8),
        Card(child: ListTile(
          leading: const Icon(Icons.upload_file), title: const Text("Upload CSV"),
          subtitle: const Text("Bulk upload with name, price, description, image_url"),
          onTap: _pickCsv,
        )),
        const SizedBox(height: 8),
        Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Add Manually"),
            TextField(controller: _manualName, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: _manualPrice, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: _manualDesc, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: _addManual, icon: const Icon(Icons.add), label: const Text("Add")),
          ]),
        )),
        const SizedBox(height: 8),
        Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Paste Website Link"),
            TextField(controller: _site, decoration: const InputDecoration(labelText: "https://...")),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: _submitSite, icon: const Icon(Icons.language), label: const Text("Analyze Website")),
          ]),
        )),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: widget.onBack, child: const Text("Back")),
          ElevatedButton(onPressed: widget.onNext, child: const Text("Continue")),
        ])
      ],
    );
  }
}
