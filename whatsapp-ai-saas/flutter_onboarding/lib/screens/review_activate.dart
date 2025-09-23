import 'package:flutter/material.dart';
import '../api.dart';

class ReviewActivateScreen extends StatefulWidget {
  final Api api; final String tenantId; final VoidCallback onBack;
  const ReviewActivateScreen({required this.api, required this.tenantId, required this.onBack});
  @override State<ReviewActivateScreen> createState()=> _ReviewActivateScreenState();
}

class _ReviewActivateScreenState extends State<ReviewActivateScreen> {
  bool _loading=false; String? _msg;

  Future<void> _activate() async {
    setState(()=> _loading=true);
    try {
      final res = await widget.api.postForm('/onboarding/activate', {'tenant_id': widget.tenantId});
      setState(()=> _msg = res['activated']==true ? "Agent Activated & Test Message Sent!" : "Activation done");
    } catch (e) {
      setState(()=> _msg = "Activation failed: $e");
    } finally {
      setState(()=> _loading=false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Review & Activate", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text("Review your details above. When you’re ready, activate the WhatsApp Agent."),
        const Spacer(),
        if (_msg != null) Text(_msg!, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: widget.onBack, child: const Text("Back")),
          ElevatedButton(
            onPressed: _loading ? null : _activate,
            child: _loading ? const CircularProgressIndicator() : const Text("Activate Agent"),
          ),
        ])
      ]),
    );
  }
}
