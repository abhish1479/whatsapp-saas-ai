import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';

// *** ADD THIS CLASS ***
// This class holds the data for each radio button
class AppRadioItem<T> {
  final T value;
  final Widget label;

  const AppRadioItem({
    required this.value,
    required this.label,
  });
}

class AppRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;

  // *** FIX: This parameter MUST be a List of AppRadioItem ***
  final List<AppRadioItem<T>> items;

  const AppRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items, // This was the source of the error
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final bool isSelected = item.value == groupValue;
        return Flexible(
          child: InkWell(
            onTap: () => onChanged(item.value),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.input,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<T>(
                    value: item.value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: item.label),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}