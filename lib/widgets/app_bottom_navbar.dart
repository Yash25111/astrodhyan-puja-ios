import 'package:flutter/material.dart';
import '../app_colors.dart';
class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  const AppBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
  }
  );
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    items: items,
    selectedItemColor: selectedColor ?? AppColors.primary,
    unselectedItemColor: unselectedColor ?? AppColors.grey,
    backgroundColor: backgroundColor ?? AppColors.surface,
    type: BottomNavigationBarType.fixed,
    );
  }
}
