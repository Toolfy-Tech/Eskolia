import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/eskolia_tokens.dart';
import '../utils/eskolia_icons.dart';

/// Mapping par defaut des couleurs vives et elegantes pour chaque bouton de navigation
const Map<String, Color> kDefaultSidebarButtonColors = {
  '/home': Color(0xFF00E5FF), // Cyan eclatant
  '/veille': Color(0xFF00B0FF), // Bleu ciel
  '/parcours': Color(0xFF7C4DFF), // Violet indigo
  '/exams': Color(0xFFFFB300), // Or / Ambre
  '/solo': Color(0xFFFF2A6D), // Rose neon
  '/tp': Color(0xFFFF6D00), // Orange vif
  '/lobbys': Color(0xFFFF4081), // Rose bonbon
  '/ai/setup': Color(0xFFAB47BC), // Violet IA
  '/notebook': Color(0xFF00E676), // Emeraude / Menthe
  '/docs': Color(0xFFFFC107), // Ambre doux
  '/leaderboard': Color(0xFFFFD700), // Or trophee
  '/achievements': Color(0xFFFF5722), // Corail feu
  '/labo': Color(0xFF1DE9B6), // Turquoise labo
  '/settings': Color(0xFF90A4AE), // Ardoise / Metal
  '/admin': Color(0xFFE53935), // Rouge securite
};

/// Palette de couleurs vives selectionnables pour la personnalisation
const List<Color> kSidebarColorPalette = [
  Color(0xFF00E5FF), // Cyan Tardis
  Color(0xFF00B0FF), // Bleu Ciel
  Color(0xFF3B82F6), // Bleu Roi
  Color(0xFF7C4DFF), // Violet Neon
  Color(0xFFAB47BC), // Violet Orchidee
  Color(0xFFFF2A6D), // Rose Neon
  Color(0xFFFF4081), // Rose Bonbon
  Color(0xFFE53935), // Rouge Ecarlate
  Color(0xFFFF5722), // Corail
  Color(0xFFFF6D00), // Orange Vif
  Color(0xFFFFB300), // Ambre / Or
  Color(0xFFFFD700), // Or Imperial
  Color(0xFF00E676), // Vert Emeraude
  Color(0xFF1DE9B6), // Turquoise / Menthe
  Color(0xFF14B8A6), // Sarcelle
  Color(0xFF90A4AE), // Ardoise Metal
  Color(0xFFFFFFFF), // Blanc Pur
];

class SidebarButtonColorsNotifier extends Notifier<Map<String, int>> {
  static const String _prefKey = 'eskolia_sidebar_button_colors_v1';

  @override
  Map<String, int> build() {
    _loadFromPrefs();
    return const {};
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefKey);
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        final map = <String, int>{};
        decoded.forEach((k, v) {
          if (v is int) map[k] = v;
        });
        if (map.isNotEmpty) {
          state = map;
        }
      }
    } catch (_) {}
  }

  Color getColor(String path, {Color? fallback}) {
    final customVal = state[path];
    if (customVal != null) return Color(customVal);
    if (kDefaultSidebarButtonColors.containsKey(path)) {
      return kDefaultSidebarButtonColors[path]!;
    }
    return fallback ?? EskoliaTokens.cyan;
  }

  Future<void> setColor(String path, Color color) async {
    final newMap = {...state, path: color.value};
    state = newMap;
    _persist(newMap);
  }

  Future<void> resetColor(String path) async {
    final newMap = {...state}..remove(path);
    state = newMap;
    _persist(newMap);
  }

  Future<void> resetAll() async {
    state = const {};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
    } catch (_) {}
  }

  Future<void> _persist(Map<String, int> map) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (_) {}
  }
}

final sidebarButtonColorsProvider =
    NotifierProvider<SidebarButtonColorsNotifier, Map<String, int>>(
  SidebarButtonColorsNotifier.new,
);

class NavButtonMeta {
  const NavButtonMeta({
    required this.path,
    required this.label,
    required this.emoji,
  });

  final String path;
  final String label;
  final String emoji;
}

const List<NavButtonMeta> kAllNavButtonMetas = [
  NavButtonMeta(path: '/home', label: 'Accueil', emoji: '🏠'),
  NavButtonMeta(path: '/veille', label: 'Veille', emoji: '📡'),
  NavButtonMeta(path: '/parcours', label: 'Parcours', emoji: '📚'),
  NavButtonMeta(path: '/exams', label: 'Examens Blancs', emoji: '🎓'),
  NavButtonMeta(path: '/solo', label: 'Solo (Quiz)', emoji: '🎯'),
  NavButtonMeta(path: '/tp', label: 'Travaux Pratiques', emoji: '🛠️'),
  NavButtonMeta(path: '/lobbys', label: 'Multijoueur / Lobbys', emoji: '🎮'),
  NavButtonMeta(path: '/ai/setup', label: 'Mon IA', emoji: '🧠'),
  NavButtonMeta(path: '/notebook', label: 'Mon Bloc-notes', emoji: '📝'),
  NavButtonMeta(path: '/docs', label: 'Documentation', emoji: '📖'),
  NavButtonMeta(path: '/leaderboard', label: 'Classement', emoji: '🏆'),
  NavButtonMeta(path: '/achievements', label: 'Hauts faits', emoji: '🎖️'),
  NavButtonMeta(path: '/labo', label: 'Le Labo', emoji: '🧪'),
  NavButtonMeta(path: '/settings', label: 'Réglages', emoji: '⚙️'),
  NavButtonMeta(path: '/admin', label: 'Administration', emoji: '🛡️'),
];

/// Affiche la boite de dialogue de personnalisation des couleurs de la barre laterale.
void showSidebarButtonColorsDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final customColors = ref.watch(sidebarButtonColorsProvider);
          final notifier = ref.read(sidebarButtonColorsProvider.notifier);

          return Dialog(
            backgroundColor: EskoliaTokens.surface1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: EskoliaTokens.cyan.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.palette_rounded,
                                color: EskoliaTokens.cyan,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Couleurs du menu',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personnalisez la couleur de chaque bouton de la barre latérale comme pour les Examens Blancs.',
                      style: GoogleFonts.plusJakartaSans(
                        color: EskoliaTokens.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: kAllNavButtonMetas.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Colors.white10,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final meta = kAllNavButtonMetas[index];
                          final currentColor = notifier.getColor(meta.path);
                          final isCustomized = customColors.containsKey(meta.path);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: currentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: currentColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  getIconDataForEmoji(meta.emoji),
                                  size: 20,
                                  color: currentColor,
                                ),
                              ),
                            ),
                            title: Text(
                              meta.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              isCustomized
                                  ? 'Couleur personnalisee'
                                  : 'Couleur par defaut',
                              style: TextStyle(
                                color: isCustomized
                                    ? currentColor
                                    : EskoliaTokens.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCustomized)
                                  IconButton(
                                    tooltip: 'Reinitialiser',
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                    onPressed: () => notifier.resetColor(meta.path),
                                  ),
                                InkWell(
                                  onTap: () {
                                    _showColorPickerSheet(
                                      context: context,
                                      meta: meta,
                                      currentColor: currentColor,
                                      onColorSelected: (c) {
                                        notifier.setColor(meta.path, c);
                                      },
                                      onReset: () {
                                        notifier.resetColor(meta.path);
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: currentColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: currentColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: currentColor.withValues(
                                                  alpha: 0.6,
                                                ),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => notifier.resetAll(),
                          icon: const Icon(
                            Icons.restart_alt_rounded,
                            size: 18,
                            color: Colors.white60,
                          ),
                          label: const Text(
                            'Tout reinitialiser',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: EskoliaTokens.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Termine',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void _showColorPickerSheet({
  required BuildContext context,
  required NavButtonMeta meta,
  required Color currentColor,
  required ValueChanged<Color> onColorSelected,
  required VoidCallback onReset,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: EskoliaTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: currentColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Couleur pour ${meta.label}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: kSidebarColorPalette.map((color) {
                    final isSelected = currentColor.value == color.value;
                    return InkWell(
                      onTap: () {
                        onColorSelected(color);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: isSelected ? 12 : 4,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.black,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        onReset();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        'Par defaut',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: EskoliaTokens.cyan),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}