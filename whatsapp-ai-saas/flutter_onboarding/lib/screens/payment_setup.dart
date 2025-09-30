import 'package:flutter/material.dart';
import '../api/api.dart';

class PaymentSetupScreen extends StatefulWidget {
  final Api api;
  final String tenantId;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PaymentSetupScreen({
    Key? key,
    required this.api,
    required this.tenantId,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  final _upi = TextEditingController();
  final _bank = TextEditingController();
  final _checkout = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _upi.dispose();
    _bank.dispose();
    _checkout.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await widget.api.postForm('/onboarding/payments', {
        'tenant_id': widget.tenantId,
        'upi_id': _upi.text.trim(),
        'bank_details': _bank.text.trim(),
        'checkout_link': _checkout.text.trim(),
      });
      widget.onNext();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving payment details: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                "Payment Setup",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Configure your payment methods to start receiving payments",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentField(
                      controller: _upi,
                      label: "UPI ID",
                      hint: "Enter your UPI ID (e.g., user@paytm)",
                      icon: Icons.account_balance_wallet_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentField(
                      controller: _bank,
                      label: "Bank Account Details",
                      hint: "Enter your bank account details",
                      icon: Icons.account_balance_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentField(
                      controller: _checkout,
                      label: "Website Checkout Link",
                      hint: "Enter your website checkout URL",
                      icon: Icons.link_rounded,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text("Back"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
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
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _save,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(_isLoading ? "Saving..." : "Save & Continue"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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
        ),
      ),
    );
  }

  Widget _buildPaymentField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
