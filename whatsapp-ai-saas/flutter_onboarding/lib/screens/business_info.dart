import 'package:flutter/material.dart';
import '../api.dart';

class BusinessInfoScreen extends StatefulWidget {
  final Api api; final String tenantId; final VoidCallback onNext;
  const BusinessInfoScreen({required this.api, required this.tenantId, required this.onNext});
  @override State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _lang = 'en';

  @override void dispose(){ _name.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await widget.api.postForm('/onboarding/business', {
      'tenant_id': widget.tenantId,
      'business_name': _name.text.trim(),
      'owner_phone': _phone.text.trim(),
      'language': _lang,
    });
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Business Information", style: Theme.of(context).textTheme.headlineSmall),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: "Business Name"),
            validator: (v)=> v==null||v.isEmpty ? "Required" : null,
          ),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(labelText: "Owner Phone (WhatsApp)"),
            keyboardType: TextInputType.phone,
          ),
          DropdownButtonFormField<String>(
            value: _lang,
            decoration: const InputDecoration(labelText: "Preferred Language"),
            items: const [
              DropdownMenuItem(value:'en', child: Text('English')),
              DropdownMenuItem(value:'hi', child: Text('Hindi')),
            ],
            onChanged: (v)=> setState(()=> _lang = v??'en'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _submit, child: const Text("Save & Continue")),
        ],
      ),
    );

    return LayoutBuilder(builder: (c,con){
      if (con.maxWidth > 900) {
        return Row(children: [
          Expanded(child: form),
          Expanded(child: Center(child: Text("Live WhatsApp preview will appear here"))),
        ]);
      }
      return form;
    });
  }
}
