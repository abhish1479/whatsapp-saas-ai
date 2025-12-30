import 'package:flutter/material.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final double radius;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              fallbackText?.substring(0, 1).toUpperCase() ?? '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
