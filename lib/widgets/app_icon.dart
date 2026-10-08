import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.semanticLabel,
  }
  );
  @override
  Widget build(BuildContext context) {
    return Icon(
    icon,
    size: size ?? AppConstants.icon,
    color: color ?? AppColors.text,
    semanticLabel: semanticLabel,
    );
  }
}
