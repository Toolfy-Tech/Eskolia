import 'package:flutter/material.dart';

const double kEskoliaAppBarHeight = 0.0;

/// AppBar homogène : transparent, titre centré, retour ergonomique (48px).
abstract final class EskoliaAppBar {
  EskoliaAppBar._();

  static PreferredSizeWidget standard(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    bool centerTitle = true,
    VoidCallback? onBack,
    bool showBack = true,
    PreferredSizeWidget? bottom,
  }) {
    return const PreferredSize(
      preferredSize: Size.zero,
      child: SizedBox.shrink(),
    );
  }
}
