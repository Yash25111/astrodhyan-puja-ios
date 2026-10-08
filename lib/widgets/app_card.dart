import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final double? borderRadius;
  final Border? border;
  final double? width;
  final double? height;
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
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
    child: Card(
    color: color ?? AppColors.surface,
    elevation: elevation ?? AppConstants.cardElevation,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
    borderRadius ?? AppConstants.cardRadius,
    ),
    side: border?.top.color == null
    ? BorderSide.none
    : border!.top,
    ),
    child: Padding(
    padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
    child: child,
    ),
    ),
    );
  }
}
