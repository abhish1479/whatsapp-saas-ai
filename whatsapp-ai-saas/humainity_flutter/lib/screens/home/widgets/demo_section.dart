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
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('allowfullscreen', 'true');

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: const HtmlElementView(viewType: _viewType),
        );
      },
    );
  }
}
