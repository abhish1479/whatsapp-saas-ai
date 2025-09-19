import 'package:flutter/material.dart';
import '../api.dart';

class WorkflowSetupScreen extends StatefulWidget {
  final Api api; final String tenantId; final VoidCallback onNext; final VoidCallback onBack;
  const WorkflowSetupScreen({required this.api, required this.tenantId, required this.onNext, required this.onBack});
  @override State<WorkflowSetupScreen> createState()=> _WorkflowSetupScreenState();
}

class _WorkflowSetupScreenState extends State<WorkflowSetupScreen> {
  bool askName=true, askLocation=false, offerPayment=true;
  String template = "Lead capture → Qualification → Payment";

  Future<void> _save() async {
    await widget.api.postForm('/onboarding/workflow', {
      'tenant_id': widget.tenantId,
      'template': template,
      'ask_name': askName.toString(),
      'ask_location': askLocation.toString(),
      'offer_payment': offerPayment.toString(),
    });
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text("Conversation Workflow", style: Theme.of(context).textTheme.headline6),
      SwitchListTile(title: const Text("Ask for Customer Name"), value: askName, onChanged:(v)=> setState(()=>askName=v)),
      SwitchListTile(title: const Text("Ask for Location"), value: askLocation, onChanged:(v)=> setState(()=>askLocation=v)),
      SwitchListTile(title: const Text("Offer Payment Link"), value: offerPayment, onChanged:(v)=> setState(()=>offerPayment=v)),
      DropdownButtonFormField<String>(
        value: template,
        items: [
          "Lead capture → Qualification → Payment",
          "Product Q&A → Cart → Payment",
          "Service booking → Confirmation → Reminder",
        ].map((e)=> DropdownMenuItem(value:e, child: Text(e))).toList(),
        onChanged:(v)=> setState(()=> template = v ?? template),
        decoration: const InputDecoration(labelText: "Conversation Template"),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(onPressed: widget.onBack, child: const Text("Back")),
        ElevatedButton(onPressed: _save, child: const Text("Save & Continue")),
      ])
    ]);
  }
}
