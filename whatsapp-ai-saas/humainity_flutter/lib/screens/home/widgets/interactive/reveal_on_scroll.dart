import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset; // slide from this offset

  const RevealOnScroll({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 16),
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.2) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedOpacity(
        duration: widget.duration,
        opacity: _visible ? 1 : 0,
        child: AnimatedSlide(
          duration: widget.duration,
          offset: _visible ? Offset.zero : widget.offset,
          child: widget.child,
        ),
      ),
    );
  }
}
