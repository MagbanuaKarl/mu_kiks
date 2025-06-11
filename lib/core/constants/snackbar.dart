import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class AppSnackBar {
  // Default snackbar with primary color
  static SnackBar primary({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.primary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Success snackbar
  static SnackBar success({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Error snackbar
  static SnackBar error({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Info snackbar with accent color
  static SnackBar info({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.accent,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Warning snackbar
  static SnackBar warning({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: Colors.black87,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.amber,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Custom snackbar with surface color for neutral messages
  static SnackBar neutral({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.surface,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: action,
      elevation: 8,
    );
  }

  // Helper method to show snackbar
  static void show(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

// Extension for easy usage
extension SnackBarExtension on BuildContext {
  void showPrimarySnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(
        this, AppSnackBar.primary(message: message, action: action));
  }

  void showSuccessSnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(
        this, AppSnackBar.success(message: message, action: action));
  }

  void showErrorSnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(this, AppSnackBar.error(message: message, action: action));
  }

  void showInfoSnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(this, AppSnackBar.info(message: message, action: action));
  }

  void showWarningSnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(
        this, AppSnackBar.warning(message: message, action: action));
  }

  void showNeutralSnackBar(String message, {SnackBarAction? action}) {
    AppSnackBar.show(
        this, AppSnackBar.neutral(message: message, action: action));
  }
}
