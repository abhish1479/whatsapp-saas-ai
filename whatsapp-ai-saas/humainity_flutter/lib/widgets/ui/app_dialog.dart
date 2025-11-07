import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  Widget? description,
  required Widget content,
  List<Widget>? actions,
  double maxWidth = 512, // max-w-lg
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        titlePadding: const EdgeInsets.all(24.0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        actionsPadding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (description != null) ...[
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                child: description,
              ),
            ],
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(child: content),
        ),
        actions: actions,
        buttonPadding: EdgeInsets.zero,
        icon: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(LucideIcons.x, size: 16),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.mutedForeground,
            splashRadius: 20,
          ),
        ),
        iconPadding: const EdgeInsets.only(top: 16, right: 16),
      );
    },
  );
}