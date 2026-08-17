import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/eskolia_tokens.dart';

class ColumnPreferencesNotifier extends Notifier<Map<String, int>> {
  static const String _prefix = 'eskolia_cols_pref_';

  @override
  Map<String, int> build() {
    _loadAll();
    return const {};
  }

  Future<void> _loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
      final map = <String, int>{};
      for (final k in keys) {
        final screen = k.substring(_prefix.length);
        final val = prefs.getInt(k);
        if (val != null) map[screen] = val;
      }
      if (map.isNotEmpty) {
        state = {...state, ...map};
      }
    } catch (_) {}
  }

  Future<void> setColumns(String screenKey, int cols) async {
    state = {...state, screenKey: cols};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_prefix$screenKey', cols);
    } catch (_) {}
  }
}

final columnPreferencesProvider =
    NotifierProvider<ColumnPreferencesNotifier, Map<String, int>>(
  ColumnPreferencesNotifier.new,
);

final columnPreferenceProvider = Provider.family<int, String>(
  (ref, screenKey) => ref.watch(columnPreferencesProvider)[screenKey] ?? 0,
);

class ColumnResolution {
  const ColumnResolution({
    required this.columns,
    required this.cardWidth,
  });

  final int columns;
  final double cardWidth;

  static ColumnResolution compute({
    required int preference,
    required double availableWidth,
    int maxAutoColumns = 4,
    double minCardWidth = 240.0,
    double spacing = 16.0,
  }) {
    int cols;
    if (preference <= 0) {
      // Mode Auto
      if (availableWidth >= 1400 && maxAutoColumns >= 4) {
        cols = 4;
      } else if (availableWidth >= 1050 && maxAutoColumns >= 3) {
        cols = 3;
      } else if (availableWidth >= 660 && maxAutoColumns >= 2) {
        cols = 2;
      } else {
        cols = 1;
      }
    } else {
      // Mode Forcé par l'utilisateur (avec sécurité de largeur minimale)
      final maxPossible = (availableWidth / minCardWidth).floor().clamp(1, 4);
      cols = preference.clamp(1, maxPossible);
    }

    final double totalSpacing = (cols - 1) * spacing;
    final double cardW = ((availableWidth - totalSpacing) / cols).clamp(180.0, double.infinity);

    return ColumnResolution(
      columns: cols,
      cardWidth: cardW,
    );
  }
}

class EskoliaColumnSwitcherButton extends ConsumerWidget {
  const EskoliaColumnSwitcherButton({
    super.key,
    required this.screenKey,
    this.maxColumns = 4,
  });

  final String screenKey;
  final int maxColumns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPref = ref.watch(columnPreferenceProvider(screenKey));

    String label;
    IconData iconData;
    if (currentPref == 0) {
      label = 'Auto';
      iconData = Icons.auto_awesome_rounded;
    } else if (currentPref == 1) {
      label = '1 col';
      iconData = Icons.view_agenda_rounded;
    } else if (currentPref == 2) {
      label = '2 cols';
      iconData = Icons.grid_view_rounded;
    } else if (currentPref == 3) {
      label = '3 cols';
      iconData = Icons.view_column_rounded;
    } else {
      label = '4 cols';
      iconData = Icons.dashboard_customize_rounded;
    }

    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      tooltip: 'Disposition des colonnes ($label)',
      color: EskoliaTokens.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      onSelected: (cols) {
        ref.read(columnPreferencesProvider.notifier).setColumns(screenKey, cols);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: currentPref == 0 ? EskoliaTokens.cyan : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Automatique (Adaptatif)',
                style: TextStyle(
                  color: currentPref == 0 ? EskoliaTokens.cyan : Colors.white,
                  fontSize: 13,
                  fontWeight: currentPref == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.view_agenda_rounded,
                color: currentPref == 1 ? EskoliaTokens.cyan : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                '1 Colonne (Pleine largeur)',
                style: TextStyle(
                  color: currentPref == 1 ? EskoliaTokens.cyan : Colors.white,
                  fontSize: 13,
                  fontWeight: currentPref == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: currentPref == 2 ? EskoliaTokens.cyan : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                '2 Colonnes (Équilibré)',
                style: TextStyle(
                  color: currentPref == 2 ? EskoliaTokens.cyan : Colors.white,
                  fontSize: 13,
                  fontWeight: currentPref == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (maxColumns >= 3)
          PopupMenuItem(
            value: 3,
            child: Row(
              children: [
                Icon(
                  Icons.view_column_rounded,
                  color: currentPref == 3 ? EskoliaTokens.cyan : Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '3 Colonnes (Dense)',
                  style: TextStyle(
                    color: currentPref == 3 ? EskoliaTokens.cyan : Colors.white,
                    fontSize: 13,
                    fontWeight: currentPref == 3 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        if (maxColumns >= 4)
          PopupMenuItem(
            value: 4,
            child: Row(
              children: [
                Icon(
                  Icons.dashboard_customize_rounded,
                  color: currentPref == 4 ? EskoliaTokens.cyan : Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '4 Colonnes (Panoramique)',
                  style: TextStyle(
                    color: currentPref == 4 ? EskoliaTokens.cyan : Colors.white,
                    fontSize: 13,
                    fontWeight: currentPref == 4 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: currentPref != 0
                ? EskoliaTokens.cyan.withValues(alpha: 0.4)
                : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: currentPref != 0 ? EskoliaTokens.cyan : Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: currentPref != 0 ? EskoliaTokens.cyan : Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Répartit dynamiquement des éléments dans N colonnes selon la hauteur estimée (Masonry / Shortest Column First)
/// pour éviter les vides verticaux lorsqu'une carte est haute (ex: cours déroulé) et les autres repliées.
List<List<T>> distributeMasonryColumns<T>({
  required List<T> items,
  required int numColumns,
  required double Function(T item) estimateHeight,
}) {
  if (numColumns <= 1 || items.isEmpty) {
    return [items];
  }

  final cols = List.generate(numColumns, (_) => <T>[]);
  final colHeights = List.filled(numColumns, 0.0);

  for (final item in items) {
    int minCol = 0;
    for (var c = 1; c < numColumns; c++) {
      if (colHeights[c] < colHeights[minCol]) {
        minCol = c;
      }
    }
    cols[minCol].add(item);
    colHeights[minCol] += estimateHeight(item) + 16.0;
  }

  return cols;
}

/// Helper pour construire un Row de colonnes avec espacement vertical et horizontal
Widget buildMasonryColumnsRow({
  required List<List<Widget>> columns,
  double spacing = 16.0,
}) {
  if (columns.isEmpty) return const SizedBox.shrink();
  if (columns.length == 1) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _addVerticalSpacing(columns[0], spacing),
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < columns.length; i++) ...[
        if (i > 0) SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _addVerticalSpacing(columns[i], spacing),
          ),
        ),
      ],
    ],
  );
}

List<Widget> _addVerticalSpacing(List<Widget> list, double spacing) {
  if (list.isEmpty) return [];
  final res = <Widget>[];
  for (var i = 0; i < list.length; i++) {
    res.add(list[i]);
    if (i < list.length - 1) {
      res.add(SizedBox(height: spacing));
    }
  }
  return res;
}
