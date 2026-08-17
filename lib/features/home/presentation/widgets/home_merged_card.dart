import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../data/tech_news_models.dart';
import '../../data/tech_news_repository.dart';
import '../../data/home_repository.dart';
import '../providers/home_providers.dart';
import 'home_card_settings_dialog.dart';

class MergedCardItem {
  final String emoji;
  final String text;
  final String? link;
  final DateTime? date;
  final String? sourceLabel;
  final String? pubDate;

  MergedCardItem({
    required this.emoji,
    required this.text,
    this.link,
    this.date,
    this.sourceLabel,
    this.pubDate,
  });
}

class HomeMergedCard extends ConsumerStatefulWidget {
  const HomeMergedCard({
    super.key,
    required this.mergeKey,
    required this.username,
    required this.streak,
  });

  final String mergeKey;
  final String username;
  final int streak;

  @override
  ConsumerState<HomeMergedCard> createState() => _HomeMergedCardState();
}

class _HomeMergedCardState extends ConsumerState<HomeMergedCard> {
  final TechNewsRepository _rssRepo = TechNewsRepository();
  final HomeRepository _homeRepo = HomeRepository();

  bool _loading = false;
  List<MergedCardItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadMergedContent();
  }

  @override
  void didUpdateWidget(covariant HomeMergedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mergeKey != widget.mergeKey ||
        oldWidget.username != widget.username ||
        oldWidget.streak != widget.streak) {
      _loadMergedContent();
    }
  }

  List<String> _buildLocalMessages() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : (hour < 18 ? 'Bon après-midi' : 'Bonsoir');
    final name = widget.username.isNotEmpty ? widget.username : "l'ami";

    final list = <String>[
      '👋 $greeting $name ! Ravi de te revoir sur Eskolia. Prêt à relever de nouveaux défis aujourd\'hui ?',
    ];

    if (widget.streak >= 1) {
      list.add('🔥 Signal stable — Série active de ${widget.streak} jour${widget.streak > 1 ? "s" : ""} ! Continue ainsi !');
    }

    list.addAll([
      '📢 Mode Solo : Utilise le Vrai/Faux pour de l\'évaluation rapide, le mode Survival (3 vies) pour te dépasser, ou la Maîtrise pour réviser sur-mesure.',
      '🧠 Mon IA : Optimus, ton tuteur virtuel, t\'aide à comprendre n\'importe quel concept réseau ou à t\'exercer à la volée.',
      '📝 Bloc-notes : Prends tes notes de cours en Markdown et laisse l\'IA générer instantanément un QCM adapté !',
      '🧪 Le Labo : Propose tes propres questions de quiz, fais-les valider par le prof et contribue à l\'apprentissage commun.',
      '🎮 Lobbys : Rejoins ou crée un salon multijoueur pour affronter tes camarades en direct sur des séries de questions !',
      '🏆 Classement : Monte dans le classement hebdomadaire, gagne de l\'XP et qualifie-toi pour la ligue supérieure !',
      '🛠️ Travaux Pratiques : Simule des pannes réseau réelles, écris du PowerShell ou administre Active Directory.',
      '📖 Documentation : Accède à des mini-cours synthétiques et des fiches mémo (ITIL, RGPD, ANSSI, Modèle OSI).',
      '🎖️ Hauts faits : Débloque des badges exclusifs en réalisant des séries de connexions ou des sans-fautes !',
      '📡 Flux & Sources : Personnalise ton Espace Veille en ajoutant tes propres flux RSS technologiques.',
    ]);

    return list;
  }

  Future<void> _loadMergedContent() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final subKeys = widget.mergeKey.substring(6).split('+');
      final compiledItems = <MergedCardItem>[];

      final rssKeys = <String>[];
      final loadLocalMessages = subKeys.contains('messages');
      final loadLocalTips = subKeys.contains('astuces');
      final loadLocalFavs = subKeys.contains('favoris');

      for (final k in subKeys) {
        if (k == 'it_pro' ||
            k == 'it' ||
            k == 'security' ||
            k == 'hardware' ||
            k == 'software' ||
            k.startsWith('source:')) {
          rssKeys.add(k);
        }
      }

      // 1. Charger les messages
      if (loadLocalMessages) {
        final msgs = _buildLocalMessages();
        for (final m in msgs) {
          String msgEmoji = '📢';
          if (m.startsWith('👋')) {
            msgEmoji = '👋';
          } else if (m.startsWith('🔥')) {
            msgEmoji = '🔥';
          } else if (m.startsWith('🧠')) {
            msgEmoji = '🧠';
          } else if (m.startsWith('📝')) {
            msgEmoji = '📝';
          } else if (m.startsWith('🧪')) {
            msgEmoji = '🧪';
          } else if (m.startsWith('🎮')) {
            msgEmoji = '🎮';
          } else if (m.startsWith('🏆')) {
            msgEmoji = '🏆';
          } else if (m.startsWith('🛠️')) {
            msgEmoji = '🛠️';
          } else if (m.startsWith('📖')) {
            msgEmoji = '📖';
          } else if (m.startsWith('🎖️')) {
            msgEmoji = '🎖️';
          } else if (m.startsWith('📡')) {
            msgEmoji = '📡';
          }

          var cleanText = m.trim();
          if (cleanText.length >= 2) {
            final firstTwoChars = cleanText.substring(0, 2);
            if (firstTwoChars.runes.first > 127) { // Emoji
              cleanText = cleanText.substring(2).trim();
            }
          }

          compiledItems.add(MergedCardItem(
            emoji: msgEmoji,
            text: cleanText,
          ));
        }
      }

      // 2. Charger les astuces
      if (loadLocalTips) {
        final tips = _homeRepo.getLocalTips();
        for (final t in tips) {
          var cleanText = t.trim();
          if (cleanText.startsWith('💬')) {
            cleanText = cleanText.substring(1).trim();
          } else if (cleanText.startsWith('\u{1F4AC}')) {
            cleanText = cleanText.substring(1).trim();
          }

          compiledItems.add(MergedCardItem(
            emoji: '💡',
            text: cleanText,
          ));
        }
      }

      // 3. Charger les favoris
      if (loadLocalFavs) {
        final favs = ref.read(homeFavoritesProvider);
        for (final f in favs) {
          compiledItems.add(MergedCardItem(
            emoji: '❤️',
            text: f.title,
            link: f.link,
            date: f.publishedAt,
            sourceLabel: f.sourceLabel,
            pubDate: f.pubDate,
          ));
        }
      }

      // 4. Charger les flux RSS
      if (rssKeys.isNotEmpty) {
        final subSources = ref.read(homeSubscribedSourcesProvider);
        final futures = rssKeys.map((k) {
          final src = k.startsWith('source:') ? k.substring(7) : null;
          return _rssRepo.loadNews(
            sourceFilter: src,
            subscribedSources: subSources,
          ).then((articles) {
            // Filtrer par catégorie si ce n'est pas "it_pro" ou une source spécifique
            if (src == null && k != 'it_pro') {
              return articles.where((a) {
                final itemCat = a.category == 'it_pro' ? 'it' : a.category;
                return itemCat == k;
              }).toList();
            }
            return articles;
          });
        }).toList();

        final results = await Future.wait(futures);
        for (final list in results) {
          for (final a in list) {
            compiledItems.add(MergedCardItem(
              emoji: '📡',
              text: a.title,
              link: a.link,
              date: a.publishedAt,
              sourceLabel: a.sourceLabel,
              pubDate: a.pubDate,
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _items = compiledItems;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleItemTap(MergedCardItem item) async {
    if (item.link != null) {
      final uri = Uri.tryParse(item.link!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      await Clipboard.setData(ClipboardData(text: item.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded, color: EskoliaTokens.success, size: 18),
              SizedBox(width: 8),
              Text('Contenu copié dans le presse-papiers !'),
            ],
          ),
          backgroundColor: EskoliaTokens.surface1,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinned = ref.watch(homePinnedCardsProvider).contains(widget.mergeKey);
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[widget.mergeKey];
    final isCollapsed = settings?.isCollapsed ?? false;

    // Générer le titre par défaut de la fusion
    final subKeys = widget.mergeKey.substring(6).split('+');
    String getCardTitle(String k) {
      final s = settingsMap[k];
      if (s?.title.isNotEmpty == true) return s!.title;
      if (k == 'it_pro') return 'Veille Générale';
      if (k == 'favoris') return 'Favoris';
      if (k == 'messages') return 'Messages';
      if (k == 'astuces') return 'Astuces';
      if (k.startsWith('source:')) {
        final srcName = k.substring(7);
        if (srcName.startsWith('custom:')) {
          try {
            final map = jsonDecode(srcName.substring(7)) as Map<String, dynamic>;
            return map['label'] as String? ?? 'Flux perso';
          } catch (_) {}
        }
        return srcName;
      }
      if (k == 'security') return 'Sécurité';
      if (k == 'it') return 'Veille IT';
      if (k == 'hardware') return 'Veille Hardware';
      if (k == 'software') return 'Veille Software';
      return k;
    }
    final defaultTitle = 'Fusion : ${subKeys.map(getCardTitle).join(' + ')}';

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : defaultTitle;
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '🔀';

    final accentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : Colors.blueGrey);

    const Color slate = EskoliaTokens.textSecondary;

    final sortedItems = List<MergedCardItem>.from(_items);
    if (settings?.sortBy == 'oldest') {
      sortedItems.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });
    } else {
      // newest by default
      sortedItems.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
    }

    final limit = settings?.limit ?? 5;
    final displayItems = sortedItems.take(limit).toList();

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ligne 1 : Badge + Titre
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(widget.mergeKey),
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
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Ligne 2 : Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(widget.mergeKey),
                icon: Icon(
                  isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: slate.withValues(alpha: 0.85),
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: slate.withValues(alpha: 0.85),
                  size: 19,
                ),
                tooltip: 'Options de la carte',
                color: EskoliaTokens.surface1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                onSelected: (action) {
                  if (action == 'settings') {
                    showHomeCardSettingsDialog(context, ref, widget.mergeKey);
                  } else if (action == 'unmerge') {
                    ref.read(homeCardsOrderProvider.notifier).unmergeCard(widget.mergeKey);
                  } else if (action == 'pin') {
                    ref.read(homePinnedCardsProvider.notifier).togglePin(widget.mergeKey);
                  }
                },
                itemBuilder: (ctx) => [
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
                    value: 'unmerge',
                    child: Row(
                      children: [
                        Icon(Icons.call_split_rounded, color: Colors.white70, size: 18),
                        SizedBox(width: 10),
                        Text('Séparer les cartes', style: TextStyle(color: Colors.white, fontSize: 13)),
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
                ],
              ),
            ],
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 4),
            Text(
              'Carte fusionnée contenant ${subKeys.length} sources de données',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: slate,
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
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: EskoliaTokens.cyan,
                    ),
                  ),
                ),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Aucun contenu disponible pour cette fusion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: slate, fontSize: 13),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayItems.length,
                separatorBuilder: (_, __) => Divider(
                  height: 12,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  return InkWell(
                    onTap: () => _handleItemTap(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              getIconDataForEmoji(item.emoji),
                              color: accentColor,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                                if (item.sourceLabel != null || item.pubDate != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item.sourceLabel != null)
                                        Text(
                                          item.sourceLabel!,
                                          style: const TextStyle(
                                            color: EskoliaTokens.cyan,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (item.sourceLabel != null && item.pubDate != null)
                                        const Text(
                                          ' · ',
                                          style: TextStyle(color: slate, fontSize: 9),
                                        ),
                                      if (item.pubDate != null)
                                        Flexible(
                                          child: Text(
                                            item.pubDate!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: slate,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (item.link != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 13,
                              color: slate.withValues(alpha: 0.5),
                            ),
                          ],
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
