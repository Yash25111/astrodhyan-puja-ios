import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppRupeeAmount extends StatelessWidget {
  final Object amount;
  final String currencySymbol;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  const AppRupeeAmount({
    super.key,
    required this.amount,
    this.currencySymbol = '₹',
    this.fontSize,
    this.color,
    this.fontWeight,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Text(
    '$currencySymbol$amount',
    style: TextStyle(
    fontSize: fontSize ?? AppConstants.textMedium,
    color: color ?? AppColors.text,
    fontWeight: fontWeight ?? FontWeight.w600,
    ),
    );
  }
}
