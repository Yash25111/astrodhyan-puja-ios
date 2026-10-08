import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final double? iconSize;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.iconSize,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.padding,
    this.borderRadius,
  }
  );
  @override
  Widget build(BuildContext context) {
    return SizedBox(
    width: size ?? AppConstants.buttonHeight,
    height: size ?? AppConstants.buttonHeight,
    child: IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    padding: padding ?? EdgeInsets.zero,
    style: IconButton.styleFrom(
    backgroundColor: backgroundColor ?? Colors.transparent,
    foregroundColor: color ?? AppColors.text,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
    borderRadius ?? AppConstants.borderRadius,
    ),
    ),
    ),
    icon: Icon(
    icon,
    size: iconSize ?? AppConstants.icon,
    ),
    ),
    );
  }
}
