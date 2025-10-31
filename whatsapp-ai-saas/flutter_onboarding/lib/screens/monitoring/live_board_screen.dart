import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/monitoring_controller.dart';

class LiveBoardScreen extends StatefulWidget {
  const LiveBoardScreen({super.key});

  @override
  State<LiveBoardScreen> createState() => _LiveBoardScreenState();
}

class _LiveBoardScreenState extends State<LiveBoardScreen> {
  // final ctrl = Get.put(MonitoringController());
  final ctrl = Get.find<MonitoringController>();
  @override
  void initState() {
    super.initState();
    ctrl.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Monitoring')),
      body: Obx(() {
        final rows = ctrl.rows;
        if (rows.isEmpty) return const Center(child: Text('No live data yet'));
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final r = rows[i];
            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(r['lead_name'] ?? '-'),
              subtitle: Text(r['status'] ?? '-'),
              trailing: Text(r['phone'] ?? ''),
            );
          },
        );
      }),
    );
  }
}
