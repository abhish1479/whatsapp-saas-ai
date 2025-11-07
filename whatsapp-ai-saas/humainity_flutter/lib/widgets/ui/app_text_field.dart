import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved; // ADDED
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? icon;
  final String? initialValue;

  const AppTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved, // ADDED
    this.keyboardType,
    this.maxLines = 1,
    this.icon,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved, // ADDED
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText, // FIX: Use hintText property
        prefixIcon: icon != null
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: icon,
        )
            : null,
      ),
    );
  }
}