import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/eskolia_layout.dart';

/// AppBar homogène : transparent, titre centré, retour ergonomique (48px).
abstract final class EskoliaAppBar {
  EskoliaAppBar._();

  static AppBar standard(
    BuildContext context, {
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    bool centerTitle = true,
    VoidCallback? onBack,
    bool showBack = true,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leadingWidth: showBack ? EskoliaLayout.minTouchTarget + 8 : 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Retour',
              onPressed: onBack ?? () => context.pop(),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                )
              : null),
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }
}
