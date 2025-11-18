import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final double hoverElevation;
  final double hoverTranslateY;
  final Duration duration;
  final BorderRadiusGeometry? borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.hoverElevation = 14,
    this.hoverTranslateY = -4,
    this.duration = const Duration(milliseconds: 180),
    this.borderRadius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.identity()
          ..translate(0.0, _hover ? widget.hoverTranslateY : 0.0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: widget.hoverElevation,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
