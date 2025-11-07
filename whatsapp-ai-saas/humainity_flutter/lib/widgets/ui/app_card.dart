import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final BoxBorder? border; // ADDED

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.border, // ADDED
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).cardTheme;

    Color defaultBorderColor = AppColors.border;
    if (theme.shape is RoundedRectangleBorder) {
      final side = (theme.shape as RoundedRectangleBorder).side;
      defaultBorderColor = side.color;
    }

    // Determine the border to use
    final effectiveBorder = border ??
        Border.all(
          color: borderColor ?? defaultBorderColor,
        );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.color ?? AppColors.card,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        border: effectiveBorder, // UPDATED
        boxShadow: [
          if (elevation != null)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation!,
              offset: Offset(0, elevation! / 2),
            )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}