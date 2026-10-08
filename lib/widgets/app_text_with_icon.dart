import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
enum AppIconPosition {
  leading, trailing
}
class AppTextWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppIconPosition iconPosition;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? spacing;
  const AppTextWithIcon({
    super.key,
    required this.icon,
    required this.text,
    this.iconPosition = AppIconPosition.leading,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.spacing,
  }
  );
  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
    icon,
    size: iconSize ?? AppConstants.icon,
    color: iconColor ?? AppColors.text,
    );
    final textWidget = Text(
    text,
    style: textStyle ?? const TextStyle(
    fontSize: AppConstants.text,
    color: AppColors.text,
    ),
    );
    final children = iconPosition == AppIconPosition.leading
    ? [iconWidget, SizedBox(width: spacing ?? AppConstants.gap), textWidget]
    : [textWidget, SizedBox(width: spacing ?? AppConstants.gap), iconWidget];
    return Row(
    mainAxisSize: MainAxisSize.min,
    children: children,
    );
  }
}
