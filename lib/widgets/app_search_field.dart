import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      textInputAction: TextInputAction.search,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search',
        prefixIcon: const Icon(
          Icons.search,
          size: AppConstants.icon,
          color: AppColors.grey,
        ),
        suffixIcon: controller == null
            ? null
            : ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller!,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      controller!.clear();
                      onChanged?.call('');
                    },
                    icon: const Icon(Icons.clear, size: AppConstants.icon),
                    color: AppColors.grey,
                  );
                },
              ),
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
      ),
    );
  }
}
