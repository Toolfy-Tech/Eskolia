import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/eskolia_card.dart';
import '../../data/tech_news_models.dart';
import '../../data/tech_news_repository.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../providers/home_providers.dart';
import 'home_card_settings_dialog.dart';

const Color _slate = EskoliaTokens.textSecondary;
const Color _slateLight = EskoliaTokens.textSecondary;
const Color _cyan = EskoliaTokens.cyan;

/// Bloc de veille RSS paramétrable et filtré par catégorie ou par créateur.
class TechNewsSection extends ConsumerStatefulWidget {
  const TechNewsSection({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.sourceFilter,
    this.isVeilleScreen = false,
  });

  final String category;
  final String title;
  final String subtitle;
  final String emoji;
  final String? sourceFilter;
  final bool isVeilleScreen;

  @override
  ConsumerState<TechNewsSection> createState() => _TechNewsSectionState();
}

class _TechNewsSectionState extends ConsumerState<TechNewsSection> {
  final TechNewsRepository _repo = TechNewsRepository();

  bool _loading = true;
  String? _error;
  List<TechNewsItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TechNewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceFilter != widget.sourceFilter || oldWidget.category != widget.category) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final subSources = ref.read(homeSubscribedSourcesProvider);
      final list = await _repo.loadNews(
        sourceFilter: widget.sourceFilter,
        subscribedSources: subSources,
      );
      if (!mounted) return;
      
      // Filtrage par catégorie si on n'a pas de filtre de source
      final filtered = widget.sourceFilter != null
          ? list
          : (widget.category == 'all'
              ? list
              : list.where((item) {
                  final itemCat = item.category == 'it_pro' ? 'it' : item.category;
                  return itemCat == widget.category;
                }).toList());
      
      setState(() {
        _items = filtered;
        _loading = false;
        _error = filtered.isEmpty
            ? 'Aucun article pour le moment. Réessaie plus tard.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les flux. Vérifie ta connexion.';
      });
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cardKey = widget.sourceFilter != null
        ? 'source:${widget.sourceFilter}'
        : (widget.category == 'all' ? 'it_pro' : widget.category);
    final isPinned = widget.isVeilleScreen
        ? ref.watch(veillePinnedCardsProvider).contains(cardKey)
        : ref.watch(homePinnedCardsProvider).contains(cardKey);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(cardKey);
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[cardKey];
    final isCollapsed = settings?.isCollapsed ?? false;

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : widget.title;
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : widget.emoji;

    final accentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned
            ? EskoliaTokens.cyan
            : (widget.sourceFilter != null
                ? EskoliaTokens.cyan
                : (widget.category == 'security' ? EskoliaTokens.error : _cyan)));

    final sortedItems = List<TechNewsItem>.from(_items);
    if (settings?.sortBy == 'oldest') {
      sortedItems.sort((a, b) {
        final aDate = a.publishedAt;
        final bDate = b.publishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
    } else {
      sortedItems.sort((a, b) {
        final aDate = a.publishedAt;
        final bDate = b.publishedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }

    final limit = settings?.limit ?? 5;
    final displayItems = sortedItems.take(limit).toList();

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(cardKey),
            child: Row(
              children: [
                EskoliaCardSectionBadge(
                  sectionName: 'VEILLE',
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                  onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(cardKey),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: _slateLight.withValues(alpha: 0.85),
                    size: 19,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: _slateLight.withValues(alpha: 0.85),
                    size: 19,
                  ),
                  tooltip: 'Options de la carte',
                  color: EskoliaTokens.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  onSelected: (action) {
                    if (action == 'refresh') {
                      _load();
                    } else if (action == 'settings') {
                      showHomeCardSettingsDialog(context, ref, cardKey);
                    } else if (action == 'merge') {
                      showMergeCardDialog(context, ref, cardKey);
                    } else if (action == 'pin') {
                      if (widget.isVeilleScreen) {
                        ref.read(veillePinnedCardsProvider.notifier).togglePin(cardKey);
                      } else {
                        ref.read(homePinnedCardsProvider.notifier).togglePin(cardKey);
                      }
                    } else if (action == 'home') {
                      if (isAddedToHome) {
                        ref.read(homeCardsOrderProvider.notifier).removeCard(cardKey);
                      } else {
                        ref.read(homeCardsOrderProvider.notifier).addCard(cardKey);
                      }
                    } else if (action == 'delete') {
                      if (widget.sourceFilter != null) {
                        ref.read(homeSubscribedSourcesProvider.notifier).unsubscribe(widget.sourceFilter!);
                      } else {
                        ref.read(homeCardsOrderProvider.notifier).removeCard(widget.category);
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Text('Actualiser le flux', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Text('Personnaliser', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'merge',
                      child: Row(
                        children: [
                          Icon(Icons.call_merge_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Text('Fusionner avec...', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: isPinned ? accentColor : Colors.white70, size: 18),
                          const SizedBox(width: 10),
                          Text(isPinned ? 'Désépingler' : 'Épingler', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'home',
                      child: Row(
                        children: [
                          Icon(isAddedToHome ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded, color: isAddedToHome ? EskoliaTokens.error : EskoliaTokens.cyan, size: 18),
                          const SizedBox(width: 10),
                          Text(isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (widget.sourceFilter != null || (widget.category != 'it_pro' && widget.category != 'all'))
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 18),
                            SizedBox(width: 10),
                            Text('Supprimer la carte', style: TextStyle(color: EskoliaTokens.error, fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 4),
            Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.95),
              fontSize: 11,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          if (_loading && _items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _cyan,
                  ),
                ),
              ),
            )
          else if (_error != null && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _slateLight.withValues(alpha: 0.92),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _load,
                    icon: Icon(Icons.replay_rounded, color: accentColor),
                    label: Text(
                      'Réessayer',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final favorites = ref.watch(homeFavoritesProvider);
                final isFav = favorites.any((x) => x.link == item.link);

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
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => ref.read(homeFavoritesProvider.notifier).toggle(item),
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                            color: isFav ? EskoliaTokens.error : _slateLight.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
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
                                        Text(
                                          '·',
                                          style: TextStyle(color: _slate.withValues(alpha: 0.5), fontSize: 11),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            item.pubDate!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _slate.withValues(alpha: 0.95),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        size: 13,
                                        color: _slateLight.withValues(alpha: 0.5),
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
