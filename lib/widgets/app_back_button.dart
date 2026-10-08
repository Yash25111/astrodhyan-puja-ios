import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon,
    this.color,
    this.backgroundColor,
    this.tooltip,
  }
  );
  @override
  Widget build(BuildContext context) {
    return IconButton(
    onPressed: onPressed,
    tooltip: tooltip ?? 'Back',
    style: IconButton.styleFrom(
    foregroundColor: color ?? AppColors.text,
    backgroundColor: backgroundColor ?? Colors.transparent,
    padding: const EdgeInsets.all(AppConstants.paddingSmall),
    ),
    icon: Icon(icon ?? Icons.arrow_back),
    );
  }
}
