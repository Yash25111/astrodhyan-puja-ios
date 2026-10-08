import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppStrikeText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  const AppStrikeText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Text(
    text,
    textAlign: textAlign,
    style: TextStyle(
    color: color ?? AppColors.subheading,
    fontSize: fontSize ?? AppConstants.text,
    fontWeight: fontWeight ?? FontWeight.normal,
    decoration: TextDecoration.lineThrough,
    ),
    );
  }
}
