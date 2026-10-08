import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
enum AppButtonIconPosition {
  leading, trailing
}
class AppButtonWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final AppButtonIconPosition iconPosition;
  final bool loading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? iconSize;
  final double? elevation;
  const AppButtonWithIcon({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.iconPosition = AppButtonIconPosition.leading,
    this.loading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.iconSize,
    this.elevation,
  }
  );
  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    final iconWidget = loading
    ? SizedBox(
    width: iconSize ?? AppConstants.icon,
    height: iconSize ?? AppConstants.icon,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation<Color>(
    foregroundColor ?? AppColors.white,
    ),
    ),
    )
    : Icon(icon, size: iconSize ?? AppConstants.icon);
    final label = Text(text);
    final row = iconPosition == AppButtonIconPosition.leading
    ? [iconWidget, const SizedBox(width: AppConstants.gap), label]
    : [label, const SizedBox(width: AppConstants.gap), iconWidget];
    return SizedBox(
    width: width,
    height: height ?? AppConstants.buttonHeight,
    child: ElevatedButton(
    onPressed: active ? onPressed : null,
    style: ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? AppColors.primary,
    foregroundColor: foregroundColor ?? AppColors.white,
    disabledBackgroundColor: AppColors.lightGrey,
    disabledForegroundColor: AppColors.disabled,
    elevation: elevation ?? 0,
    padding: padding ?? const EdgeInsets.symmetric(
    horizontal: AppConstants.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
    borderRadius ?? AppConstants.buttonRadius,
    ),
    ),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: row,
    ),
    ),
    );
  }
}
