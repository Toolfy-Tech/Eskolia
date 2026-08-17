import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../data/home_repository.dart';
import '../providers/home_providers.dart';
import 'home_card_settings_dialog.dart';

class HomeAstucesCard extends ConsumerStatefulWidget {
  const HomeAstucesCard({
    super.key,
    this.isVeilleScreen = false,
  });

  final bool isVeilleScreen;

  @override
  ConsumerState<HomeAstucesCard> createState() => _HomeAstucesCardState();
}

class _HomeAstucesCardState extends ConsumerState<HomeAstucesCard> {
  final HomeRepository _repo = HomeRepository();
  List<String> _allTips = [];
  List<String> _currentTips = [];
  
  late final PageController _pageController;
  Timer? _scrollTimer;
  int _currentPage = 0;
  int _lastScrollInterval = 12;
  int _lastTipsPerPage = 4;
  bool _isHovered = false;

  int get _totalPages {
    if (_currentTips.isEmpty) return 1;
    final settings = ref.read(homeCardSettingsProvider)['astuces'];
    final tipsPerPage = settings?.limit ?? 4;
    return (_currentTips.length / tipsPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();
    _allTips = _repo.getLocalTips();
    _currentTips = List<String>.from(_allTips);
    
    final settings = ref.read(homeCardSettingsProvider)['astuces'];
    _lastTipsPerPage = settings?.limit ?? 4;
    _lastScrollInterval = settings?.scrollInterval ?? 12;

    // Déterminer la page de départ pour le scroll infini virtuel
    final initialPage = _totalPages > 0 ? 1000 * _totalPages : 0;
    _pageController = PageController(initialPage: initialPage);
    _currentPage = initialPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _shuffleTips() {
    final list = List<String>.from(_allTips)..shuffle();
    setState(() {
      _currentTips = list;
    });
    if (mounted && _totalPages > 0) {
      final initialPage = 1000 * _totalPages;
      _currentPage = initialPage;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(initialPage);
      }
    }
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    final settings = ref.read(homeCardSettingsProvider)['astuces'];
    final scrollInterval = settings?.scrollInterval ?? 12;
    _scrollTimer = Timer.periodic(Duration(seconds: scrollInterval), (timer) {
      if (!mounted) return;
      if (_isHovered) return;
      
      final tipsPerPage = ref.read(homeCardSettingsProvider)['astuces']?.limit ?? 4;
      final totalPages = (_currentTips.length / tipsPerPage).ceil();
      if (_pageController.hasClients && totalPages > 0) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll('’', "'")
        .replaceAll('—', "-")
        .replaceAll('«', '"')
        .replaceAll('»', '"')
        .replaceAll('💬', '')
        .replaceAll('\u{1F4AC}', '')
        .trim();
  }

  Future<void> _copyToClipboard(String rawText) async {
    await Clipboard.setData(ClipboardData(text: rawText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline_rounded, color: EskoliaTokens.success, size: 18),
            SizedBox(width: 8),
            Text('Astuce copiée dans le presse-papiers !'),
          ],
        ),
        backgroundColor: EskoliaTokens.surface1,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPinned = widget.isVeilleScreen
        ? ref.watch(veillePinnedCardsProvider).contains('astuces')
        : ref.watch(homePinnedCardsProvider).contains('astuces');
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('astuces');
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['astuces'];
    final isCollapsed = settings?.isCollapsed ?? false;
    final tipsPerPage = settings?.limit ?? 4;
    final scrollInterval = settings?.scrollInterval ?? 12;

    if (scrollInterval != _lastScrollInterval || tipsPerPage != _lastTipsPerPage) {
      _lastScrollInterval = scrollInterval;
      _lastTipsPerPage = tipsPerPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startAutoScroll();
        }
      });
    }

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : 'Astuces Pro';
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '💡';

    final accentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : EskoliaTokens.amber);

    const Color slate = EskoliaTokens.textSecondary;

    final displayTips = List<String>.from(_currentTips);
    if (settings?.sortBy == 'oldest') {
      displayTips.sort((a, b) => b.compareTo(a));
    }

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
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('astuces'),
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
                      fontSize: 16,
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
                tooltip: 'Mélanger les astuces',
                onPressed: () {
                  _shuffleTips();
                  _startAutoScroll();
                },
                icon: const Icon(
                  Icons.shuffle_rounded,
                  color: slate,
                  size: 18,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('astuces'),
                icon: Icon(
                  isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: slate.withValues(alpha: 0.85),
                  size: 18,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Personnaliser',
                onPressed: () => showHomeCardSettingsDialog(context, ref, 'astuces'),
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: slate.withValues(alpha: 0.85),
                  size: 20,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: isPinned ? 'Désépingler' : 'Épingler',
                onPressed: () {
                  if (widget.isVeilleScreen) {
                    ref.read(veillePinnedCardsProvider.notifier).togglePin('astuces');
                  } else {
                    ref.read(homePinnedCardsProvider.notifier).togglePin('astuces');
                  }
                },
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? accentColor : slate.withValues(alpha: 0.5),
                  size: 17,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                onPressed: () {
                  if (isAddedToHome) {
                    ref.read(homeCardsOrderProvider.notifier).removeCard('astuces');
                  } else {
                    ref.read(homeCardsOrderProvider.notifier).addCard('astuces');
                  }
                },
                icon: Icon(
                  isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                  color: isAddedToHome ? EskoliaTokens.cyan : slate.withValues(alpha: 0.5),
                  size: 17,
                ),
              ),
            ],
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 4),
            Text(
              'Conseils d\'administration système, réseau et cybersécurité (${_allTips.length} astuces)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: slate,
                fontSize: 11,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) {
                setState(() => _isHovered = false);
                _startAutoScroll();
              },
              child: Container(
                height: (tipsPerPage * 52.0 + 15.0).clamp(120.0, 500.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      _currentPage = index;
                    },
                    itemBuilder: (context, index) {
                      if (displayTips.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucune astuce disponible',
                            style: TextStyle(color: slate, fontSize: 13),
                          ),
                        );
                      }

                      final totalPages = (displayTips.length / tipsPerPage).ceil();
                      final pageIndex = totalPages > 0 ? index % totalPages : 0;
                      final startIndex = pageIndex * tipsPerPage;
                      final endIndex = (startIndex + tipsPerPage).clamp(0, displayTips.length);
                      final pageTips = startIndex < displayTips.length 
                          ? displayTips.sublist(startIndex, endIndex)
                          : <String>[];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: pageTips.map((tip) {
                            final cleanTip = _sanitizeText(tip);

                            return InkWell(
                              onTap: () {
                                _copyToClipboard(cleanTip);
                                _startAutoScroll();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        LucideIcons.lightbulb,
                                        color: accentColor.withValues(alpha: 0.85),
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        cleanTip,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                          height: 1.35,
                                          fontFamily: 'sans-serif',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
