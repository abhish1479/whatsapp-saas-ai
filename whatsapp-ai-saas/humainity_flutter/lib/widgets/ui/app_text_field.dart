import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? icon; // This is typically for suffixIcon or old style icon
  final Widget? prefixIcon; // <--- ADDED: Dedicated prefix icon
  final String? initialValue;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.keyboardType,
    this.maxLines = 1,
    this.icon,
    this.prefixIcon, // <--- ADDED to constructor
    this.initialValue,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled, // ✅ Pass to Flutter widget
      style: TextStyle(
        color: enabled ? AppColors.foreground : AppColors.mutedForeground,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: !enabled, // Optional: grey background when disabled
        fillColor: enabled ? null : AppColors.muted.withOpacity(0.3),
        prefixIcon: prefixIcon != null
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: prefixIcon, // Keep icon colored or grey it out
        )
            : null,
        suffixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
