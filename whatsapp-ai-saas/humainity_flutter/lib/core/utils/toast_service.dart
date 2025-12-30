import 'package:flutter/material.dart';
import 'package:humainise_ai/core/routing/app_router.dart';
import 'package:humainise_ai/core/theme/app_colors.dart';
import 'package:humainise_ai/core/utils/responsive.dart'; // Ensure this import is correct
import 'package:toastification/toastification.dart';

class ToastService {
  static void showError(String message) {
    _showToast(
      message: message,
      type: ToastificationType.error,
      icon: const Icon(Icons.error_outline, color: Colors.red),
      primaryColor: Colors.red,
    );
  }

  static void showSuccess(String message) {
    _showToast(
      message: message,
      type: ToastificationType.success,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      primaryColor: Colors.green,
    );
  }

  static void _showToast({
    required String message,
    required ToastificationType type,
    required Icon icon,
    required Color primaryColor,
  }) {
    // 1. Get Global Context
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    // 2. Responsive Alignment Logic
    // Web/Desktop -> Top Right
    // Mobile -> Top Center
    final alignment =
        Responsive.isMobile(context) ? Alignment.topCenter : Alignment.topRight;

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flatColored,
      title: Text(
        type == ToastificationType.error ? 'Error' : 'Success',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(message),
      // ✅ Apply Responsive Alignment
      alignment: alignment,
      autoCloseDuration: const Duration(seconds: 4),
      primaryColor: primaryColor,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      icon: icon,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: true,
      // Allow drag to dismiss on mobile for better UX
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
    );
  }
}
