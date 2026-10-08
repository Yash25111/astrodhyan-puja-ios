import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppFAB extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool mini;
  const AppFAB({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.mini = false,
  });
  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label;
    if (effectiveLabel != null && effectiveLabel.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? AppColors.white,
        tooltip: tooltip,
        isExtended: true,
        icon: Icon(icon),
        label: Text(effectiveLabel),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.white,
      tooltip: tooltip,
      mini: mini,
      child: Icon(icon),
    );
  }
}
