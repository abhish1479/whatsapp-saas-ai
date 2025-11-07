import 'package:flutter/material.dart';
import 'package:humainity_flutter/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

Color getStatusColor(String? status) {
  switch (status) {
    case "new":
      return Colors.blue.shade500;
    case "contacted":
      return Colors.yellow.shade700;
    case "qualified":
      return Colors.purple.shade500;
    case "converted":
      return AppColors.success;
    case "lost":
      return AppColors.destructive;
    default:
      return Colors.grey.shade500;
  }
}

Color getCampaignStatusColor(String? status) {
  switch (status) {
    case 'running':
      return AppColors.success;
    case 'scheduled':
      return Colors.blue.shade500;
    case 'paused':
      return AppColors.warning;
    case 'completed':
      return Colors.grey.shade500;
    case 'failed':
      return AppColors.destructive;
    default:
      return Colors.grey.shade400;
  }
}

IconData getEngagementIcon(String type) {
  switch (type) {
    case 'message':
      return LucideIcons.messageSquare;
    case 'call':
      return LucideIcons.phone;
    case 'email':
      return LucideIcons.mail;
    case 'meeting':
      return LucideIcons.calendar;
    case 'note':
      return LucideIcons.fileText;
    default:
      return LucideIcons.fileText;
  }
}

Color getLogStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "delivered":
    case "success":
      return AppColors.success;
    case "failed":
    case "error":
      return AppColors.destructive;
    case "pending":
      return AppColors.warning;
    default:
      return AppColors.mutedForeground;
  }
}