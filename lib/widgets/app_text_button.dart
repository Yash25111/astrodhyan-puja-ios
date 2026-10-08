import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final bool enabled;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.enabled = true,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.alignment,
  }
  );
  @override
  Widget build(BuildContext context) {
    return TextButton(
    onPressed: enabled ? onPressed : null,
    style: TextButton.styleFrom(
    foregroundColor: textColor ?? AppColors.primary,
    disabledForegroundColor: AppColors.disabled,
    padding: padding ?? const EdgeInsets.symmetric(
    horizontal: AppConstants.paddingSmall,
    vertical: AppConstants.gapSmall,
    ),
    alignment: alignment ?? Alignment.center,
    ),
    child: Text(
    text,
    style: TextStyle(
    fontSize: fontSize ?? AppConstants.text,
    fontWeight: fontWeight ?? FontWeight.w600,
    ),
    ),
    );
  }
}
