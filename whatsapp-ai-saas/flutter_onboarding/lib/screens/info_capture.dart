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
  // Manual item form
  final _manualForm = GlobalKey<FormState>();
  final _manualName = TextEditingController();
  final _manualPrice = TextEditingController();
  final _manualDesc = TextEditingController();

  // Website ingestion
  final _site = TextEditingController();

  // UI state
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

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickCsv() async {
    try {
      setState(() => _loadingCsv = true);
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (res == null || res.files.single.bytes == null) {
        return; // user canceled
      }
      final file = res.files.single;
      final bytes = file.bytes as Uint8List;

      // Prefer the newer helper:
      // await widget.api.uploadCsv('/onboarding/items/csv',
      //   filename: file.name, bytes: bytes, fields: {'tenant_id': widget.tenantId});

      // If your current Api has the older signature uploadCsv(path, tenantId, bytes, filename: ...):
      // (Uncomment the one that matches your Api class)
      await widget.api.uploadCsv(
        '/onboarding/items/csv',
        widget.tenantId,
        bytes,
        filename: file.name,
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
      // Prefer JSON (recommended):
      // await widget.api.postJson('/onboarding/items/website', {
      //   'tenant_id': widget.tenantId,
      //   'url': url,
      //   'respect_robots': true,
      //   'max_pages': 10,
      // });

      // If your server expects form-encoded (as in your current Api):
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

    Widget sectionTitle(String text, {IconData? icon}) {
      return Row(
        children: [
          if (icon != null) Icon(icon, size: 18, color: theme.colorScheme.primary),
          if (icon != null) const SizedBox(width: 6),
          Text(text, style: theme.textTheme.titleMedium),
        ],
      );
    }

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

                // CSV upload
                Card(
                  child: ListTile(
                    leading: _loadingCsv
                        ? const SizedBox(
                            width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file),
                    title: const Text('Upload CSV'),
                    subtitle: const Text('Bulk upload: name, price, description, image_url'),
                    onTap: _loadingCsv ? null : _pickCsv,
                    trailing: _loadingCsv ? const SizedBox(width: 24) : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Manual add
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _manualForm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle('Add Manually', icon: Icons.add_box),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _manualName,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'e.g., Premium Consultation',
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _manualPrice,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              hintText: 'e.g., 499',
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Required';
                              final n = num.tryParse(t);
                              if (n == null || n < 0) return 'Enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _manualDesc,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Short details visible to users',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _savingManual ? null : _addManual,
                              icon: _savingManual
                                  ? const SizedBox(
                                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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

                // Website ingestion
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      sectionTitle('Paste Website Link', icon: Icons.language),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _site,
                        decoration: const InputDecoration(
                          labelText: 'https://...',
                          hintText: 'Public site with your services/products',
                        ),
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _ingestingSite ? null : _submitSite(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _ingestingSite ? null : _submitSite,
                          icon: _ingestingSite
                              ? const SizedBox(
                                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
