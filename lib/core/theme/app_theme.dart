import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/eskolia_tokens.dart';
import '../constants/typography.dart';
import 'app_theme_extensions.dart';
import 'eskolia_layout.dart';
import 'theme_palette_provider.dart';

abstract final class AppTheme {
  AppTheme._();

  static const Color _textPrimary   = EskoliaTokens.textPrimary;
  static const Color _textSecondary = EskoliaTokens.textSecondary;

  static ThemeData get dark => fromPalette(const EskoliaThemePalette(themeId: EskoliaThemeId.tardisCyan));

  static ThemeData fromPalette(EskoliaThemePalette palette) {
    final primary = palette.primaryAccent;
    final background = palette.bgBase;
    final surface = palette.bgSurface;
    final borderGlass = palette.cardBorder;
    final borderGlassFocused = palette.cardBorderGlow;

    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.black,
      secondary: primary,
      onSecondary: Colors.black,
      tertiary: palette.surfaceElevated,
      onTertiary: _textPrimary,
      surface: surface,
      onSurface: _textPrimary,
      error: const Color(0xFFFF5252),
      onError: _textPrimary,
      outline: borderGlass,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        GlassmorphismTheme(
          glassColor: surface.withValues(alpha: 0.20),
          borderColor: primary.withValues(alpha: 0.35),
          blur: 14,
        ),
        NeonTheme(
          neonColor: primary,
          shadowColor: primary,
          intensity: 1.0,
        ),
      ],
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: EskoliaTypography.textTheme(),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(EskoliaLayout.minTouchTarget, EskoliaLayout.minTouchTarget),
          padding: const EdgeInsets.all(8),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EskoliaLayout.screenPaddingH,
          vertical: 10,
        ),
        minVerticalPadding: 12,
        iconColor: _textSecondary,
        textColor: _textPrimary,
        titleTextStyle: EskoliaTypography.body(),
        subtitleTextStyle: EskoliaTypography.body(_textSecondary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.15),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: EskoliaTypography.h3(),
        iconTheme: const IconThemeData(color: _textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: _textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
          side: BorderSide(color: borderGlass, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: primary.withValues(alpha: 0.15),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceElevated,
        contentTextStyle: EskoliaTypography.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
          side: BorderSide(color: borderGlass, width: 1),
        ),
        titleTextStyle: EskoliaTypography.h2(),
        contentTextStyle: EskoliaTypography.body(_textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceCard,
        hoverColor: palette.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: EskoliaTypography.body(_textSecondary),
        labelStyle: EskoliaTypography.label(_textSecondary),
        floatingLabelStyle: EskoliaTypography.label(primary),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: BorderSide(color: borderGlass, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: BorderSide(color: borderGlass, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: BorderSide(color: borderGlassFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error.withValues(alpha: 0.9)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll(Colors.black),
          backgroundColor: WidgetStatePropertyAll(primary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: const WidgetStatePropertyAll(Colors.black),
          backgroundColor: WidgetStatePropertyAll(primary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(primary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            final pressed = states.contains(WidgetState.pressed);
            return BorderSide(
              color: primary.withValues(alpha: pressed ? 0.9 : 0.6),
              width: 1.25,
            );
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _textSecondary.withValues(alpha: 0.4);
            }
            return primary;
          }),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
          ),
        ),
      ),
    );
  }
}

/// Autorise le drag des scrollables (PageView, listes) à la souris, au pavé et au stylet.
class EskoliaScrollBehavior extends MaterialScrollBehavior {
  const EskoliaScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
