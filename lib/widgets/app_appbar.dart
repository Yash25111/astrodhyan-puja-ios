import 'package:flutter/material.dart';
import '../app_colors.dart';
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  const AppAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
  }
  );
  @override
  Widget build(BuildContext context) {
    return AppBar(
    title: title,
    leading: leading,
    actions: actions,
    backgroundColor: backgroundColor ?? AppColors.appBar,
    foregroundColor: foregroundColor ?? AppColors.text,
    elevation: elevation ?? 0,
    centerTitle: centerTitle,
    automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
