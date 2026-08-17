import 'package:flutter_test/flutter_test.dart';
import 'package:eskolia/core/theme/theme_palette_provider.dart';
import 'package:eskolia/shared/widgets/eskolia_column_switcher.dart';

void main() {
  group('Theme Palette Tests', () {
    test('EskoliaThemeId fromKey returns correct themes and fallback', () {
      expect(EskoliaThemeId.fromKey('tardis_cyan'), EskoliaThemeId.tardisCyan);
      expect(EskoliaThemeId.fromKey('neon_violet'), EskoliaThemeId.neonViolet);
      expect(EskoliaThemeId.fromKey('matrix_emerald'), EskoliaThemeId.matrixEmerald);
      expect(EskoliaThemeId.fromKey('gold_obsidian'), EskoliaThemeId.goldObsidian);
      expect(EskoliaThemeId.fromKey('unknown_key'), EskoliaThemeId.tardisCyan);
    });

    test('EskoliaThemePalette provides correct colors and gradient', () {
      const palette = EskoliaThemePalette(themeId: EskoliaThemeId.matrixEmerald);
      expect(palette.primaryAccent, EskoliaThemeId.matrixEmerald.accentColor);
      expect(palette.bgBase, EskoliaThemeId.matrixEmerald.bgBaseColor);
      expect(palette.backgroundGradient.colors.length, 2);
    });
  });

  group('Column Resolution Tests', () {
    test('Auto mode (preference = 0) adapts to available width', () {
      // Very wide screen
      final wide = ColumnResolution.compute(preference: 0, availableWidth: 1500);
      expect(wide.columns, 4);

      // Desktop
      final desktop = ColumnResolution.compute(preference: 0, availableWidth: 1100);
      expect(desktop.columns, 3);

      // Tablet
      final tablet = ColumnResolution.compute(preference: 0, availableWidth: 750);
      expect(tablet.columns, 2);

      // Mobile
      final mobile = ColumnResolution.compute(preference: 0, availableWidth: 400);
      expect(mobile.columns, 1);
    });

    test('Manual mode respects user preference when width is sufficient', () {
      final res3 = ColumnResolution.compute(preference: 3, availableWidth: 1200);
      expect(res3.columns, 3);

      final res2 = ColumnResolution.compute(preference: 2, availableWidth: 1200);
      expect(res2.columns, 2);

      final res1 = ColumnResolution.compute(preference: 1, availableWidth: 1200);
      expect(res1.columns, 1);
    });

    test('Manual mode clamps to safe max columns on small screen', () {
      // 400px width with 240px min card width should clamp 3 or 4 cols to 1
      final clamped = ColumnResolution.compute(preference: 4, availableWidth: 400);
      expect(clamped.columns, 1);
    });
  });
}
