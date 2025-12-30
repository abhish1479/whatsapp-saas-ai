import 'package:flutter/material.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  // This is the actual Widget used as the hint in the DropdownButtonFormField
  final Widget? hint;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.labelText,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    // FIX: Added 'hint' to the constructor
    this.hint,
    this.enabled = true,
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
          onChanged: enabled ? onChanged : null,
          validator: validator,
          // FIX: Pass the 'hint' property directly to the DropdownButtonFormField
          hint: hint,
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: enabled ? null : AppColors.muted.withOpacity(0.3),
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
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
