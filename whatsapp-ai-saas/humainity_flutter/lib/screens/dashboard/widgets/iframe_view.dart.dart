import 'dart:ui_web' as ui_web; // Web-specific
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/providers/session_link_provider.dart';
import 'package:humainise_ai/widgets/ui/app_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:universal_html/html.dart' as html;

class CommonIframeView extends ConsumerStatefulWidget {
  final String title;
  final String targetUrl; // Full URL: http://localhost:8090/app/lead

  const CommonIframeView({
    super.key,
    required this.title,
    required this.targetUrl,
  });

  @override
  ConsumerState<CommonIframeView> createState() => _CommonIframeViewState();
}

class _CommonIframeViewState extends ConsumerState<CommonIframeView> {
  // Unique key to force Iframe rebuilds
  String _viewId = '';
  Future<String>? _urlFuture;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  void _loadUrl() {
    setState(() {
      // Create a unique ID for the platform view registry
      _viewId =
          'iframe-${widget.targetUrl}-${DateTime.now().millisecondsSinceEpoch}';

      // Use the provider to resolve the link (handle session/magic link)
      _urlFuture =
          ref.read(sessionLinkProvider.notifier).getUrlToLoad(widget.targetUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: "Reload",
                onPressed: _loadUrl,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<String>(
                  future: _urlFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Verifying session..."),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.alertTriangle,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Connection Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(LucideIcons.refreshCw, size: 16),
                              label: const Text("Retry"),
                              onPressed: _loadUrl,
                            )
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final url = snapshot.data!;

                      if (kIsWeb) {
                        // WEB IMPLEMENTATION
                        // ignore: undefined_prefixed_name
                        ui_web.platformViewRegistry.registerViewFactory(
                          _viewId,
                          (int viewId) => html.IFrameElement()
                            ..src = url
                            ..style.border = 'none'
                            ..style.width = '100%'
                            ..style.height = '100%',
                        );
                        return HtmlElementView(viewType: _viewId);
                      } else {
                        // MOBILE IMPLEMENTATION (Placeholder)
                        return const Center(
                          child: Text("Mobile WebView not yet implemented"),
                        );
                      }
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
