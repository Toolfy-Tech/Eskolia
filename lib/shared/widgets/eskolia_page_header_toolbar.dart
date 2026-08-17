import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import 'eskolia_column_switcher.dart';

class EskoliaCardOption {
  const EskoliaCardOption({
    required this.key,
    required this.title,
    required this.emoji,
    this.icon,
  });

  final String key;
  final String title;
  final String emoji;
  final IconData? icon;
}

/// Barre d'en-tête de page unifiée pour les 7 hubs d'Eskolia
class EskoliaPageHeaderToolbar extends ConsumerWidget {
  const EskoliaPageHeaderToolbar({
    super.key,
    required this.title,
    required this.screenKey,
    this.onInfoTap,
    this.onCollapseAll,
    this.onExpandAll,
    this.extraActions = const [],
    this.availableCards = const [],
    this.maxColumns = 4,
  });

  final String title;
  final String screenKey;
  final VoidCallback? onInfoTap;
  final VoidCallback? onCollapseAll;
  final VoidCallback? onExpandAll;
  final List<Widget> extraActions;
  final List<EskoliaCardOption> availableCards;
  final int maxColumns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeOrder = ref.watch(homeCardsOrderProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final titleWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (onInfoTap != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: EskoliaTokens.cyan, size: 20),
                  tooltip: 'Comment ça marche ?',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: onInfoTap,
                ),
              ],
            ],
          );

          final actionsWidget = Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...extraActions,
              if (onCollapseAll != null)
                TextButton.icon(
                  onPressed: onCollapseAll,
                  icon: const Icon(Icons.unfold_less_rounded, color: Colors.white70, size: 16),
                  label: const Text(
                    'Tout masquer',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (onExpandAll != null)
                TextButton.icon(
                  onPressed: onExpandAll,
                  icon: const Icon(Icons.unfold_more_rounded, color: Colors.white70, size: 16),
                  label: const Text(
                    'Tout afficher',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              EskoliaColumnSwitcherButton(
                screenKey: screenKey,
                maxColumns: maxColumns,
              ),
              if (availableCards.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white70, size: 20),
                  tooltip: 'Gérer / Ajouter des cartes',
                  color: EskoliaTokens.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  onSelected: (cardKey) {
                    final isAdded = homeOrder.contains(cardKey);
                    if (isAdded) {
                      ref.read(homeCardsOrderProvider.notifier).removeCard(cardKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Carte retirée de l\'accueil'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ref.read(homeCardsOrderProvider.notifier).addCard(cardKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Carte ajoutée à l\'accueil'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => availableCards.map((c) {
                    final isAdded = homeOrder.contains(c.key);
                    return PopupMenuItem<String>(
                      value: c.key,
                      child: Row(
                        children: [
                          Icon(
                            isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                            color: isAdded ? EskoliaTokens.success : EskoliaTokens.cyan,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          if (c.emoji.isNotEmpty) ...[
                            Text(c.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              isAdded ? 'Retirer "${c.title}" de l\'accueil' : 'Ajouter "${c.title}" à l\'accueil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: isAdded ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                titleWidget,
                const SizedBox(height: 12),
                actionsWidget,
              ],
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Center(child: titleWidget),
              Positioned(
                right: 0,
                child: actionsWidget,
              ),
            ],
          );
        },
      ),
    );
  }
}
