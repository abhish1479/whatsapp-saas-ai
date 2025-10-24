import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/api.dart';
import '../helper/utils/shared_preference.dart';

class ReviewActivateScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onBack;

  const ReviewActivateScreen({
    Key? key,
    required this.api,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ReviewActivateScreen> createState() => _ReviewActivateScreenState();
}

class _ReviewActivateScreenState extends State<ReviewActivateScreen> {
  bool _loading = false;
  String? _msg;
  bool _isSuccess = false;

  // State for "Talk to Me" functionality
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testPhoneController = TextEditingController();

  Future<void> _activate() async {
    setState(() => _loading = true);
    try {
      final res = await widget.api.postForm('/onboarding/activate',
          {'tenant_id': await StoreUserData().getTenantId()});
      setState(() {
        _msg = res['activated'] == true
            ? "Agent Activated & Test Message Sent!"
            : "Activation done";
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _msg = "Activation failed: $e";
        _isSuccess = false;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  // Function for "Talk to Me" functionality
  void _testAgent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Test WhatsApp Agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter details to test your WhatsApp agent',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _testNameController,
              decoration: InputDecoration(
                hintText: 'Name (optional)',
                prefixIcon: const Icon(Icons.person, color: Color(0xFF8B5CF6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ 10-digit phone number (without country code)
            TextField(
              controller: _testPhoneController,
              decoration: InputDecoration(
                hintText: '9876543210',
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF3B82F6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _testPhoneController.clear();
              _testNameController.clear();
              Navigator.of(ctx).pop();
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
              onPressed: () async {
                FocusScope.of(context).unfocus();

                final phone = _testPhoneController.text.trim();
                final name = _testNameController.text.trim();
                final isValid = RegExp(r'^\d{10}$').hasMatch(phone);

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a valid 10-digit WhatsApp number.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sending test message...'),
                    backgroundColor: Color(0xFF3B82F6),
                  ),
                );

                try {
                  final tenantId = await StoreUserData().getTenantId();

                  // ✅ Proper payload structure
                  final Map<String, dynamic> payload = {
                    "tenant_id": tenantId.toString(), // TODO: Replace with actual tenant ID
                    "recipients": [
                      {
                        "to": "+91$phone",
                        "name": name.isEmpty ? "" : name,
                      }
                    ]
                  };

                  await widget.api.postJson(
                      '/conversation/conversations/talk_to_me', payload);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test message sent to +91$phone'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send test: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } finally {
                  _testPhoneController.clear();
                  _testNameController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Send Test'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack(); // go to previous onboarding step
        return false;
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Review & Activate",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Review your configuration and activate your WhatsApp Agent",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Ready to Launch",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Your WhatsApp Agent is configured and ready to go. Click the button below to activate it and start engaging with your customers.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 32),
                      if (_msg != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isSuccess
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isSuccess
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isSuccess ? Icons.check_circle : Icons.error,
                                color: _isSuccess
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _msg!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _isSuccess
                                        ? const Color(0xFF166534)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text("Back"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),*/

                  // Added "Talk to Me" button here
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _testAgent,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.message, size: 18),
                        label: Text("Talk to Me"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _activate,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.rocket_launch, size: 18),
                        label: Text(_loading ? "Launching..." : "Launch"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
