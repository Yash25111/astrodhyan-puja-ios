import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
import 'app_text.dart';
class AppSubtitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const AppSubtitle({
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
    fontSize: fontSize ?? AppConstants.subtitle,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: color ?? AppColors.subheading,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    );
  }
}
