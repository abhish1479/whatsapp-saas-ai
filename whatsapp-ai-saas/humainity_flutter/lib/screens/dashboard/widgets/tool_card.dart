import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ToolCard extends StatelessWidget {
  final String name;
  final String description;
  final String icon;
  final int runs;
  final bool isEnabled;
  final VoidCallback onTap;

  const ToolCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.runs,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary.withOpacity(0.05) : AppColors.background,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isEnabled ? AppColors.primary : AppColors.border,
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(description,
                          style: const TextStyle(
                              color: AppColors.mutedForeground, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.barChart3,
                              size: 14, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text('$runs runs',
                              style: const TextStyle(
                                  color: AppColors.mutedForeground, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isEnabled)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: const Icon(LucideIcons.check,
                      color: AppColors.primaryForeground, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}