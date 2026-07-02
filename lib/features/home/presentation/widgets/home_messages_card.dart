import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../providers/home_providers.dart';
import 'home_card_settings_dialog.dart';

class HomeMessagesCard extends ConsumerStatefulWidget {
  const HomeMessagesCard({
    super.key,
    required this.username,
    this.streak = 0,
    this.isVeilleScreen = false,
  });

  final String username;
  final int streak;
  final bool isVeilleScreen;

  @override
  ConsumerState<HomeMessagesCard> createState() => _HomeMessagesCardState();
}

class _HomeMessagesCardState extends ConsumerState<HomeMessagesCard> {
  late final PageController _pageController;
  Timer? _scrollTimer;
  int _currentPage = 0;
  int _lastScrollInterval = 12;
  int _lastMessagesPerPage = 3;
  bool _isHovered = false;

  int get _totalPages {
    final messages = _buildMessages();
    if (messages.isEmpty) return 1;
    final settings = ref.read(homeCardSettingsProvider)['messages'];
    final messagesPerPage = settings?.limit ?? 3;
    return (messages.length / messagesPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();
    final messages = _buildMessages();
    final settings = ref.read(homeCardSettingsProvider)['messages'];
    final messagesPerPage = settings?.limit ?? 3;
    final scrollInterval = settings?.scrollInterval ?? 12;
    _lastMessagesPerPage = messagesPerPage;
    _lastScrollInterval = scrollInterval;
    
    final total = (messages.length / messagesPerPage).ceil();
    final initialPage = total > 0 ? 1000 * total : 0;
    _pageController = PageController(initialPage: initialPage);
    _currentPage = initialPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    final settings = ref.read(homeCardSettingsProvider)['messages'];
    final scrollInterval = settings?.scrollInterval ?? 12;
    _scrollTimer = Timer.periodic(Duration(seconds: scrollInterval), (timer) {
      if (!mounted) return;
      if (_isHovered) return;
      
      final messages = _buildMessages();
      final messagesPerPage = ref.read(homeCardSettingsProvider)['messages']?.limit ?? 3;
      final totalPages = (messages.length / messagesPerPage).ceil();
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

  List<String> _buildMessages() {
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

  String _sanitizeText(String text) {
    return text
        .replaceAll('’', "'")
        .replaceAll('—', "-")
        .replaceAll('«', '"')
        .replaceAll('»', '"')
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
            Text('Message copié dans le presse-papiers !'),
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
        ? ref.watch(veillePinnedCardsProvider).contains('messages')
        : ref.watch(homePinnedCardsProvider).contains('messages');
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('messages');
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['messages'];
    final isCollapsed = settings?.isCollapsed ?? false;
    final messagesPerPage = settings?.limit ?? 3;
    final scrollInterval = settings?.scrollInterval ?? 12;

    if (scrollInterval != _lastScrollInterval || messagesPerPage != _lastMessagesPerPage) {
      _lastScrollInterval = scrollInterval;
      _lastMessagesPerPage = messagesPerPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startAutoScroll();
        }
      });
    }

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : 'Messages d\'accueil';
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '👋';

    final accentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : EskoliaTokens.success);

    const Color slate = EskoliaTokens.textSecondary;

    final messages = _buildMessages();
    final displayMessages = List<String>.from(messages);
    if (settings?.sortBy == 'oldest') {
      displayMessages.sort((a, b) => b.compareTo(a));
    }

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('messages'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EskoliaCardSectionBadge(
                  sectionName: 'ACCUEIL',
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Personnaliser',
                  onPressed: () => showHomeCardSettingsDialog(context, ref, 'messages'),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: slate.withValues(alpha: 0.85),
                    size: 22,
                  ),
                ),

                IconButton(
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                  onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('messages'),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: slate.withValues(alpha: 0.85),
                    size: 20,
                  ),
                ),
                IconButton(
                  tooltip: isPinned ? 'Désépingler' : 'Épingler',
                  onPressed: () {
                    if (widget.isVeilleScreen) {
                      ref.read(veillePinnedCardsProvider.notifier).togglePin('messages');
                    } else {
                      ref.read(homePinnedCardsProvider.notifier).togglePin('messages');
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
                      ref.read(homeCardsOrderProvider.notifier).removeCard('messages');
                    } else {
                      ref.read(homeCardsOrderProvider.notifier).addCard('messages');
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
            Text(
              'Actualités de la plateforme et messages de bienvenue (${messages.length} messages)',
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
                height: (messagesPerPage * 62.0 + 15.0).clamp(120.0, 520.0),
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
                      if (displayMessages.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucun message disponible',
                            style: TextStyle(color: slate, fontSize: 13),
                          ),
                        );
                      }

                      final totalPages = (displayMessages.length / messagesPerPage).ceil();
                      final pageIndex = totalPages > 0 ? index % totalPages : 0;
                      final startIndex = pageIndex * messagesPerPage;
                      final endIndex = (startIndex + messagesPerPage).clamp(0, displayMessages.length);
                      final pageMessages = startIndex < displayMessages.length 
                          ? displayMessages.sublist(startIndex, endIndex)
                          : <String>[];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: pageMessages.map((msg) {
                            IconData icon = LucideIcons.info;
                            if (msg.startsWith('👋')) {
                              icon = LucideIcons.hand;
                            } else if (msg.startsWith('🔥')) {
                              icon = LucideIcons.flame;
                            } else if (msg.startsWith('📢')) {
                              icon = LucideIcons.megaphone;
                            } else if (msg.startsWith('🧠')) {
                              icon = LucideIcons.brain;
                            } else if (msg.startsWith('📝')) {
                              icon = LucideIcons.notebook;
                            } else if (msg.startsWith('🧪')) {
                              icon = LucideIcons.flaskConical;
                            } else if (msg.startsWith('🎮')) {
                              icon = LucideIcons.gamepad2;
                            } else if (msg.startsWith('🏆')) {
                              icon = LucideIcons.trophy;
                            } else if (msg.startsWith('🛠️')) {
                              icon = LucideIcons.wrench;
                            } else if (msg.startsWith('📖')) {
                              icon = LucideIcons.bookOpen;
                            } else if (msg.startsWith('🎖️')) {
                              icon = LucideIcons.award;
                            } else if (msg.startsWith('📡')) {
                              icon = LucideIcons.rss;
                            }

                            var cleanMsg = _sanitizeText(msg);
                            if (cleanMsg.length >= 2) {
                              final firstTwoChars = cleanMsg.substring(0, 2);
                              if (firstTwoChars.runes.first > 127) {
                                cleanMsg = cleanMsg.substring(2).trim();
                              }
                            }

                            return InkWell(
                              onTap: () {
                                _copyToClipboard(msg);
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
                                        icon,
                                        color: accentColor.withValues(alpha: 0.85),
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        cleanMsg,
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
