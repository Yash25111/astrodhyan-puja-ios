import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
import 'app_text.dart';
class AppHeading extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const AppHeading({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }
  );
  @override
  Widget build(BuildContext context) {
    return AppText(
    text: text,
    fontSize: fontSize ?? AppConstants.heading,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.heading,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    );
  }
}
