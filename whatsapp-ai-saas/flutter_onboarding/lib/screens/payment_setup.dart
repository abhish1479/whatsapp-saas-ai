import 'package:flutter/material.dart';
import '../api.dart';

class PaymentSetupScreen extends StatefulWidget {
  final Api api; final String tenantId; final VoidCallback onNext; final VoidCallback onBack;
  const PaymentSetupScreen({required this.api, required this.tenantId, required this.onNext, required this.onBack});
  @override State<PaymentSetupScreen> createState()=> _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  final _upi = TextEditingController();
  final _bank = TextEditingController();
  final _checkout = TextEditingController();

  @override void dispose(){ _upi.dispose(); _bank.dispose(); _checkout.dispose(); super.dispose(); }

  Future<void> _save() async {
    await widget.api.postForm('/onboarding/payments', {
      'tenant_id': widget.tenantId,
      'upi_id': _upi.text.trim(),
      'bank_details': _bank.text.trim(),
      'checkout_link': _checkout.text.trim(),
    });
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text("Payment Setup", style: Theme.of(context).textTheme.headlineSmall),
      TextField(controller: _upi, decoration: const InputDecoration(labelText: "UPI ID")),
      TextField(controller: _bank, decoration: const InputDecoration(labelText: "Bank Account Details")),
      TextField(controller: _checkout, decoration: const InputDecoration(labelText: "Website Checkout Link")),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(onPressed: widget.onBack, child: const Text("Back")),
        ElevatedButton(onPressed: _save, child: const Text("Save & Continue")),
      ])
    ]);
  }
}
