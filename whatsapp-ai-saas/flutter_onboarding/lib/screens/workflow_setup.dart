import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leadbot_client/helper/utils/app_utils.dart';
import '../api/api.dart';
import '../controller/onboarding_controller.dart';
import '../helper/utils/shared_preference.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WorkflowSetupScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const WorkflowSetupScreen(
      {required this.api, required this.onNext, required this.onBack});

  @override
  State<WorkflowSetupScreen> createState() => _WorkflowSetupScreenState();
}

class _WorkflowSetupScreenState extends State<WorkflowSetupScreen> {
  final controller = Get.find<OnboardingController>();
  bool askName = true, askLocation = false, offerPayment = false;
  String template = "Lead capture → Qualification → Payment";
  bool _isLoading = false;

  // Payment state (saved when user confirms the modal)
  String upiId = '';
  Uint8List? qrCodeBytes;
  String qrCodeUrl = '';

  @override
  void initState() {
    super.initState();
    _loadExistingWorkflowData();
  }

  Future<void> _loadExistingWorkflowData() async {
    final tid = await StoreUserData().getTenantId();
    await controller.fetchOnboardingData(tid);
    final data = controller.data?.workflow;
    if (data != null) {
      setState(() {
        askName = data.askName ?? true;
        askLocation = data.askLocation ?? false;
        offerPayment = data.offerPayment ?? false;
        upiId = data.upiId ?? '';
        qrCodeUrl = data.qrImageUrl ?? '';
        template = data.template ?? template;
      });
    }
  }

  Future<void> _save() async {
    if (offerPayment) {
      if (upiId.isEmpty && qrCodeUrl.isEmpty) {
        AppUtils.showError('Error', 'Please enter your payment details');
        return;
      }
    }
    setState(() => _isLoading = true);
    try {
      final tid = await StoreUserData().getTenantId();
      final result = await controller.submitWorkflowSetup(
        tenantId: tid!,
        template: template,
        askName: askName,
        askLocation: askLocation,
        offerPayment: offerPayment,
        upiId: upiId,
        qrImageUrl: qrCodeUrl,
      );

      if (result['ok'] == true) {
        widget.onNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['detail'] ?? 'Failed to save workflow'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving workflow: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _showPaymentDialog() async {
    final upiCtrl = TextEditingController(text: upiId ?? '');
    Uint8List? tempBytes = qrCodeBytes;
    String? tempUrl = qrCodeUrl;

    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: true, // tapping outside counts as cancel
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Payment Setup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your UPI details for quick payments.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // UPI ID input
                TextField(
                  controller: upiCtrl,
                  decoration: InputDecoration(
                    hintText: 'example@upi',
                    labelText: 'UPI ID',
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF3B82F6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                // QR upload area
                InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final img =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (img == null) return;

                    final bytes = await img.readAsBytes();

                    // Update modal preview
                    setState(() => tempBytes = bytes);

                    try {
                      final uploadedPath =
                          await widget.api.uploadImage(bytes, img.name);

                      setState(() => tempUrl = uploadedPath);

                      // Optional: Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR uploaded successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        tempBytes = null;
                        tempUrl = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('QR upload failed: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tempUrl != null
                                ? 'QR uploaded'
                                : 'Upload QR Code (image)',
                            style: TextStyle(
                              color: tempUrl != null
                                  ? Colors.green[700]
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (tempBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      tempBytes!,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(null);
              },
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final entered = upiCtrl.text.trim();

                  if (entered.isEmpty && tempUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please provide either a UPI ID or upload a QR Code.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  if (entered.isNotEmpty &&
                      !RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(entered)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enter a valid UPI ID format (e.g. name@upi).'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    upiId = entered.isEmpty ? '' : entered;
                    qrCodeUrl = tempUrl ?? '';
                    qrCodeBytes = tempBytes;
                    offerPayment = true;
                  });

                  Navigator.of(ctx).pop({
                    'upiId': entered.isEmpty ? '' : entered,
                    'qrUrl': tempUrl,
                    'bytes': tempBytes,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Conversation Workflow",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Configure how your chatbot interacts with customers",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),

          // Card: Customer Info
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Information",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 16),
                _buildEnhancedSwitchTile(
                  "Ask for Customer Name",
                  "Collect customer names for personalization",
                  askName,
                  (v) => setState(() => askName = v),
                  Icons.person_outlined,
                ),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),
                _buildEnhancedSwitchTile(
                  "Ask for Location",
                  "Gather location data for better service",
                  askLocation,
                  (v) => setState(() => askLocation = v),
                  Icons.location_on_outlined,
                ),
                const Divider(height: 32, color: Color(0xFFE2E8F0)),

                // Offer payment: open modal on ON, revert to OFF if cancelled
                _buildEnhancedSwitchTile(
                  "Offer Payment Link",
                  "Do you want to offer payment link if conversion happens?",
                  offerPayment,
                  (v) async {
                    if (v == true) {
                      // Try to collect details
                      final result = await _showPaymentDialog();
                      if (result == null) {
                        // User cancelled → revert toggle
                        setState(() => offerPayment = false);
                      } else {
                        setState(() {
                          offerPayment = true;
                          upiId = result['upiId'] as String;
                          qrCodeUrl = result['qrUrl'] as String;
                          qrCodeBytes = result['bytes'] as Uint8List?;
                        });
                      }
                    } else {
                      setState(() {
                        offerPayment = false;
                        upiId = '';
                        qrCodeUrl = '';
                        qrCodeBytes = null;
                      });
                    }
                  },
                  Icons.payment_outlined,
                ),
                // ✅ FIXED: Prioritize qrCodeBytes over qrCodeUrl for preview
                if (offerPayment &&
                    (upiId != null ||
                        qrCodeUrl != null ||
                        qrCodeBytes != null)) ...[
                  // Changed condition
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Prioritize Image.memory if qrCodeBytes is available
                        if (qrCodeBytes != null)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.black87,
                                  insetPadding: const EdgeInsets.all(20),
                                  child: InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        qrCodeBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                qrCodeBytes!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        // Then try Image.network if qrCodeUrl is available but qrCodeBytes is not
                        else if (qrCodeUrl != null)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.black87,
                                  insetPadding: const EdgeInsets.all(20),
                                  child: InteractiveViewer(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        qrCodeUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(Icons.broken_image,
                                              color: Colors.white70, size: 80),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                qrCodeUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.qr_code_2,
                                    size: 48,
                                    color: Colors.grey),
                              ),
                            ),
                          )
                        // Show placeholder if neither is available
                        else
                          const Icon(Icons.qr_code_2,
                              size: 48, color: Colors.grey),

                        const SizedBox(width: 16),

                        // 🧾 Payment Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Payment Info",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (upiId != null && upiId!.isNotEmpty)
                                Text(
                                  upiId!,
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                )
                              else if (qrCodeBytes != null ||
                                  qrCodeUrl != null) // Changed condition
                                const Text(
                                  "QR Code uploaded",
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              else
                                const Text(
                                  "No payment info",
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ✏️ Edit
                        TextButton.icon(
                          onPressed: () async {
                            final result = await _showPaymentDialog();
                            if (result != null) {
                              setState(() {
                                upiId = result['upiId'] as String;
                                qrCodeUrl = result['qrUrl'] as String;
                                qrCodeBytes = result['bytes'] as Uint8List?;
                              });
                            }
                          },
                          icon: const Icon(Icons.edit,
                              size: 16, color: Color(0xFF3B82F6)),
                          label: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                        ),

                        // 🗑 Remove
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 20),
                          tooltip: "Remove payment info",
                          onPressed: () {
                            setState(() {
                              upiId = '';
                              qrCodeUrl = '';
                              qrCodeBytes = null;
                              offerPayment = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Payment info removed."),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Card: Template
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Conversation Template",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: template,
                      isExpanded: true,
                      items: const [
                        "Lead capture → Qualification → Payment",
                        "Product Q&A → Cart → Payment",
                        "Service booking → Confirmation → Reminder",
                      ]
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  overflow: kIsWeb
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => template = v ?? template),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF64748B)),

                      // 👇 Add this
                      selectedItemBuilder: (context) {
                        return [
                          "Lead capture → Qualification → Payment",
                          "Product Q&A → Cart → Payment",
                          "Service booking → Confirmation → Reminder",
                        ].map((e) {
                          return Text(
                            e,
                            overflow: kIsWeb
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    )),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text("Back"),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: const Color(0xFF64748B),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white, size: 18),
                  label: Text(
                    _isLoading ? "Saving..." : "Save & Continue",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFF3B82F6).withOpacity(0.1)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF94A3B8),
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}
