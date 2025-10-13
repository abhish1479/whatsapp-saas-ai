import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//

import '../../theme/business_info_theme.dart';
import '../utils/color_constant.dart'; // Update path or replace

class CustomWidgets {

  static Widget buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool? enabled,
    String? initialValue,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool obscureText = false,
    int? maxLines = 1,
    int? maxLength, // Enforce max input length
    double labelFontSize = 14.0,
    double hintFontSize = 14.0,
    double errorFontSize = 12.0,
  }) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light;

    // Combine custom formatters with length limiter
    final List<TextInputFormatter> combinedFormatters = [
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      if (inputFormatters != null) ...inputFormatters,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: theme.borderRadius,
        boxShadow: [theme.cardShadow],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: combinedFormatters.isEmpty ? null : combinedFormatters,
        validator: validator,
        enabled: enabled,
        initialValue: initialValue,
        onChanged: onChanged,
        onTap: onTap,
        textInputAction: TextInputAction.next,
        obscureText: obscureText,
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: maxLength != null
            ? MaxLengthEnforcement.enforced
            : MaxLengthEnforcement.none,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide:  BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          labelStyle: TextStyle(
            color: const Color(0xFF002F47), // Replace with ColorConstant.black_002F47 if available
            fontSize: labelFontSize,
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF9D9FA1), // Replace with ColorConstant.grey9d9fa1
            fontSize: hintFontSize,
          ),
          errorStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: errorFontSize,
            height: 1.4, // Adds effective bottom padding after error text
          ),
          errorMaxLines: 2,
          counterText: "", // 👈 Hides the "5/10" character counter
        ),
      ),
    );
  }



  static Widget buildTextField2({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    String? initialValue, // Note: initialValue is typically for non-controlled inputs, TextField uses controller.text
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool obscureText = false,
    int? maxLines = 1,
    int? maxLength, // Enforce max input length
    double labelFontSize = 14.0,
    double hintFontSize = 14.0,
    double errorFontSize = 12.0,
    Color? iconColor,
    Color? enabledBorderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor, // This won't be used directly by TextField, you might manage error state externally
    Color? fillColor,
    Color? labelColor,
    Color? hintColor,
    BorderRadius? customBorderRadius,
    String? errorText,
    FocusNode? focusNode,
  }) {
    final theme = Theme.of(context).extension<BusinessInfoTheme>() ??
        BusinessInfoTheme.light; // Ensure fallback theme exists

    // Determine colors, preferring passed parameters, then theme, then defaults
    final resolvedIconColor = iconColor ?? Colors.blue[600]!;
    final resolvedEnabledBorderColor = enabledBorderColor ?? Colors.grey; // Default outline color
    final resolvedFocusedBorderColor = focusedBorderColor ?? Colors.blue; // Default focused color
    // Use errorBorderColor if errorText is provided, otherwise default
    final resolvedErrorBorderColor = (errorText != null && errorText.isNotEmpty)
        ? errorBorderColor ?? Colors.red
        : resolvedEnabledBorderColor;
    final resolvedFillColor = fillColor ?? Colors.white;
    final resolvedLabelColor = labelColor ?? const Color(0xFF002F47);
    final resolvedHintColor = hintColor ?? const Color(0xFF9D9FA1);
    final resolvedErrorColor = errorBorderColor ?? Colors.red; // Default error color

    // Combine custom formatters with length limiter
    final List<TextInputFormatter> combinedFormatters = [
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      if (inputFormatters != null) ...inputFormatters,
    ];

    return Container(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: combinedFormatters.isEmpty ? null : combinedFormatters,
        // Removed validator
        enabled: enabled,
        // Removed initialValue (use controller.text)
        onChanged: onChanged,
        onTap: onTap,
        textInputAction: TextInputAction.next,
        obscureText: obscureText,
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: maxLength != null
            ? MaxLengthEnforcement.enforced
            : MaxLengthEnforcement.none,
        focusNode: focusNode, // Optional focus node
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: customBorderRadius ?? theme.borderRadius, // Use custom or theme radius
            borderSide: BorderSide(
              color: resolvedEnabledBorderColor,
              width: 1.0, // 1 dp outline
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: customBorderRadius ?? theme.borderRadius,
            borderSide: BorderSide(
              color: resolvedEnabledBorderColor,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: customBorderRadius ?? theme.borderRadius,
            borderSide: BorderSide(
              color: resolvedFocusedBorderColor,
              width: 1.0, // 1 dp outline
            ),
          ),
          // Use errorBorder/focusedErrorBorder based on errorText
          errorBorder: errorText != null && errorText.isNotEmpty
              ? OutlineInputBorder(
            borderRadius: customBorderRadius ?? theme.borderRadius,
            borderSide: BorderSide(
              color: resolvedErrorBorderColor,
              width: 1.0, // 1 dp outline
            ),
          )
              : null, // Don't override if no error
          focusedErrorBorder: errorText != null && errorText.isNotEmpty
              ? OutlineInputBorder(
            borderRadius: customBorderRadius ?? theme.borderRadius,
            borderSide: BorderSide(
              color: resolvedErrorBorderColor,
              width: 1.0, // 1 dp outline
            ),
          )
              : null, // Don't override if no error
          // Filled is handled by fillColor below
          fillColor: resolvedFillColor,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0, // Padding inside the border, to the left of text (after icon if any)
            vertical: 16.0,
          ),
          labelStyle: TextStyle(
            color: resolvedLabelColor,
            fontSize: labelFontSize,
          ),
          hintStyle: TextStyle(
            color: resolvedHintColor,
            fontSize: hintFontSize,
          ),
          // Display error text if provided
          errorText: errorText,
          errorStyle: TextStyle(
            color: resolvedErrorColor, // Use resolved error color
            fontSize: errorFontSize,
            height: 1.4, // Adds effective bottom padding after error text
          ),
          errorMaxLines: 2,
          counterText: "", // 👈 Hides the "5/10" character counter
        ),
      ),
    );
  }


// ───────────────────────
  // DROPDOWN
  // ───────────────────────
  static Widget buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    Color? iconColor,
  }) {
    final theme = BusinessInfoTheme.light;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: theme.borderRadius,
        boxShadow: [theme.cardShadow],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor ?? Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: theme.borderRadius,
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        items: items,
        dropdownColor: Colors.white,
        borderRadius: theme.borderRadius,
      ),
    );
  }

  // ───────────────────────
  // GRADIENT BUTTON (WITH LOADING)
  // ───────────────────────
  static Widget buildGradientButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    IconData? icon,
  }) {
    final theme = BusinessInfoTheme.light;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: theme.borderRadius,
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: theme.buttonGradient,
            borderRadius: theme.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Saving...",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(icon, size: 18, color: Colors.white),
              if (icon != null) const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildCustomButton({
    required VoidCallback? onPressed,
    required String text,
    Color? backgroundColor,        // Optional: custom background color
    Color? textColor = Colors.white, // Optional: custom text/icon color
    bool isLoading = false,
    IconData? icon,
    double borderRadius = 12.0,    // Optional: custom border radius
    double height = 50.0,          // Optional: custom height
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Optional: custom padding
    String? loadingText = "Loading...", // Optional: custom loading text
  }) {
    final theme = BusinessInfoTheme.light;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            // ✅ Use custom color if provided, otherwise use gradient
            color: backgroundColor, // Use this instead of gradient
            gradient: backgroundColor == null ? theme.buttonGradient : null, // Only use gradient if no custom color
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? Colors.blue).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: padding, // ✅ Add custom padding
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                loadingText ?? "Loading...",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}