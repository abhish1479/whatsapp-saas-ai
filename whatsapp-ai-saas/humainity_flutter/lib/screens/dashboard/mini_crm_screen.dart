import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/providers/mini_crm_provider.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:universal_html/html.dart' as html;

class MiniCrmScreen extends ConsumerStatefulWidget {
  const MiniCrmScreen({super.key});

  @override
  ConsumerState<MiniCrmScreen> createState() => _MiniCrmScreenState();
}

class _MiniCrmScreenState extends ConsumerState<MiniCrmScreen> {
  // Initialize with a unique key
  String _viewType = 'mini-crm-iframe-${DateTime.now().millisecondsSinceEpoch}';

  void _handleRefresh() {
    // 1. Force a new view ID to destroy the old Iframe
    setState(() {
      _viewType = 'mini-crm-iframe-${DateTime.now().millisecondsSinceEpoch}';
    });
    // 2. Trigger the provider to fetch a FRESH magic link
    ref.read(miniCrmLinkProvider.notifier).refreshLink();
  }

  @override
  Widget build(BuildContext context) {
    final linkAsync = ref.watch(miniCrmLinkProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: "Get New Session",
                onPressed: _handleRefresh,
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Iframe Container
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: linkAsync.when(
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Securely connecting to CRM..."),
                        ],
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertTriangle,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Connection failed: $err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text("Retry Connection"),
                            onPressed: _handleRefresh,
                          )
                        ],
                      ),
                    ),
                    data: (url) {
                      // Register the factory with the unique _viewType
                      // ignore: undefined_prefixed_name
                      ui_web.platformViewRegistry.registerViewFactory(
                        _viewType,
                        (int viewId) => html.IFrameElement()
                          ..src = url
                          ..style.border = 'none'
                          ..style.width = '100%'
                          ..style.height = '100%',
                      );

                      return HtmlElementView(viewType: _viewType);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
