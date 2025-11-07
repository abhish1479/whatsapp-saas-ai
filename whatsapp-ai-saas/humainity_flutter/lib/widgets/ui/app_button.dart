import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

enum AppButtonVariant { primary, outline, ghost, secondary, destructive, link }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isLg;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isLg = false,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isLg ? 32 : 16;
    final double verticalPadding = isLg ? 18 : 14;
    final double fontSize = isLg ? 16 : 14;

    Widget content = isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryForeground),
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
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ],
    );

    switch (variant) {
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            foregroundColor: textColor ?? AppColors.foreground,
            side: BorderSide(color: borderColor ?? AppColors.input),
          ),
          child: content,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            foregroundColor: textColor ?? AppColors.foreground,
            backgroundColor: backgroundColor ?? Colors.transparent,
          ),
          child: content,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            backgroundColor: backgroundColor ?? AppColors.secondary,
            foregroundColor: textColor ?? AppColors.secondaryForeground,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: content,
        );
      default: // AppButtonVariant.primary
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.primaryForeground,
          ).copyWith(
            // Handle gradient
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey;
                if (backgroundColor != null) return backgroundColor;
                return null; // Will use gradient
              },
            ),
            elevation: MaterialStateProperty.all(0),
          ),
          child: Ink(
            decoration: backgroundColor == null ?
            BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(8.0),
            ) : null,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                alignment: Alignment.center,
                child: content
            ),
          ),
        );
    }
  }
}