import 'dart:convert';

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

/// Gestionnaire de disposition multi-colonnes libre et persistante.
/// Permet à l'utilisateur de placer librement ses cartes dans n'importe quelle colonne
/// (par exemple 4 cartes à gauche et 1 à droite) par simple glisser-déposer.
class ScreenColumnBoardNotifier extends Notifier<Map<String, Map<int, List<String>>>> {
  static const String _prefPrefix = 'eskolia_board_layout_';

  @override
  Map<String, Map<int, List<String>>> build() {
    _loadAll();
    return const {};
  }

  Future<void> _loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefPrefix));
      final allMap = <String, Map<int, List<String>>>{};
      for (final k in keys) {
        final screenKey = k.substring(_prefPrefix.length);
        final jsonStr = prefs.getString(k);
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
          final map = <int, List<String>>{};
          decoded.forEach((colKey, listDynamic) {
            final colInt = int.tryParse(colKey);
            if (colInt != null && listDynamic is List) {
              map[colInt] = listDynamic.map((e) => e.toString()).toList();
            }
          });
          if (map.isNotEmpty) {
            allMap[screenKey] = map;
          }
        }
      }
      if (allMap.isNotEmpty) {
        state = {...state, ...allMap};
      }
    } catch (_) {}
  }

  /// Retourne la liste des clés de cartes réparties dans chaque colonne pour [numColumns].
  List<List<String>> getResolvedColumns({
    required String screenKey,
    required List<String> activeKeys,
    required int numColumns,
  }) {
    if (activeKeys.isEmpty) return List.generate(numColumns, (_) => <String>[]);
    if (numColumns <= 1) return [List.of(activeKeys)];

    final saved = state[screenKey] ?? const {};
    final result = List.generate(numColumns, (_) => <String>[]);
    final placed = <String>{};

    if (saved.isNotEmpty) {
      // 1. Placer les cartes selon la configuration personnalisée de l'utilisateur
      saved.forEach((colIdx, cardList) {
        final targetCol = colIdx < numColumns ? colIdx : (colIdx % numColumns);
        for (final key in cardList) {
          if (activeKeys.contains(key) && !placed.contains(key)) {
            result[targetCol].add(key);
            placed.add(key);
          }
        }
      });
    }

    // 2. Pour toute carte active non encore placée, la répartir séquentiellement
    for (final key in activeKeys) {
      if (!placed.contains(key)) {
        int minCol = 0;
        for (var c = 1; c < numColumns; c++) {
          if (result[c].length < result[minCol].length) {
            minCol = c;
          }
        }
        result[minCol].add(key);
        placed.add(key);
      }
    }

    return result;
  }

  /// Déplace une carte vers une colonne et une position spécifique (Glisser-Déposer libre).
  Future<void> moveCard({
    required String screenKey,
    required String cardKey,
    required int targetColumn,
    int? targetIndex,
    required List<String> activeKeys,
    required int numColumns,
  }) async {
    final currentCols = getResolvedColumns(
      screenKey: screenKey,
      activeKeys: activeKeys,
      numColumns: numColumns,
    );

    // 1. Retirer la carte de toutes les colonnes
    for (final col in currentCols) {
      col.remove(cardKey);
    }

    // 2. Insérer dans la colonne cible
    final safeCol = targetColumn.clamp(0, numColumns - 1);
    if (targetIndex != null && targetIndex >= 0 && targetIndex < currentCols[safeCol].length) {
      currentCols[safeCol].insert(targetIndex, cardKey);
    } else {
      currentCols[safeCol].add(cardKey);
    }

    // 3. Mettre à jour l'état
    final newMap = <int, List<String>>{};
    for (var i = 0; i < currentCols.length; i++) {
      newMap[i] = currentCols[i];
    }
    state = {...state, screenKey: newMap};

    // 4. Persister
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonMap = <String, dynamic>{};
      newMap.forEach((k, v) => jsonMap[k.toString()] = v);
      await prefs.setString('$_prefPrefix$screenKey', jsonEncode(jsonMap));
    } catch (_) {}
  }
}

final screenColumnBoardProvider =
    NotifierProvider<ScreenColumnBoardNotifier, Map<String, Map<int, List<String>>>>(
  ScreenColumnBoardNotifier.new,
);

/// Répartit séquentiellement des éléments dans N colonnes (Round-robin déterministe).
List<List<T>> distributeMasonryColumns<T>({
  required List<T> items,
  required int numColumns,
  double Function(T item)? estimateHeight,
}) {
  if (numColumns <= 1 || items.isEmpty) {
    return [items];
  }

  final columns = List.generate(numColumns, (_) => <T>[]);
  for (var i = 0; i < items.length; i++) {
    columns[i % numColumns].add(items[i]);
  }
  return columns;
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

/// Tableau multi-colonnes interactif avec Glisser-Déposer libre entre colonnes.
/// Permet à l'utilisateur d'organiser ses cartes comme il le souhaite (ex: 4 à gauche, 1 à droite).
class EskoliaMultiColumnBoard extends ConsumerWidget {
  const EskoliaMultiColumnBoard({
    super.key,
    required this.screenKey,
    required this.activeKeys,
    required this.numColumns,
    required this.cardWidth,
    required this.cardBuilder,
    this.spacing = 16.0,
  });

  final String screenKey;
  final List<String> activeKeys;
  final int numColumns;
  final double cardWidth;
  final Widget Function(BuildContext context, String key) cardBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activeKeys.isEmpty) return const SizedBox.shrink();

    // Mode 1 colonne (Mobile / compact)
    if (numColumns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < activeKeys.length; i++) ...[
            _buildDraggableCard(
              context: context,
              ref: ref,
              key: activeKeys[i],
              columnIndex: 0,
              cardIndex: i,
              child: cardBuilder(context, activeKeys[i]),
              cardWidth: cardWidth,
            ),
            if (i < activeKeys.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    final resolvedColumns = ref.watch(screenColumnBoardProvider.notifier).getResolvedColumns(
          screenKey: screenKey,
          activeKeys: activeKeys,
          numColumns: numColumns,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var colIdx = 0; colIdx < numColumns; colIdx++) ...[
          if (colIdx > 0) SizedBox(width: spacing),
          Expanded(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                ref.read(screenColumnBoardProvider.notifier).moveCard(
                      screenKey: screenKey,
                      cardKey: details.data,
                      targetColumn: colIdx,
                      targetIndex: null, // ajout à la fin de la colonne
                      activeKeys: activeKeys,
                      numColumns: numColumns,
                    );
              },
              builder: (context, candidateData, rejectedData) {
                final isColHovered = candidateData.isNotEmpty;
                final cardsInCol = resolvedColumns[colIdx];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isColHovered && cardsInCol.isEmpty
                          ? EskoliaTokens.cyan.withValues(alpha: 0.8)
                          : Colors.transparent,
                      width: 2.0,
                    ),
                    color: isColHovered && cardsInCol.isEmpty
                        ? EskoliaTokens.cyan.withValues(alpha: 0.06)
                        : Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var cardIdx = 0; cardIdx < cardsInCol.length; cardIdx++) ...[
                        _buildDraggableCard(
                          context: context,
                          ref: ref,
                          key: cardsInCol[cardIdx],
                          columnIndex: colIdx,
                          cardIndex: cardIdx,
                          child: cardBuilder(context, cardsInCol[cardIdx]),
                          cardWidth: cardWidth,
                        ),
                        if (cardIdx < cardsInCol.length - 1) SizedBox(height: spacing),
                      ],
                      if (cardsInCol.isEmpty)
                        _buildEmptyColumnDropZone(context, isColHovered),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyColumnDropZone(BuildContext context, bool isHovered) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: isHovered
            ? EskoliaTokens.cyan.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovered
              ? EskoliaTokens.cyan.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          width: isHovered ? 2.0 : 1.0,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_photos_rounded,
              color: isHovered ? EskoliaTokens.cyan : Colors.white24,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Glisser une carte ici',
              style: TextStyle(
                color: isHovered ? EskoliaTokens.cyan : Colors.white30,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableCard({
    required BuildContext context,
    required WidgetRef ref,
    required String key,
    required int columnIndex,
    required int cardIndex,
    required Widget child,
    required double cardWidth,
  }) {
    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.03,
        child: Transform.scale(
          scale: 1.03,
          child: Opacity(
            opacity: 0.9,
            child: SizedBox(
              width: cardWidth,
              child: child,
            ),
          ),
        ),
      ),
    );

    return DragTarget<String>(
      key: ValueKey(key),
      onWillAcceptWithDetails: (details) => details.data != key,
      onAcceptWithDetails: (details) {
        ref.read(screenColumnBoardProvider.notifier).moveCard(
              screenKey: screenKey,
              cardKey: details.data,
              targetColumn: columnIndex,
              targetIndex: cardIndex,
              activeKeys: activeKeys,
              numColumns: numColumns,
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        final cardWidget = SizedBox(
          width: cardWidth,
          child: child,
        );

        final mainChild = LongPressDraggable<String>(
          key: ValueKey('${key}_drag'),
          data: key,
          delay: const Duration(milliseconds: 250),
          feedback: feedbackWidget,
          childWhenDragging: Opacity(
            opacity: 0.2,
            child: cardWidget,
          ),
          child: cardWidget,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? EskoliaTokens.cyan.withValues(alpha: 0.8) : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: EskoliaTokens.cyan.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: mainChild,
          ),
        );
      },
    );
  }
}
