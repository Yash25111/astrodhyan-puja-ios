import 'package:flutter/material.dart';
class AppRichText extends StatelessWidget {
  final List<InlineSpan> children;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  const AppRichText({
    super.key,
    required this.children,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  }
  );
  @override
  Widget build(BuildContext context) {
    return RichText(
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    text: TextSpan(children: children),
    );
  }
}
