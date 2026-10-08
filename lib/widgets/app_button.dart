import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.elevation,
  }
  );
  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading && onPressed != null;
    return SizedBox(
    width: width,
    height: height ?? AppConstants.buttonHeight,
    child: ElevatedButton(
    onPressed: isEnabled ? onPressed : null,
    style: ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? AppColors.primary,
    foregroundColor: textColor ?? AppColors.white,
    disabledBackgroundColor: AppColors.lightGrey,
    disabledForegroundColor: AppColors.disabled,
    elevation: elevation ?? 0,
    padding: padding ?? const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
    borderRadius ?? AppConstants.buttonRadius,
    ),
    ),
    ),
    child: loading
    ? SizedBox(
    width: AppConstants.icon,
    height: AppConstants.icon,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation<Color>(
    textColor ?? AppColors.white,
    ),
    ),
    )
    : Text(text),
    ),
    );
  }
}
