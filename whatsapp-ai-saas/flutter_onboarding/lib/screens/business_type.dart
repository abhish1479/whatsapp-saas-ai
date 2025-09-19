import 'package:flutter/material.dart';
import '../api.dart';

class BusinessTypeScreen extends StatelessWidget {
  final Api api; final String tenantId; final VoidCallback onNext; final VoidCallback onBack;
  const BusinessTypeScreen({required this.api, required this.tenantId, required this.onNext, required this.onBack});

  Future<void> _choose(BuildContext ctx, String type) async {
    await api.postForm('/onboarding/type', {'tenant_id': tenantId, 'business_type': type});
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _TypeTile(icon: Icons.shopping_bag, label: "Products", onTap: ()=> _choose(context,'products')),
      _TypeTile(icon: Icons.build, label: "Services", onTap: ()=> _choose(context,'services')),
      _TypeTile(icon: Icons.school, label: "Professional", onTap: ()=> _choose(context,'professional')),
      _TypeTile(icon: Icons.more_horiz, label: "Other", onTap: ()=> _choose(context,'other')),
    ];
    return Column(
      children: [
        Expanded(child: GridView.count(padding: const EdgeInsets.all(16), crossAxisCount: 2, children: tiles)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: onBack, child: const Text("Back")),
          const SizedBox(width: 8),
        ])
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _TypeTile({required this.icon, required this.label, required this.onTap});
  @override Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(onTap: onTap, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 48), const SizedBox(height: 8), Text(label)
    ]))),
  );
}
