import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/eskolia_tokens.dart';
import '../constants/typography.dart';
import 'app_theme_extensions.dart';
import 'eskolia_layout.dart';

export '../constants/eskolia_tokens.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: EskoliaTokens.violet,
      onPrimary: EskoliaTokens.textPrimary,
      secondary: const Color(0xFFFF6584),
      onSecondary: EskoliaTokens.textPrimary,
      tertiary: EskoliaTokens.success,
      onTertiary: EskoliaTokens.bgBase,
      surface: EskoliaTokens.surface1,
      onSurface: EskoliaTokens.textPrimary,
      error: EskoliaTokens.error,
      onError: EskoliaTokens.textPrimary,
      outline: EskoliaTokens.borderGlass,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: <ThemeExtension<dynamic>>[
        GlassmorphismTheme(
          glassColor: EskoliaTokens.surface1.withValues(alpha: 0.12),
          borderColor: EskoliaTokens.violet.withValues(alpha: 0.35),
          blur: 14,
        ),
        NeonTheme(
          neonColor: EskoliaTokens.violet,
          shadowColor: EskoliaTokens.violet,
          intensity: 1.0,
        ),
      ],
      scaffoldBackgroundColor: EskoliaTokens.bgBase,
      canvasColor: EskoliaTokens.bgBase,
      textTheme: EskoliaTypography.textTheme(),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(EskoliaLayout.minTouchTarget, EskoliaLayout.minTouchTarget),
          padding: const EdgeInsets.all(EskoliaTokens.spaceSm),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EskoliaLayout.screenPaddingH,
          vertical: 10,
        ),
        minVerticalPadding: 12,
        iconColor: EskoliaTokens.textSecondary,
        textColor: EskoliaTokens.textPrimary,
        titleTextStyle: EskoliaTypography.body(),
        subtitleTextStyle: EskoliaTypography.body(EskoliaTokens.textSecondary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: EskoliaTokens.cyan,
        linearTrackColor: EskoliaTokens.borderSubtle,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: EskoliaTokens.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: EskoliaTypography.h3(),
        iconTheme: const IconThemeData(color: EskoliaTokens.textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: EskoliaTokens.textPrimary, size: 24),
      ),
      cardTheme: CardThemeData(
        color: EskoliaTokens.surface1,
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
        color: EskoliaTokens.textSecondary.withValues(alpha: 0.25),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EskoliaTokens.surface2,
        contentTextStyle: EskoliaTypography.body(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EskoliaTokens.surface1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl)),
        titleTextStyle: EskoliaTypography.h2(),
        contentTextStyle: EskoliaTypography.body(EskoliaTokens.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EskoliaTokens.borderSubtle,
        hoverColor: EskoliaTokens.borderSubtle,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: EskoliaTokens.spaceMd + 2,
            vertical: EskoliaTokens.spaceMd),
        hintStyle: EskoliaTypography.body(EskoliaTokens.textSecondary),
        labelStyle: EskoliaTypography.label(EskoliaTokens.textSecondary),
        floatingLabelStyle: EskoliaTypography.label(EskoliaTokens.violet),
        prefixIconColor: EskoliaTokens.textSecondary,
        suffixIconColor: EskoliaTokens.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
          borderSide: const BorderSide(color: EskoliaTokens.borderGlass, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
          borderSide: const BorderSide(color: EskoliaTokens.borderGlass, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
          borderSide:
              const BorderSide(color: EskoliaTokens.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
          borderSide:
              BorderSide(color: EskoliaTokens.error.withValues(alpha: 0.9)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
          borderSide: const BorderSide(color: EskoliaTokens.error, width: 1.5),
        ),
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll(EskoliaTokens.textPrimary),
          backgroundColor: const WidgetStatePropertyAll(EskoliaTokens.violet),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
                horizontal: EskoliaTokens.spaceLg,
                vertical: EskoliaTokens.spaceMd - 2),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          foregroundColor: const WidgetStatePropertyAll(EskoliaTokens.textPrimary),
          backgroundColor: const WidgetStatePropertyAll(Color(0xFFFF6584)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
                horizontal: EskoliaTokens.spaceLg, vertical: EskoliaTokens.spaceMd),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(EskoliaTokens.textPrimary),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
                horizontal: EskoliaTokens.spaceLg,
                vertical: EskoliaTokens.spaceMd - 2),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            final pressed = states.contains(WidgetState.pressed);
            return BorderSide(
              color: EskoliaTokens.textSecondary
                  .withValues(alpha: pressed ? 0.65 : 0.45),
              width: 1.25,
            );
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EskoliaTokens.radiusMd)),
          ),
          textStyle: WidgetStatePropertyAll(EskoliaTypography.label()),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return EskoliaTokens.textSecondary.withValues(alpha: 0.4);
            }
            return EskoliaTokens.violet;
          }),
          textStyle:
              WidgetStatePropertyAll(EskoliaTypography.label(EskoliaTokens.violet)),
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
