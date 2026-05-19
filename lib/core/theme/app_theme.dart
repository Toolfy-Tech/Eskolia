import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/typography.dart';
import 'app_theme_extensions.dart';
import 'eskolia_layout.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const overlay = Color(0x14FFFFFF);
    const borderGlass = Color(0x33FFFFFF);
    const borderGlassFocused = Color(0x806C3CE1);

    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: textPrimary,
      secondary: secondary,
      onSecondary: textPrimary,
      tertiary: accent,
      onTertiary: background,
      surface: surface,
      onSurface: textPrimary,
      error: Color(0xFFFF5252),
      onError: textPrimary,
      outline: borderGlass,
 );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        GlassmorphismTheme(
          glassColor: surface.withValues(alpha: 0.12),
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
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: EskoliaTypography.body(),
        subtitleTextStyle: EskoliaTypography.body(textSecondary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: Color(0x22FFFFFF),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: EskoliaTypography.h3(),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.25),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: EskoliaTypography.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: EskoliaTypography.h2(),
        contentTextStyle: EskoliaTypography.body(textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: overlay,
        hoverColor: overlay,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: EskoliaTypography.body(textSecondary),
        labelStyle: EskoliaTypography.label(textSecondary),
        floatingLabelStyle: EskoliaTypography.label(primary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGlassFocused, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error.withValues(alpha: 0.9)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll(textPrimary),
          backgroundColor: const WidgetStatePropertyAll(primary),
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
          foregroundColor: const WidgetStatePropertyAll(textPrimary),
          backgroundColor: const WidgetStatePropertyAll(secondary),
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
          foregroundColor: const WidgetStatePropertyAll(textPrimary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            final pressed = states.contains(WidgetState.pressed);
            return BorderSide(
              color: textSecondary.withValues(alpha: pressed ? 0.65 : 0.45),
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
              return textSecondary.withValues(alpha: 0.4);
            }
            return primary;
          }),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label(primary)),
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
