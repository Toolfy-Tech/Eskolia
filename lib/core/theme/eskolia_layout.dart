import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Espacements et cibles tactiles alignés ergonomie + maquettes.
abstract final class EskoliaLayout {
  EskoliaLayout._();

  static const double screenPaddingH = 20;
  static const double screenPaddingTop = 8;
  static const double screenPaddingBottom = 28;
  static const double minTouchTarget = 48;
  static const double contentMaxWidth = 560;

  /// Colonne **Hub** (accueil `HomeScreen`) : shell solo, fins de quiz, etc. —
  /// desktop / web. Réutiliser via le widget `EskoliaShellBody`.
  static const double shellContentMaxWidth = 920;

  /// Largeur max du bloc cours (markdown) — ~2× l’ancienne colonne 560 sur desktop.
  static const double lessonDesktopMaxWidth = 1120;

  /// Portrait téléphone / tablette (9:16 typique) : marges latérales plus serrées.
  static bool lessonUseFullWidthLayout(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final portrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    return portrait && w <= 900;
  }

  /// Padding horizontal de l’écran cours (réduit en portrait étroit).
  static double lessonHorizontalPadding(BuildContext context) {
    if (lessonUseFullWidthLayout(context)) {
      return math.max(10.0, MediaQuery.sizeOf(context).width * 0.035);
    }
    return screenPaddingH;
  }

  /// Largeur max du contenu cours à l’intérieur des marges [lessonHorizontalPadding].
  static double lessonContentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = lessonHorizontalPadding(context);
    final inner = math.max(0.0, w - 2 * pad);
    if (lessonUseFullWidthLayout(context)) return inner;
    return math.min(lessonDesktopMaxWidth, inner);
  }
  static const double primaryButtonMinHeight = 52;
  static const double cardRadius = 20;

  static const EdgeInsets screenInsets = EdgeInsets.fromLTRB(
    screenPaddingH,
    screenPaddingTop,
    screenPaddingH,
    screenPaddingBottom,
  );

  static EdgeInsets scrollPaddingWithBottomNav({double extraBottom = 0}) {
    return EdgeInsets.fromLTRB(
      screenPaddingH,
      screenPaddingTop,
      screenPaddingH,
      screenPaddingBottom + extraBottom,
    );
  }
}
