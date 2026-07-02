import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../providers/home_providers.dart';
import 'home_card_settings_dialog.dart';
import '../../data/tech_news_models.dart';

class HomeFavorisCard extends ConsumerWidget {
  const HomeFavorisCard({
    super.key,
    this.isVeilleScreen = false,
  });

  final bool isVeilleScreen;

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(homeFavoritesProvider);
    final isPinned = isVeilleScreen
        ? ref.watch(veillePinnedCardsProvider).contains('favoris')
        : ref.watch(homePinnedCardsProvider).contains('favoris');
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('favoris');
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['favoris'];
    final isCollapsed = settings?.isCollapsed ?? false;

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : 'Articles Favoris';
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '❤️';

    final accentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : EskoliaTokens.violet);

    const Color slate = EskoliaTokens.textSecondary;
    const Color slateLight = EskoliaTokens.textSecondary;

    final sortedFavs = List<TechNewsItem>.from(favorites);
    if (settings?.sortBy == 'oldest') {
      sortedFavs.sort((a, b) {
        final aDate = a.publishedAt;
        final bDate = b.publishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
    } else {
      sortedFavs.sort((a, b) {
        final aDate = a.publishedAt;
        final bDate = b.publishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }

    final limit = settings?.limit ?? 10;
    final displayFavs = sortedFavs.take(limit).toList();

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('favoris'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EskoliaCardSectionBadge(
                  sectionName: 'VEILLE',
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Personnaliser',
                  onPressed: () => showHomeCardSettingsDialog(context, ref, 'favoris'),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: slateLight.withValues(alpha: 0.85),
                    size: 22,
                  ),
                ),

                IconButton(
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                  onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('favoris'),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: slateLight.withValues(alpha: 0.85),
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: isPinned ? 'Désépingler' : 'Épingler',
                  onPressed: () {
                    if (isVeilleScreen) {
                      ref.read(veillePinnedCardsProvider.notifier).togglePin('favoris');
                    } else {
                      ref.read(homePinnedCardsProvider.notifier).togglePin('favoris');
                    }
                  },
                  icon: Icon(
                    isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: isPinned ? accentColor : slate.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                  onPressed: () {
                    if (isAddedToHome) {
                      ref.read(homeCardsOrderProvider.notifier).removeCard('favoris');
                    } else {
                      ref.read(homeCardsOrderProvider.notifier).addCard('favoris');
                    }
                  },
                  icon: Icon(
                    isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isAddedToHome ? EskoliaTokens.cyan : slate.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 4),
            const Text(
            'Vos articles de veille archivés — cliquez sur le cœur pour les retirer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: slate,
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          if (favorites.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: slate.withValues(alpha: 0.4),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucun article favori.\nCliquez sur le cœur d\'un article pour l\'épingler ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: slate,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayFavs.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, index) {
                final item = displayFavs[index];

                // Abonnement Source
                final isSourceSubscribed = ref.watch(homeSubscribedSourcesProvider).contains(item.sourceLabel);

                // Abonnement Thème
                final itemCategory = item.category == 'it_pro' ? 'it' : item.category;
                final isThemeActive = ref.watch(homeCardsOrderProvider).contains(itemCategory);
                final isBaseTheme = itemCategory == 'general' || itemCategory == 'all';
                String themeLabel;
                Color themeColor;
                switch (itemCategory) {
                  case 'it':
                    themeLabel = 'IT';
                    themeColor = EskoliaTokens.cyan;
                    break;
                  case 'security':
                    themeLabel = 'Sécurité';
                    themeColor = EskoliaTokens.error;
                    break;
                  case 'hardware':
                    themeLabel = 'Hardware';
                    themeColor = Colors.orange;
                    break;
                  case 'software':
                    themeLabel = 'Software';
                    themeColor = Colors.purpleAccent;
                    break;
                  default:
                    themeLabel = 'Général';
                    themeColor = EskoliaTokens.cyan;
                }

                return Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => ref.read(homeFavoritesProvider.notifier).toggle(item),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: EskoliaTokens.error,
                            size: 20,
                          ),
                          tooltip: 'Retirer des favoris',
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLink(item.link),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Badge de Source Cliquable
                                      InkWell(
                                        onTap: () {
                                          final notifier = ref.read(homeSubscribedSourcesProvider.notifier);
                                          if (isSourceSubscribed) {
                                            notifier.unsubscribe(item.sourceLabel);
                                          } else {
                                            notifier.subscribe(item.sourceLabel);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: isSourceSubscribed
                                                ? EskoliaTokens.cyan.withValues(alpha: 0.18)
                                                : Colors.white.withValues(alpha: 0.05),
                                            border: Border.all(
                                              color: isSourceSubscribed
                                                  ? EskoliaTokens.cyan.withValues(alpha: 0.4)
                                                  : Colors.white12,
                                            ),
                                          ),
                                          child: Text(
                                            isSourceSubscribed ? '✓ ${item.sourceLabel}' : '+ ${item.sourceLabel}',
                                            style: TextStyle(
                                              color: isSourceSubscribed ? EskoliaTokens.cyan : Colors.white70,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Badge de Thème Cliquable
                                      isBaseTheme
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                color: themeColor.withValues(alpha: 0.12),
                                                border: Border.all(
                                                  color: themeColor.withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: Text(
                                                themeLabel,
                                                style: TextStyle(
                                                  color: themeColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                final notifier = ref.read(homeCardsOrderProvider.notifier);
                                                if (isThemeActive) {
                                                  notifier.removeCard(itemCategory);
                                                } else {
                                                  notifier.addCard(itemCategory);
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(6),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: isThemeActive
                                                      ? themeColor.withValues(alpha: 0.18)
                                                      : Colors.white.withValues(alpha: 0.05),
                                                  border: Border.all(
                                                    color: isThemeActive
                                                        ? themeColor.withValues(alpha: 0.4)
                                                        : Colors.white12,
                                                  ),
                                                ),
                                                child: Text(
                                                  isThemeActive ? '✓ $themeLabel' : '+ $themeLabel',
                                                  style: TextStyle(
                                                    color: isThemeActive ? themeColor : Colors.white70,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      if (item.pubDate != null && item.pubDate!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        const Text(
                                          '·',
                                          style: TextStyle(color: Colors.white30, fontSize: 11),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            item.pubDate!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: slate,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        size: 13,
                                        color: slateLight.withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
