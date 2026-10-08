import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../constants.dart';
class AppRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double? starSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowInteraction;
  final ValueChanged<double>? onRatingChanged;
  const AppRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize,
    this.activeColor,
    this.inactiveColor,
    this.allowInteraction = false,
    this.onRatingChanged,
  }
  );
  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0.0, maxRating.toDouble());
    return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(maxRating, (index) {
      final value = index + 1.0;
      final icon = clampedRating >= value
      ? Icons.star
      : clampedRating >= value - 0.5
      ? Icons.star_half
      : Icons.star_border;
      return IconButton(
      onPressed: allowInteraction && onRatingChanged != null
      ? () => onRatingChanged!(value)
      : null,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
      icon,
      size: starSize ?? AppConstants.icon,
      color: clampedRating >= value - 0.5
      ? (activeColor ?? AppColors.warning)
      : (inactiveColor ?? AppColors.lightGrey),
      ),
      );
    }
    ),
    );
  }
}
