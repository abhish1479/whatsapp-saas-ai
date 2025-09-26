import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../api.dart';

class BusinessInfoCaptureScreen extends StatefulWidget {
  final Api api;
  final String tenantId;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const BusinessInfoCaptureScreen({
    super.key,
    required this.api,
    required this.tenantId,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BusinessInfoCaptureScreen> createState() => _InfoCaptureScreenState();
}

class _InfoCaptureScreenState extends State<BusinessInfoCaptureScreen> {
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

  Future<bool> _validateCsv(List<int> bytes) async {
    try {
      final csvString = utf8.decode(bytes);
      final List<List<String>> rows = const CsvToListConverter(
        shouldParseNumbers: false,
        allowInvalid: false,
      ).convert(csvString);

      if (rows.isEmpty) {
        _toast('CSV file is empty');
        return false;
      }

      // Normalize headers: trim and lowercase
      final List<String> headers =
          rows.first.map((e) => e.trim().toLowerCase()).toList();

      final expectedHeaders = ['name', 'price', 'description', 'image_url'];
      final missing = <String>[];

      for (final required in expectedHeaders) {
        if (!headers.contains(required)) {
          missing.add(required);
        }
      }

      if (missing.isNotEmpty) {
        _toast('Missing required columns: ${missing.join(', ')}');
        return false;
      }

      // Validate first few data rows (skip header)
      final int sampleRows = 5;
      for (int i = 1; i < rows.length && i <= sampleRows; i++) {
        final row = rows[i];
        if (row.length < 4) continue; // skip malformed short rows

        // Validate price
        final priceStr = row[headers.indexOf('price')].trim();
        if (priceStr.isEmpty) {
          _toast('Price is required in row ${i + 1}');
          return false;
        }
        final price = num.tryParse(priceStr);
        if (price == null || price < 0) {
          _toast('Invalid price in row ${i + 1}: "$priceStr"');
          return false;
        }

        // Validate name
        final name = row[headers.indexOf('name')].trim();
        if (name.isEmpty) {
          _toast('Name is required in row ${i + 1}');
          return false;
        }
      }

      return true;
    } catch (e) {
      _toast('Invalid CSV format: $e');
      return false;
    }
  }

  Future<void> _pickCsv() async {
    if (_loadingCsv) return;

    try {
      setState(() => _loadingCsv = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _toast('No file selected');
        return;
      }

      final platformFile = result.files.single;

      // On all platforms (including web), `withData: true` ensures bytes are available
      final bytes = platformFile.bytes;
      if (bytes == null) {
        _toast('Failed to read file. Please try again or use a smaller file.');
        return;
      }

      // Validate CSV content before uploading
      final isValid = await _validateCsv(bytes);
      if (!isValid) {
        return;
      }

      // Perform upload
      final response = await widget.api.uploadCsv(
        '/onboarding/items/csv',
        filename: platformFile.name,
        bytes: bytes,
      );

      // Handle success response
      final message = response['message'] ?? 'CSV uploaded successfully';
      final count = response['count'];
      final successMessage =
          count != null ? '$message ($count items added)' : message;

      _toast(successMessage);
    } catch (e, stackTrace) {
      debugPrint('CSV upload error: $e\n$stackTrace');

      String errorMessage = 'Upload failed. Please try again.';
      if (e is Exception) {
        final message = e.toString().replaceAll('Exception: ', '').trim();
        // Try to extract user-friendly message
        if (message.contains('statusCode')) {
          errorMessage = 'Upload failed. Server error.';
        } else if (message.length > 100) {
          errorMessage = 'Upload failed: ${message.substring(0, 100)}...';
        } else {
          errorMessage = 'Upload failed: $message';
        }
      }

      _toast(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _loadingCsv = false);
      }
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
    const primaryColor = Color(0xFF3B82F6);
    const secondaryColor = Color(0xFF8B5CF6);
    const surfaceColor = Color(0xFFFAFAFA);
    const cardColor = Colors.white;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth < 900 ? constraints.maxWidth : 900.0;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Products & Services',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose how you\'d like to add your offerings',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _loadingCsv ? null : _pickCsv,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _loadingCsv
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.upload_file_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upload CSV File',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bulk upload: name, price, description, image_url',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: const Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _manualForm,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add Manually',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            TextFormField(
                              controller: _manualName,
                              decoration: InputDecoration(
                                labelText: 'Product/Service Name',
                                hintText: 'Premium Consultation',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _manualPrice,
                              decoration: InputDecoration(
                                labelText: 'Price',
                                hintText: '499',
                                prefixText: '\$ ',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Required';
                                final n = num.tryParse(t);
                                if (n == null || n < 0)
                                  return 'Enter a valid number';
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _manualDesc,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Brief description of your offering',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _savingManual ? null : _addManual,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: _savingManual
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.add_rounded, color: Colors.white),
                                  label: Text(
                                    _savingManual ? 'Adding...' : 'Add Item',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: secondaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.language_rounded,
                                  color: secondaryColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Analyze Website',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'ll automatically extract products and services from your website',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: _site,
                            decoration: InputDecoration(
                              labelText: 'Website URL',
                              hintText: 'https://yourwebsite.com',
                              prefixIcon: Icon(Icons.link_rounded, color: secondaryColor),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: secondaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            keyboardType: TextInputType.url,
                            onSubmitted: (_) => _ingestingSite ? null : _submitSite(),
                          ),
                          const SizedBox(height: 20),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [secondaryColor, primaryColor],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: secondaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _ingestingSite ? null : _submitSite,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: _ingestingSite
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                                label: Text(
                                  _ingestingSite ? 'Analyzing...' : 'Analyze Website',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FilledButton.icon(
                            onPressed: (_loadingCsv || _savingManual || _ingestingSite)
                                ? null
                                : widget.onNext,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            label: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
