import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Titres : Poppins Bold · Corps : Inter Regular · Accents / labels : Poppins SemiBold
abstract final class EskoliaTypography {
  EskoliaTypography._();

  static const double _displaySize = 40;
  static const double _h1Size = 32;
  static const double _h2Size = 24;
  static const double _h3Size = 20;
  static const double _bodySize = 16;
  static const double _captionSize = 12;
  static const double _labelSize = 14;

  static TextStyle display([Color? color]) => GoogleFonts.poppins(
        fontSize: _displaySize,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: color ?? textPrimary,
      );

  static TextStyle h1([Color? color]) => GoogleFonts.poppins(
        fontSize: _h1Size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.25,
        color: color ?? textPrimary,
      );

  static TextStyle h2([Color? color]) => GoogleFonts.poppins(
        fontSize: _h2Size,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color ?? textPrimary,
      );

  static TextStyle h3([Color? color]) => GoogleFonts.poppins(
        fontSize: _h3Size,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color ?? textPrimary,
      );

  static TextStyle body([Color? color]) => GoogleFonts.inter(
        fontSize: _bodySize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? textPrimary,
      );

  static TextStyle caption([Color? color]) => GoogleFonts.inter(
        fontSize: _captionSize,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color ?? textSecondary,
      );

  static TextStyle label([Color? color]) => GoogleFonts.poppins(
        fontSize: _labelSize,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: color ?? textPrimary,
      );

  /// [TextTheme] Material aligné sur les styles Eskolia (dark).
  static TextTheme textTheme() => TextTheme(
        displayLarge: display(),
        headlineLarge: h1(),
        headlineMedium: h2(),
        headlineSmall: h3(),
        bodyLarge: body(),
        bodySmall: caption(),
        labelLarge: label(),
      );
}
