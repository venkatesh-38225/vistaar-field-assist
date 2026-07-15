import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalSnackbar {
  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: Colors.redAccent,
    );
  }

  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: Colors.green,

    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
  }) {
    debugPrint("GlobalSnackbar: $message");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.key.currentContext;

      if (context == null) {
        debugPrint("GlobalSnackbar failed: no context available");
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}