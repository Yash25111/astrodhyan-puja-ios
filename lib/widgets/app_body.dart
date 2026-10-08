import 'package:flutter/material.dart';
import '../app_colors.dart';
class AppBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  const AppBody({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding,
    color: backgroundColor ?? AppColors.background,
    child: child,
    );
  }
}
