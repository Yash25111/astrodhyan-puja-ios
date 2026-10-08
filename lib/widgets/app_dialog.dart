import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final Widget? child;
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.barrierDismissible = true,
    this.child,
  }
  );
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Widget? child,
  }
  ) {
    return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => AppDialog(
    title: title,
    content: content,
    actions: actions,
    barrierDismissible: barrierDismissible,
    child: child,
    ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
    title: title == null ? null : Text(title!),
    content: child ?? content,
    actions: actions,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
    ),
    backgroundColor: AppColors.surface,
    );
  }
}
