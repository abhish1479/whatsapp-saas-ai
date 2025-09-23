import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../api.dart';

class InfoCaptureScreen extends StatefulWidget {
  final Api api;
  final String tenantId;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const InfoCaptureScreen({
    super.key,
    required this.api,
    required this.tenantId,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<InfoCaptureScreen> createState() => _InfoCaptureScreenState();
}

class _InfoCaptureScreenState extends State<InfoCaptureScreen> {
  final _manualForm = GlobalKey<FormState>();
  final _manualName = TextEditingController();
  final _manualPrice = TextEditingController();
  final _manualDesc = TextEditingController();
  final _site = TextEditingController();

  bool _loadingCsv = false;
  bool _savingManual = false;
  bool _ingestingSite = false;

  @override
  void dispose() {
    _manualName.dispose();
    _manualPrice.dispose();
    _manualDesc.dispose();
    _site.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pickCsv() async {
    try {
      setState(() => _loadingCsv = true);
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (res == null || res.files.single.bytes == null) return;
      final file = res.files.single;
      final bytes = file.bytes as Uint8List;

      // new uploadCsv signature: named args
      await widget.api.uploadCsv(
        '/onboarding/items/csv',
        filename: file.name,
        bytes: bytes,
        fields: {'tenant_id': widget.tenantId},
      );

      _toast('CSV uploaded');
    } catch (e) {
      _toast('CSV upload failed: $e');
    } finally {
      if (mounted) setState(() => _loadingCsv = false);
    }
  }

  Future<void> _addManual() async {
    if (!_manualForm.currentState!.validate()) return;
    try {
      setState(() => _savingManual = true);
      await widget.api.postForm('/onboarding/items/manual', {
        'tenant_id': widget.tenantId,
        'name': _manualName.text.trim(),
        'price': _manualPrice.text.trim(),
        'description': _manualDesc.text.trim(),
      });
      _manualName.clear();
      _manualPrice.clear();
      _manualDesc.clear();
      _toast('Item added');
    } catch (e) {
      _toast('Add failed: $e');
    } finally {
      if (mounted) setState(() => _savingManual = false);
    }
  }

  bool _isLikelyUrl(String s) {
    final t = s.trim().toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  Future<void> _submitSite() async {
    final url = _site.text.trim();
    if (!_isLikelyUrl(url)) {
      _toast('Enter a valid URL starting with http:// or https://');
      return;
    }
    try {
      setState(() => _ingestingSite = true);
      await widget.api.postForm('/onboarding/items/website', {
        'tenant_id': widget.tenantId,
        'url': url,
      });
      _toast('Website queued for analysis');
    } catch (e) {
      _toast('Website ingestion failed: $e');
    } finally {
      if (mounted) setState(() => _ingestingSite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth < 900 ? constraints.maxWidth : 900.0;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Add Products / Services', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: _loadingCsv
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file),
                    title: const Text('Upload CSV'),
                    subtitle: const Text('Bulk upload: name, price, description, image_url'),
                    onTap: _loadingCsv ? null : _pickCsv,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _manualForm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Manually', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _manualName,
                            decoration: const InputDecoration(labelText: 'Name', hintText: 'Premium Consultation'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _manualPrice,
                            decoration: const InputDecoration(labelText: 'Price', hintText: '499'),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Required';
                              final n = num.tryParse(t);
                              if (n == null || n < 0) return 'Enter a valid number';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _manualDesc,
                            decoration: const InputDecoration(labelText: 'Description', hintText: 'Short details'),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _savingManual ? null : _addManual,
                              icon: _savingManual
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.add),
                              label: Text(_savingManual ? 'Saving...' : 'Add'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Paste Website Link', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _site,
                        decoration: const InputDecoration(labelText: 'https://...', hintText: 'Public site with your services/products'),
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _ingestingSite ? null : _submitSite(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _ingestingSite ? null : _submitSite,
                          icon: _ingestingSite
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.playlist_add_check),
                          label: Text(_ingestingSite ? 'Queuing...' : 'Analyze Website'),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: widget.onBack, child: const Text('Back')),
                    FilledButton(
                      onPressed: (_loadingCsv || _savingManual || _ingestingSite) ? null : widget.onNext,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
