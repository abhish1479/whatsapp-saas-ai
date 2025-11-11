import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Using prefixIcon property of InputDecoration directly
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: prefixIcon,
              )
            : null,
        // The existing 'icon' property is likely intended for the suffix/end
        suffixIcon: icon,
      ),
    );
  }
}
