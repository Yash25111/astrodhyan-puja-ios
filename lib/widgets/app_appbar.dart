import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
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
    this.titleText,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
  });
  @override
  Widget build(BuildContext context) {
    final effectiveForeground = foregroundColor ?? AppColors.text;
    return AppBar(
      title:
          title ??
          (titleText == null
              ? null
              : Text(
                  titleText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: effectiveForeground,
                  ),
                )),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.appBar,
      foregroundColor: effectiveForeground,
      elevation: elevation ?? 0,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
