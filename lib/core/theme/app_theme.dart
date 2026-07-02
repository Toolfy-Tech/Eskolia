import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/eskolia_tokens.dart';
import '../constants/typography.dart';
import 'app_theme_extensions.dart';
import 'eskolia_layout.dart';
import 'eskolia_visual.dart';

abstract final class AppTheme {
  AppTheme._();

  // Aliases locaux — couleurs specifiques au MaterialTheme (pas dans les tokens metier)
  static const Color _primary       = EskoliaTokens.violetSoft;
  static const Color _secondary     = EskoliaTokens.pink;
  static const Color _accent        = Color(0xFF43E97B); // vert neon role tertiary
  static const Color _background    = EskoliaVisual.bgDeep;
  static const Color _surface       = EskoliaVisual.bgElevated;
  static const Color _textPrimary   = EskoliaTokens.textPrimary;
  static const Color _textSecondary = EskoliaTokens.textSecondary;

  static ThemeData get dark {
    const overlay = Color(0x14FFFFFF);
    const borderGlass = Color(0x55FFFFFF);
    const borderGlassFocused = Color(0x806C3CE1);

    final colorScheme = ColorScheme.dark(
      primary: _primary,
      onPrimary: _textPrimary,
      secondary: _secondary,
      onSecondary: _textPrimary,
      tertiary: _accent,
      onTertiary: _background,
      surface: _surface,
      onSurface: _textPrimary,
      error: Color(0xFFFF5252),
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
          glassColor: _surface.withValues(alpha: 0.12),
          borderColor: _primary.withValues(alpha: 0.35),
          blur: 14,
        ),
        NeonTheme(
          neonColor: _primary,
          shadowColor: _primary,
          intensity: 1.0,
        ),
      ],
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accent,
        linearTrackColor: Color(0x22FFFFFF),
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
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: _textSecondary.withValues(alpha: 0.25),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surface,
        contentTextStyle: EskoliaTypography.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl)),
        titleTextStyle: EskoliaTypography.h2(),
        contentTextStyle: EskoliaTypography.body(_textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: overlay,
        hoverColor: overlay,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: EskoliaTypography.body(_textSecondary),
        labelStyle: EskoliaTypography.label(_textSecondary),
        floatingLabelStyle: EskoliaTypography.label(_primary),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd),
          borderSide: const BorderSide(color: borderGlassFocused, width: 1.5),
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
          foregroundColor: const WidgetStatePropertyAll(_textPrimary),
          backgroundColor: const WidgetStatePropertyAll(_primary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: const WidgetStatePropertyAll(_textPrimary),
          backgroundColor: const WidgetStatePropertyAll(_secondary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(_textPrimary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            final pressed = states.contains(WidgetState.pressed);
            return BorderSide(
              color: _textSecondary.withValues(alpha: pressed ? 0.65 : 0.45),
              width: 1.25,
            );
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _textSecondary.withValues(alpha: 0.4);
            }
            return _primary;
          }),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label(_primary)),
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
