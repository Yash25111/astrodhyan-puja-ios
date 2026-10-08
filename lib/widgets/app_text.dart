import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final double? letterSpacing;
  const AppText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.letterSpacing,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    style: TextStyle(
    fontSize: fontSize ?? AppConstants.text,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: color ?? AppColors.text,
    decoration: decoration,
    height: height,
    letterSpacing: letterSpacing,
    ),
    );
  }
}
