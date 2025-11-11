import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

// Use this enum for standard button variants.
enum AppButtonVariant { primary, outline, ghost, secondary, destructive, link }

// Use this enum for simplified styling requested by the user, mapping to standard variants.
enum AppButtonStyle { primary, secondary, tertiary }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final Widget? icon;
  final bool isLoading;
  final bool isLg;
  final Color? textColor;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry?
      padding; // <--- This parameter is now correctly defined
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.isLg = false,
    this.textColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.padding, // <--- Added to constructor
    this.width,
  });

  // Helper method to resolve the standard variant from the simplified style
  AppButtonVariant _resolveVariant() {
    switch (style) {
      case AppButtonStyle.primary:
        return AppButtonVariant.primary;
      case AppButtonStyle.secondary:
        return AppButtonVariant.secondary;
      case AppButtonStyle.tertiary:
        // Tertiary often means low emphasis, similar to an outlined style.
        return AppButtonVariant.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variant = _resolveVariant();

    // Resolve colors: use specific parameters first, then fallback to generic 'color'
    final resolvedBackgroundColor = backgroundColor ?? color;
    final resolvedBorderColor = borderColor ?? color;

    // Calculate default padding if none is provided
    final double defaultHorizontalPadding = isLg ? 32 : 16;
    final double defaultVerticalPadding = isLg ? 18 : 14;
    final EdgeInsetsGeometry defaultPadding = EdgeInsets.symmetric(
        horizontal: defaultHorizontalPadding, vertical: defaultVerticalPadding);

    // Use provided padding or default padding
    final effectivePadding = padding ?? defaultPadding;

    final double fontSize = isLg ? 16 : 14;

    Widget content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // Using AppColors.primaryForeground for contrast on colored buttons
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryForeground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ],
          );

    // Common properties for ElevatedButton (used for Primary and Secondary)
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: variant == AppButtonVariant.outline
          ? BorderSide(color: resolvedBorderColor ?? AppColors.input)
          : BorderSide.none,
    );

    switch (variant) {
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero, // Padding is handled inside the Container
            foregroundColor: textColor ?? AppColors.foreground,
            side: BorderSide(color: resolvedBorderColor ?? AppColors.input),
            shape: shape,
          ),
          child: Container(
            width: width,
            padding: effectivePadding, // <-- Uses custom/default padding
            alignment: Alignment.center,
            child: content,
          ),
        );

      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: effectivePadding, // <-- Uses custom/default padding
            foregroundColor: textColor ?? AppColors.foreground,
            backgroundColor: resolvedBackgroundColor ?? Colors.transparent,
          ),
          child: content,
        );

      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: effectivePadding, // <-- Uses custom/default padding
            backgroundColor: resolvedBackgroundColor ?? AppColors.secondary,
            foregroundColor: textColor ?? AppColors.secondaryForeground,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: shape,
          ),
          child: content,
        );

      default: // AppButtonVariant.primary
        // Primary button uses DecoratedBox to handle gradient
        return DecoratedBox(
          decoration: resolvedBackgroundColor == null
              ? BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(8.0),
                )
              : BoxDecoration(
                  color: resolvedBackgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              // Make the button transparent so the DecoratedBox background/gradient shows through
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              padding:
                  EdgeInsets.zero, // Padding is handled in the child Container
              foregroundColor: textColor ?? AppColors.primaryForeground,
              shape: shape,
            ),
            child: Container(
              width: width,
              padding: effectivePadding, // <-- Uses custom/default padding
              alignment: Alignment.center,
              child: content,
            ),
          ),
        );
    }
  }
}
