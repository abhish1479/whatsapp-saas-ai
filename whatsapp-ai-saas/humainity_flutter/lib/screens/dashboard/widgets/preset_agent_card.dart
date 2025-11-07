import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PresetAgentCard extends StatelessWidget {
  final String name;
  final String description;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const PresetAgentCard({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                color: AppColors.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(description,
                        style: const TextStyle(
                            color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.check,
                        color: AppColors.primaryForeground, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}