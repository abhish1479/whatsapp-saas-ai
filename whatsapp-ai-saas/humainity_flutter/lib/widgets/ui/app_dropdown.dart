import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  // FIX: Retaining 'hint' as the actual parameter for a DropdownButtonFormField
  final Widget? hint;

  const AppDropdown({
    super.key,
    required this.labelText,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          // Use the correct parameter name
          hint: hint,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}