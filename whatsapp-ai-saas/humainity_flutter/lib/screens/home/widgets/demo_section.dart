import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class DemoSection extends StatelessWidget {
  const DemoSection({super.key});

  static const String _viewType = 'demo-iframe-view';

  static void registerIframe() {
    if (!kIsWeb) return;

    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://humainise.lovable.app/godrej-presentation'
          ..style.border = 'none'
          ..style.width = '100vw'
          ..style.height = '100vh'
          ..style.position = 'fixed'
          ..style.top = '0'
          ..style.left = '0';

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text("Demo available on web only"),
      );
    }

    return const SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
