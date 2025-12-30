import 'package:flutter/material.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';

class AppSwitch extends StatelessWidget {
  // FIX: Renamed initialValue to value
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({
    super.key,
    required this.value, // FIX: Use value instead of initialValue
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      // You may need to add theme data overrides if necessary
    );
  }
}
