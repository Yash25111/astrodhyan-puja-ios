import 'package:flutter/material.dart';
import '../app_colors.dart';
enum AppSnackBarType {
  normal, success, error, warning
}
class AppSnackBar {
  AppSnackBar._();
  static void show(
  BuildContext context,
  String message, {
    AppSnackBarType type = AppSnackBarType.normal,
    Duration duration = const Duration(seconds: 3),
  }
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final backgroundColor = switch (type) {
      AppSnackBarType.success => AppColors.success,
      AppSnackBarType.error => AppColors.error,
      AppSnackBarType.warning => AppColors.warning,
      AppSnackBarType.normal => AppColors.text,
    }
    ;
    messenger.showSnackBar(
    SnackBar(
    content: Text(message),
    duration: duration,
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    ),
    );
  }
  static void success(BuildContext context, String message) =>
  show(context, message, type: AppSnackBarType.success);
  static void error(BuildContext context, String message) =>
  show(context, message, type: AppSnackBarType.error);
  static void warning(BuildContext context, String message) =>
  show(context, message, type: AppSnackBarType.warning);
}
