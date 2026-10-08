import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final String? errorText;
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.errorText,
  }
  );
  @override
  Widget build(BuildContext context) {
    return TextFormField(
    controller: controller,
    focusNode: focusNode,
    obscureText: obscureText,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    validator: validator,
    onChanged: onChanged,
    enabled: enabled,
    readOnly: readOnly,
    maxLines: obscureText ? 1 : maxLines,
    decoration: InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    errorText: errorText,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
    horizontal: AppConstants.paddingMedium,
    vertical: AppConstants.padding,
    ),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
    borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
    borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
    borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppConstants.textFieldRadius),
    borderSide: const BorderSide(color: AppColors.error),
    ),
    ),
    );
  }
}
