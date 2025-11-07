import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

// ADDED enum for badge styling
enum AppBadgeVariant { primary, secondary, outline }

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Border? border;
  final Widget? icon;
  final AppBadgeVariant variant; // ADDED

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.border,
    this.icon,
    this.variant = AppBadgeVariant.primary, // ADDED default
  });

  @override
  Widget build(BuildContext context) {
    // UPDATED logic to handle variant
    Color defaultBackgroundColor = AppColors.primary;
    Color defaultTextColor = AppColors.primaryForeground;
    Border? defaultBorder = border;

    switch (variant) {
      case AppBadgeVariant.primary:
        defaultBackgroundColor = AppColors.primary;
        defaultTextColor = AppColors.primaryForeground;
        break;
      case AppBadgeVariant.secondary:
        defaultBackgroundColor = AppColors.secondary;
        defaultTextColor = AppColors.secondaryForeground;
        break;
      case AppBadgeVariant.outline:
        defaultBackgroundColor = Colors.transparent;
        defaultTextColor = AppColors.foreground;
        defaultBorder = Border.all(color: AppColors.border, width: 1);
        break;
    }

    // Fallback to explicit color/border if provided
    final effectiveBackgroundColor = color ?? defaultBackgroundColor;
    final effectiveTextColor = textColor ?? defaultTextColor;
    final effectiveBorder = border ?? defaultBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: effectiveBorder, // UPDATED
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: effectiveTextColor,
            ),
          ),
        ],
      ),
    );
  }
}