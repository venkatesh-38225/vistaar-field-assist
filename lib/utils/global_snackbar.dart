import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalSnackbar {
  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: Colors.redAccent,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showWarning(String message) {
    _show(
      message: message,
      backgroundColor: Colors.orange.shade800,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      backgroundColor: const Color(0xFF145a95),
      icon: Icons.info_outline_rounded,
    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
    IconData? icon,
  }) {
    debugPrint("GlobalSnackbar: $message");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.key.currentContext;

      if (context == null) {
        debugPrint("GlobalSnackbar failed: no context available");
        return;
      }

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.hideCurrentSnackBar();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}
