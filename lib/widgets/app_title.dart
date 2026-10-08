import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
import 'app_text.dart';
class AppTitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const AppTitle({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }
  );
  @override
  Widget build(BuildContext context) {
    return AppText(
    text: text,
    fontSize: fontSize ?? AppConstants.title,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color ?? AppColors.heading,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    );
  }
}
