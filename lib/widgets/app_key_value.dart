import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppKeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final double? labelSize;
  final double? valueSize;
  final double? spacing;
  final MainAxisAlignment alignment;
  const AppKeyValue({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.labelSize,
    this.valueSize,
    this.spacing,
    this.alignment = MainAxisAlignment.spaceBetween,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Row(
    mainAxisAlignment: alignment,
    children: [
    Flexible(
    child: Text(
    label,
    style: TextStyle(
    fontSize: labelSize ?? AppConstants.text,
    color: labelColor ?? AppColors.subheading,
    ),
    ),
    ),
    SizedBox(width: spacing ?? AppConstants.gap),
    Flexible(
    child: Text(
    value,
    textAlign: TextAlign.end,
    style: TextStyle(
    fontSize: valueSize ?? AppConstants.text,
    color: valueColor ?? AppColors.text,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ],
    );
  }
}
