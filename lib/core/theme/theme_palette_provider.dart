import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EskoliaThemeId {
  tardisCyan(
    'tardis_cyan',
    'Cyan Tardis',
    Color(0xFF00E5FF),
    Color(0xFF050E1A),
    Color(0xFF0A1C33),
    Color(0xFF102A4C),
  ),
  neonViolet(
    'neon_violet',
    'Néon Violet',
    Color(0xFFC084FC),
    Color(0xFF0E061E),
    Color(0xFF1B0D38),
    Color(0xFF2C1656),
  ),
  matrixEmerald(
    'matrix_emerald',
    'Menthe Émeraude',
    Color(0xFF00E5A3),
    Color(0xFF03140E),
    Color(0xFF08261C),
    Color(0xFF0F3B2C),
  ),
  goldObsidian(
    'gold_obsidian',
    'Or Impérial',
    Color(0xFFFFB300),
    Color(0xFF140D04),
    Color(0xFF241808),
    Color(0xFF38260F),
  );

  const EskoliaThemeId(
    this.key,
    this.label,
    this.accentColor,
    this.bgBaseColor,
    this.bgSurfaceColor,
    this.bgElevatedColor,
  );

  final String key;
  final String label;
  final Color accentColor;
  final Color bgBaseColor;
  final Color bgSurfaceColor;
  final Color bgElevatedColor;

  static EskoliaThemeId fromKey(String? key) {
    return EskoliaThemeId.values.firstWhere(
      (t) => t.key == key,
      orElse: () => EskoliaThemeId.tardisCyan,
    );
  }
}

class EskoliaThemePalette {
  const EskoliaThemePalette({required this.themeId});

  final EskoliaThemeId themeId;

  String get key => themeId.key;
  String get label => themeId.label;
  Color get primaryAccent => themeId.accentColor;
  Color get bgBase => themeId.bgBaseColor;
  Color get bgSurface => themeId.bgSurfaceColor;
  Color get bgElevated => themeId.bgElevatedColor;

  Color get surfaceCard => Color.alphaBlend(primaryAccent.withValues(alpha: 0.04), bgSurface);
  Color get surfaceElevated => Color.alphaBlend(primaryAccent.withValues(alpha: 0.08), bgElevated);
  Color get cardBorder => primaryAccent.withValues(alpha: 0.20);
  Color get cardBorderGlow => primaryAccent.withValues(alpha: 0.50);
  Color get activeNavBg => primaryAccent.withValues(alpha: 0.12);
  Color get sidebarBg => Color.alphaBlend(primaryAccent.withValues(alpha: 0.04), bgSurface);
  Color get sidebarBorder => primaryAccent.withValues(alpha: 0.28);

  RadialGradient get backgroundGradient => RadialGradient(
        center: Alignment.center,
        radius: 1.35,
        colors: [
          bgSurface,
          bgBase,
        ],
      );

  Color get gridPrimaryColor => primaryAccent.withValues(alpha: 0.07);
  Color get gridSecondaryColor => primaryAccent.withValues(alpha: 0.025);
}

class ThemePaletteNotifier extends Notifier<EskoliaThemePalette> {
  static const String _prefKey = 'eskolia_app_theme_id_v1';

  @override
  EskoliaThemePalette build() {
    _loadFromPrefs();
    return const EskoliaThemePalette(themeId: EskoliaThemeId.tardisCyan);
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_prefKey);
      if (key != null) {
        state = EskoliaThemePalette(themeId: EskoliaThemeId.fromKey(key));
      }
    } catch (_) {}
  }

  Future<void> setTheme(EskoliaThemeId id) async {
    state = EskoliaThemePalette(themeId: id);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, id.key);
    } catch (_) {}
  }
}

final themePaletteProvider =
    NotifierProvider<ThemePaletteNotifier, EskoliaThemePalette>(ThemePaletteNotifier.new);
