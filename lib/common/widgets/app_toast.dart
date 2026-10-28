import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Color(isError ? AppColors.danger : AppColors.success),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }

  static void showFeatureComingSoon(BuildContext context) {
    show(context, AppStrings.featureComingSoon);
  }
}
