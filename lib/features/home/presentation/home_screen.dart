import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'widgets/home_card_settings_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/onboarding_prefs.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../auth/data/user_model.dart';
import '../../economy/data/achievement_triggers.dart';
import '../data/home_repository.dart';
import 'providers/home_providers.dart';
import 'widgets/tech_news_section.dart';
import 'widgets/home_favoris_card.dart';
import 'widgets/home_astuces_card.dart';
import 'widgets/home_messages_card.dart';
import 'widgets/home_merged_card.dart';
import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/utils/feature_info_resolver.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';
import '../../parcours/presentation/providers/parcours_providers.dart';
import '../../parcours/presentation/parcours_screen.dart';
import '../../tp/presentation/tp_hub_screen.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../podcasts/data/podcast_model.dart';
import '../../podcasts/data/podcast_player_service.dart';
import '../../solo/presentation/widgets/solo_quiz_card_body.dart';
import '../../solo/presentation/widgets/solo_lacunes_card_body.dart';
import '../../solo/presentation/widgets/solo_pool_card_body.dart';
import '../../solo/presentation/widgets/solo_quiz_ai_card_body.dart';
import '../../solo/presentation/widgets/solo_flashcards_card_body.dart';
import '../../lobby/presentation/widgets/lobby_active_card_body.dart';
import '../../lobby/presentation/widgets/lobby_create_card_body.dart';
import '../../lobby/presentation/widgets/lobby_create_ai_card_body.dart';
import '../../lobby/presentation/widgets/lobby_join_private_card_body.dart';
import '../../lobby/presentation/widgets/duel_quick_card_body.dart';
import '../../notebook/presentation/widgets/notebook_card_body.dart';
import '../../notebook/presentation/widgets/home_note_card.dart';
import '../../flashcards/presentation/widgets/flashcards_deck_card_body.dart';
import '../../docs/presentation/widgets/docs_search_card_body.dart';
import '../../docs/presentation/docs_screen.dart';
import '../../docs/presentation/docs_mini_course_dialog.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../classement/presentation/widgets/leaderboard_mini_card_body.dart';
import '../../labo/presentation/widgets/labo_contrib_card_body.dart';
import '../../parcours/presentation/widgets/examen_blanc_card_body.dart';
import '../../parcours/presentation/widgets/mega_lexique_card_body.dart';
import '../../parcours/presentation/widgets/mega_mediatheque_card_body.dart';
import '../../exam/presentation/widgets/exam_blanc_announcement_dialog.dart';
import 'widgets/whats_new_announcement_dialog.dart';
import 'widgets/home_news_cards_section.dart';
import 'providers/home_news_provider.dart';

const Color _surfaceBar    = EskoliaTokens.surface2;
const Color _redStreak     = EskoliaTokens.error;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final HomeRepository _repo = HomeRepository();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  final List<bool> _sectionVisible = List.filled(3, false);
  bool _isModuleListExpanded = false;

  StreamSubscription<UserModel?>? _userSub;
  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  @override
  void initState() {
    super.initState();
    _subscribeToUser();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardOnboarding());
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _dragDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _guardOnboarding() async {
    final done = await OnboardingPrefs.isCompleted();
    if (!mounted) return;
    if (!done) {
      context.go('/onboarding');
      return;
    }
    // Affichage du dialogue d'annonce de la section Examens Blancs
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        ExamBlancAnnouncementDialog.showIfFirstTime(context);
      }
    });
  }

  Future<void> _loadData() async {
    _userSub?.cancel();
    _subscribeToUser();
  }

  void _subscribeToUser() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _userSub = _repo.watchCurrentUser().listen(
      (user) async {
        if (!mounted) return;
        if (user == null) {
          setState(() => _isLoading = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/login');
          });
          return;
        }
        try {
          await AchievementTriggers(
            onUnlocked: (emoji, title) {
              if (mounted) showAchievementSnackBar(context, emoji, title);
            },
          ).syncFromUserSnapshot(user);
          
          if (!mounted) return;
          
          // Synchroniser les préférences Firebase vers les Providers locaux
          if (user.homeCardsOrder.isNotEmpty) {
            ref.read(homeCardsOrderProvider.notifier).syncFromFirestore(user.homeCardsOrder);
          }
          if (user.homePinnedCards.isNotEmpty) {
            ref.read(homePinnedCardsProvider.notifier).syncFromFirestore(user.homePinnedCards);
          }
          if (user.subscribedSources.isNotEmpty) {
            ref.read(homeSubscribedSourcesProvider.notifier).syncFromFirestore(user.subscribedSources);
          }
          if (user.cardSettings.isNotEmpty) {
            ref.read(homeCardSettingsProvider.notifier).syncFromFirestore(user.cardSettings);
          }

          setState(() {
            _user = user;
            _isLoading = false;
          });
          _triggerSectionAnimations();
          _maybeShowStreakBanner(user.streak);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) WhatsNewAnnouncementDialog.showIfFirstTime(context);
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _maybeShowStreakBanner(int streak) async {
    if (streak <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = 'streak_banner_${now.year}_${now.month}_${now.day}';
    if (prefs.getBool(key) == true) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showStreakBanner(context, streak);
    });
  }

  void _triggerSectionAnimations() {
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        setState(() => _sectionVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: true,
            showBack: false,
            child: _isLoading
                ? _buildSkeleton()
                : _errorMessage != null
                    ? _buildError(context)
                    : _user == null
                        ? const SizedBox.shrink()
                        : _buildMain(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Text(
                'Mon Accueil',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _skeletonBox(36, 36, radius: 18),
              const SizedBox(width: 8),
              _skeletonBox(36, 36, radius: 18),
            ],
          ),
          const SizedBox(height: 20),
          _skeletonBox(100, double.infinity, radius: 14),
          const SizedBox(height: 12),
          _skeletonBox(100, double.infinity, radius: 14),
        ],
      ),
    );
  }

  Widget _skeletonBox(double height, double width, {double radius = 8}) {
    return Container(
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: _surfaceBar,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _redStreak, size: 48),
          Text(_errorMessage ?? 'Erreur'),
          EskoliaButton(label: 'Reessayer', onPressed: _loadData),
        ],
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> list) {
    if (list.isEmpty) return [];
    final res = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      res.add(list[i]);
      if (i < list.length - 1) {
        res.add(const SizedBox(height: 16));
      }
    }
    return res;
  }

  Widget _buildCardByKey(String key, UserModel user) {
    if (key.startsWith('note:')) {
      return HomeNoteCard(key: ValueKey(key), noteId: key.substring(5));
    }
    if (key.startsWith('merge:')) {
      return HomeMergedCard(
        mergeKey: key,
        username: user.username,
        streak: user.streak,
      );
    }
    if (key.startsWith('source:')) {
      final sourceName = key.substring(7);
      String displayTitle = 'Veille $sourceName';
      String subtitle = 'Flux RSS dédié aux publications de $sourceName';
      if (sourceName.startsWith('custom:')) {
        try {
          final map = jsonDecode(sourceName.substring(7)) as Map<String, dynamic>;
          displayTitle = 'Veille ${map['label'] ?? 'perso'}';
          subtitle = 'Flux RSS personnalisé';
        } catch (_) {}
      }
      return TechNewsSection(
        category: 'all',
        title: displayTitle,
        subtitle: subtitle,
        emoji: '📡',
        sourceFilter: sourceName,
      );
    }
    if (key.startsWith('feature:')) {
      return _buildFeatureCard(key, user);
    }
    switch (key) {
      case 'it_pro':
        return const TechNewsSection(
          category: 'all',
          title: 'Veille Générale',
          subtitle: 'Actualités IT, infra, cloud, et développement — flux RSS externes',
          emoji: '🖥️',
        );
      case 'it':
        return const TechNewsSection(
          category: 'it',
          title: 'Veille IT',
          subtitle: 'Flux RSS dédié aux thèmes IT et Infrastructure',
          emoji: '💻',
        );
      case 'security':
        return const TechNewsSection(
          category: 'security',
          title: 'Sécurité & Menaces',
          subtitle: 'Cybersécurité, vulnérabilités, alertes… — flux RSS externes',
          emoji: '🛡️',
        );
      case 'hardware':
        return const TechNewsSection(
          category: 'hardware',
          title: 'Veille Hardware',
          subtitle: 'Actualités matériel, composants et nouveautés hardware',
          emoji: '🔌',
        );
      case 'software':
        return const TechNewsSection(
          category: 'software',
          title: 'Veille Software',
          subtitle: 'Actualités systèmes, logiciels et dev — flux RSS externes',
          emoji: '💿',
        );
      case 'favoris':
        return const HomeFavorisCard();
      case 'messages':
        return HomeMessagesCard(username: user.username, streak: user.streak);
      case 'astuces':
        return const HomeAstucesCard();
      default:
        return const SizedBox.shrink();
    }
  }

  String _getSectionName(String key) {
    if (key == 'messages') return 'ACCUEIL';
    if (key == 'astuces' ||
        key == 'favoris' ||
        key == 'it_pro' ||
        key == 'it' ||
        key == 'security' ||
        key == 'hardware' ||
        key == 'software' ||
        key.startsWith('source:') ||
        key.startsWith('merge:')) {
      return 'VEILLE';
    }
    if (key.startsWith('feature:')) {
      final feat = key.substring(8);
      if (feat == 'solo' ||
          feat == 'solo_quiz' ||
          feat == 'solo_quiz_ai' ||
          feat == 'solo_lacunes' ||
          feat == 'solo_pool' ||
          feat == 'flashcards' ||
          feat == 'notebook' ||
          feat == 'flashcards_deck') {
        return 'SOLO';
      }
      if (feat == 'tp' ||
          feat == 'tp_reseau' ||
          feat == 'tp_ad' ||
          feat == 'tp_powershell' ||
          feat == 'tp_packet_tracer' ||
          feat == 'tp_itil' ||
          feat == 'tp_glpi') {
        return 'TP';
      }
      if (feat == 'parcours' ||
          feat == 'podcasts' ||
          feat == 'examen_blanc' ||
          feat == 'mediatheque' ||
          feat == 'lexique') {
        return 'PARCOURS';
      }
      if (feat == 'lobbys' ||
          feat == 'lobbys_active' ||
          feat == 'lobbys_create' ||
          feat == 'lobbys_create_ai' ||
          feat == 'lobbys_join_private' ||
          feat == 'duel_quick') {
        return 'LOBBY';
      }
      if (feat == 'classement' ||
          feat == 'leaderboard_mini') {
        return 'CLASSEMENT';
      }
      if (feat == 'labo' ||
          feat == 'labo_contrib') {
        return 'LABO';
      }
      if (feat == 'docs' ||
          feat == 'docs_search' ||
          feat.startsWith('docs_')) {
        return 'DOCS';
      }
    }
    return 'Eskolia';
  }

  Widget _buildFeatureCard(String key, UserModel user) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[key];
    final isCollapsed = settings?.isCollapsed ?? false;

    String title = '';
    String emoji = '';
    Color accentColor = EskoliaTokens.cyan;
    Widget cardBody = const SizedBox.shrink();

    if (key == 'feature:ai') {
      title = 'Mon Tuteur IA';
      emoji = '🧠';
      accentColor = EskoliaTokens.violet;
      cardBody = _buildAiFeatureBody();
    } else if (key == 'feature:solo') {
      title = 'Mode Solo (Quiz)';
      emoji = '🎮';
      accentColor = EskoliaTokens.cyan;
      cardBody = _buildSoloFeatureBody();
    } else if (key == 'feature:solo_quiz') {
      title = 'Générateur de Quiz';
      emoji = '🎮';
      accentColor = EskoliaTokens.cyan;
      cardBody = const SoloQuizCardBody();
    } else if (key == 'feature:solo_quiz_ai') {
      title = 'Génération avec IA';
      emoji = '🧠';
      accentColor = EskoliaTokens.violet;
      cardBody = const SoloQuizAiCardBody();
    } else if (key == 'feature:solo_lacunes') {
      title = 'Mes fautes';
      emoji = '❌';
      accentColor = EskoliaTokens.error;
      cardBody = const SoloLacunesCardBody();
    } else if (key == 'feature:solo_pool') {
      title = 'À revoir';
      emoji = '📌';
      accentColor = EskoliaTokens.success;
      cardBody = const SoloPoolCardBody();
    } else if (key == 'feature:classement') {
      title = 'Progression & Rang';
      emoji = '🏆';
      accentColor = EskoliaTokens.amber;
      cardBody = _buildClassementFeatureBody(user);
    } else if (key == 'feature:tp') {
      title = 'Travaux Pratiques';
      emoji = '🛠️';
      accentColor = EskoliaTokens.error;
      cardBody = _buildTpFeatureBody();
    } else if (key == 'feature:tp_reseau') {
      title = 'Réseau & Adressage IP';
      emoji = '🌐';
      accentColor = EskoliaTokens.cyan;
      cardBody = const TpReseauCardBody();
    } else if (key == 'feature:tp_ad') {
      title = 'Active Directory';
      emoji = '👥';
      accentColor = EskoliaTokens.info;
      cardBody = const TpActiveDirectoryCardBody();
    } else if (key == 'feature:tp_powershell') {
      title = 'Scripting PowerShell';
      emoji = '💻';
      accentColor = EskoliaTokens.violet;
      cardBody = const TpPowerShellCardBody();
    } else if (key == 'feature:tp_packet_tracer') {
      title = 'Packet Tracer';
      emoji = '⚡';
      accentColor = EskoliaTokens.cyan;
      cardBody = const TpPacketTracerCardBody();
    } else if (key == 'feature:tp_itil') {
      title = 'Gestion de Tickets (ITIL)';
      emoji = '🎟️';
      accentColor = EskoliaTokens.violet;
      cardBody = const TpItilCardBody();
    } else if (key == 'feature:tp_glpi') {
      title = 'TP GLPI';
      emoji = '📦';
      accentColor = EskoliaTokens.textDisabled;
      cardBody = const TpGlpiCardBody();
    } else if (key == 'feature:notebook') {
      title = 'Mon Bloc-notes';
      emoji = '📝';
      accentColor = EskoliaTokens.success;
      cardBody = const NotebookCardBody();
    } else if (key == 'feature:lobbys_active') {
      title = 'Lobbys Actifs';
      emoji = '👥';
      accentColor = Colors.pinkAccent;
      cardBody = const LobbyActiveCardBody();
    } else if (key == 'feature:lobbys_create') {
      title = 'Créer Salon';
      emoji = '👥';
      accentColor = Colors.pinkAccent;
      cardBody = const LobbyCreateCardBody();
    } else if (key == 'feature:lobbys_create_ai') {
      title = 'Créer Salon IA';
      emoji = '🧠';
      accentColor = EskoliaTokens.amber;
      cardBody = const LobbyCreateAiCardBody();
    } else if (key == 'feature:lobbys_join_private') {
      title = 'Rejoindre par Code';
      emoji = '🔒';
      accentColor = EskoliaTokens.cyan;
      cardBody = const LobbyJoinPrivateCardBody();
    } else if (key == 'feature:duel_quick') {
      title = 'Défi Express';
      emoji = '⚡';
      accentColor = Colors.pinkAccent;
      cardBody = const DuelQuickCardBody();
    } else if (key == 'feature:flashcards_deck') {
      title = 'Révisions Mémoire';
      emoji = '⚡';
      accentColor = EskoliaTokens.cyan;
      cardBody = const FlashcardsDeckCardBody();
    } else if (key == 'feature:docs_search') {
      title = 'Recherche de Mémos';
      emoji = '📖';
      accentColor = Colors.orange;
      cardBody = const DocsSearchCardBody();
    } else if (key == 'feature:docs_mes_cours') {
      title = 'Mes cours sauvegardés';
      emoji = '📚';
      accentColor = EskoliaTokens.violetSoft;
      cardBody = const MesCoursCard();
    } else if (key == 'feature:docs_rgpd') {
      title = 'RGPD (UE)';
      emoji = '⚖️';
      accentColor = EskoliaVisual.neonViolet;
      cardBody = DocSectionCardBody(
        accent: EskoliaVisual.neonViolet,
        body: DocsScreen.rgpdBody,
        linkLabel: 'Fiche CNIL sur le règlement européen',
        onLink: () => openDocsUrl(context, DocsScreen.cnilRgpd),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — RGPD',
          assetPath: DocsScreen.assetMiniRgpd,
          officialUrl: DocsScreen.cnilRgpd,
          officialLinkLabel: 'Fiche CNIL sur le règlement européen',
        ),
        onQuiz: () => context.go('/quiz/quick'),
      );
    } else if (key == 'feature:docs_cnil') {
      title = 'CNIL';
      emoji = '🏢';
      accentColor = EskoliaVisual.neonCyan;
      cardBody = DocSectionCardBody(
        accent: EskoliaVisual.neonCyan,
        body: DocsScreen.cnilBody,
        linkLabel: 'Site de la CNIL',
        onLink: () => openDocsUrl(context, DocsScreen.cnilHome),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — CNIL',
          assetPath: DocsScreen.assetMiniCnil,
          officialUrl: DocsScreen.cnilHome,
          officialLinkLabel: 'Site de la CNIL',
        ),
        onQuiz: () => context.go('/quiz/quick'),
      );
    } else if (key == 'feature:docs_anssi') {
      title = 'ANSSI & bonnes pratiques';
      emoji = '🛡️';
      accentColor = EskoliaVisual.neonGreen;
      cardBody = DocSectionCardBody(
        accent: EskoliaVisual.neonGreen,
        body: DocsScreen.anssiBody,
        linkLabel: 'Site de l\'ANSSI',
        onLink: () => openDocsUrl(context, DocsScreen.anssiHome),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — ANSSI',
          assetPath: DocsScreen.assetMiniAnssi,
          officialUrl: DocsScreen.anssiHome,
          officialLinkLabel: 'Site de l\'ANSSI',
        ),
        onQuiz: () => context.go('/quiz/quick'),
      );
    } else if (key == 'feature:docs_itil') {
      title = 'ITIL 4 (Services IT)';
      emoji = '🎟️';
      accentColor = const Color(0xFF60A5FA);
      cardBody = DocSectionCardBody(
        accent: const Color(0xFF60A5FA),
        body: DocsScreen.itilBody,
        linkLabel: 'Site officiel ITIL (Axelos)',
        onLink: () => openDocsUrl(context, DocsScreen.itilHome),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — ITIL 4',
          assetPath: DocsScreen.assetMiniItil,
          officialUrl: DocsScreen.itilHome,
          officialLinkLabel: 'Site officiel ITIL',
        ),
        onQuiz: () => context.go('/quiz/quick'),
      );
    } else if (key == 'feature:docs_osi') {
      title = 'Modèle OSI & réseaux';
      emoji = '🌐';
      accentColor = const Color(0xFF34D399);
      cardBody = DocSectionCardBody(
        accent: const Color(0xFF34D399),
        body: DocsScreen.osiBody,
        linkLabel: null,
        onLink: null,
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — Modèle OSI',
          assetPath: DocsScreen.assetMiniOsi,
          officialUrl: null,
          officialLinkLabel: null,
        ),
        onQuiz: () => context.go('/quiz/quick'),
      );
    } else if (key == 'feature:docs_technician') {
      title = 'Technicien - Bonnes pratiques';
      emoji = '💡';
      accentColor = const Color(0xFFFFB74D);
      cardBody = DocSectionCardBody(
        accent: const Color(0xFFFFB74D),
        body: DocsScreen.technicianBody,
        linkLabel: null,
        onLink: null,
      );
    } else if (key == 'feature:leaderboard_mini') {
      title = 'Classement Hebdomadaire';
      emoji = '🏆';
      accentColor = EskoliaTokens.amber;
      cardBody = const LeaderboardMiniCardBody();
    } else if (key == 'feature:labo_contrib') {
      title = 'Mes Contributions';
      emoji = '🧪';
      accentColor = Colors.tealAccent;
      cardBody = const LaboContribCardBody();
    } else if (key == 'feature:flashcards') {
      title = 'Révisions Flashcards';
      emoji = '⚡';
      accentColor = EskoliaTokens.cyan;
      cardBody = const SoloFlashcardsCardBody();
    } else if (key == 'feature:docs') {
      title = 'Documentation IT';
      emoji = '📖';
      accentColor = Colors.orange;
      cardBody = _buildDocsFeatureBody();
    } else if (key == 'feature:labo') {
      title = 'Le Labo';
      emoji = '🧪';
      accentColor = Colors.tealAccent;
      cardBody = _buildLaboFeatureBody();
    } else if (key == 'feature:lobbys') {
      title = 'Lobbys Multijoueur';
      emoji = '👥';
      accentColor = Colors.pinkAccent;
      cardBody = _buildLobbysFeatureBody();
    } else if (key == 'feature:parcours') {
      title = 'Cours formation TIP';
      emoji = '🎓';
      accentColor = EskoliaTokens.cyan;
      cardBody = _buildParcoursFeatureBody();
    } else if (key == 'feature:podcasts') {
      title = 'Podcast TIP';
      emoji = '🎙️';
      accentColor = EskoliaTokens.violet;
      cardBody = _buildPodcastsFeatureBody();
    } else if (key == 'feature:examen_blanc') {
      title = 'Validation TIP';
      emoji = '🏆';
      accentColor = EskoliaTokens.amber;
      cardBody = _buildExamenBlancFeatureBody();
    } else if (key == 'feature:lexique') {
      title = 'Lexique TIP';
      emoji = '📖';
      accentColor = EskoliaTokens.orange;
      cardBody = const SizedBox.shrink();
    } else if (key == 'feature:mediatheque') {
      title = 'Média TIP';
      emoji = '📁';
      accentColor = EskoliaTokens.violetSoft;
      cardBody = const SizedBox.shrink();
    }

    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final displayColor = settings != null ? Color(settings.colorHex) : accentColor;

    if (key == 'feature:lexique') {
      cardBody = MegaLexiqueCardBody(accentColor: displayColor);
    } else if (key == 'feature:mediatheque') {
      cardBody = MegaMediathequeCardBody(accentColor: displayColor);
    }

    if (kDebugMode) {
      print('EskoliaDebugCard: key=$key, isCollapsed=$isCollapsed, cond=${!isCollapsed || key == 'feature:parcours' || key == 'feature:podcasts'}');
    }

    const Color slate = EskoliaTokens.textSecondary;

    return EskoliaCardContent(
      accentBorderColor: displayColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(key),
            child: Row(
              children: [
                EskoliaCardSectionBadge(
                  sectionName: _getSectionName(key),
                  color: displayColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
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
                      if (FeatureInfoResolver.getInfo(key) != null) ...[
                        const SizedBox(width: 2),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                          tooltip: 'Comment ça marche ?',
                          onPressed: () => _showInfoDialog(context, key),
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white60,
                            size: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                  onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(key),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: slate.withValues(alpha: 0.85),
                    size: 19,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
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
                      showHomeCardSettingsDialog(context, ref, key);
                    } else if (action == 'merge') {
                      showMergeCardDialog(context, ref, key);
                    } else if (action == 'pin') {
                      ref.read(homePinnedCardsProvider.notifier).togglePin(key);
                    } else if (action == 'remove') {
                      ref.read(homeCardsOrderProvider.notifier).removeCard(key);
                    }
                  },
                  itemBuilder: (ctx) {
                    final isPinned = ref.watch(homePinnedCardsProvider).contains(key);
                    final canMerge = key == 'it_pro' ||
                        key == 'security' ||
                        key == 'it' ||
                        key == 'hardware' ||
                        key == 'software' ||
                        key.startsWith('source:') ||
                        key.startsWith('merge:');
                    return [
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
                      if (canMerge)
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
                            Icon(isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, color: isPinned ? displayColor : Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            Text(isPinned ? 'Désépingler' : 'Épingler', style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline_rounded, color: EskoliaTokens.error, size: 18),
                            SizedBox(width: 10),
                            Text('Retirer de l\'accueil', style: TextStyle(color: EskoliaTokens.error, fontSize: 13)),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          if (!isCollapsed || key == 'feature:parcours' || key == 'feature:podcasts') ...[
            const SizedBox(height: 12),
            cardBody,
          ],
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String key) {
    final info = FeatureInfoResolver.getInfo(key);
    if (info == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isErrorAccent = key == 'feature:solo_lacunes' || key == 'feature:tp';
        return AlertDialog(
          backgroundColor: EskoliaTokens.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              if (info.emoji.isNotEmpty) ...[
                Text(info.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  info.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: FeatureInfoResolver.buildRichDescription(
            info.description,
            const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Compris',
                style: TextStyle(
                  color: isErrorAccent ? EskoliaTokens.error : EskoliaTokens.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAiFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tuteur virtuel disponible pour vous aider à réviser ou comprendre un concept IT.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/ai/setup'),
          icon: const Icon(Icons.forum_rounded, size: 16),
          label: const Text('Discuter avec Optimus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.violet,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSoloFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Entraînez-vous à votre rythme sur les thèmes de votre choix.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/true-false'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Vrai/Faux', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.go('/solo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Lancer Quiz', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassementFeatureBody(UserModel user) {
    final xp = user.xp;
    final lvl = (xp ~/ 1000) + 1;
    final lvlXp = xp % 1000;
    final pct = lvlXp / 1000.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Niveau $lvl', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text('$lvlXp / 1000 XP', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(EskoliaTokens.amber),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/leaderboard'),
          icon: const Icon(Icons.emoji_events_rounded, size: 16),
          label: const Text('Voir le classement', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTpFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Simulateur de pannes réseaux et entraînements PowerShell / Active Directory.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/tp'),
          icon: const Icon(Icons.construction_rounded, size: 16),
          label: const Text('Entrer dans le TP Hub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.error,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildNotebookFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Rédigez vos notes en Markdown et générez des QCM personnalisés automatiquement.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/notebook'),
          icon: const Icon(Icons.note_alt_rounded, size: 16),
          label: const Text('Ouvrir mes notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.success,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcardsFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Révisez efficacement en utilisant des cartes mémoire de questions/réponses.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/flashcards'),
          icon: const Icon(Icons.bolt_rounded, size: 16),
          label: const Text('Réviser les Flashcards', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.cyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDocsFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Accédez à des fiches de synthèse sur le modèle OSI, ITIL, l\'ANSSI, le RGPD et plus.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/docs'),
          icon: const Icon(Icons.menu_book_rounded, size: 16),
          label: const Text('Consulter les mémos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildLaboFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Soumettez vos propres questions au professeur et collaborez au contenu d\'Eskolia.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/labo'),
          icon: const Icon(Icons.science_rounded, size: 16),
          label: const Text('Accéder au Labo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildLobbysFeatureBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Affrontez vos camarades en direct ou rejoignez un salon de révision multijoueur.',
          style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.3),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/lobbys'),
          icon: const Icon(Icons.groups_rounded, size: 16),
          label: const Text('Rejoindre un lobby', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildExamenBlancFeatureBody() {
    final snap = ref.watch(parcoursFormationsProvider);
    return snap.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text(
              'Aucun parcours disponible',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          );
        }
        final formation = list.first; // Formation TIP
        return ExamenBlancCardBody(formation: formation);
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur: $e',
          style: const TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildParcoursFeatureBody() {
    final snap = ref.watch(parcoursFormationsProvider);
    return snap.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text(
              'Aucun parcours disponible',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          );
        }
        final formation = list.first; // Formation TIP
        final selectedIdx = ref.watch(homeSelectedModuleIndexProvider);
        
        // Ensure index is valid
        final safeIdx = selectedIdx.clamp(0, formation.sections.isEmpty ? 0 : formation.sections.length - 1);
        if (formation.sections.isEmpty) {
          return const Center(
            child: Text(
              'Aucun module disponible',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          );
        }

        final section = formation.sections[safeIdx];
        final lastClickedChapterId = ref.watch(homeLastClickedChapterProvider);
        final settingsMap = ref.watch(homeCardSettingsProvider);
        final isCollapsed = settingsMap['feature:parcours']?.isCollapsed ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row for Selecting Module & Navigation Arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left chevron
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: EskoliaTokens.cyan),
                  onPressed: safeIdx > 0
                      ? () => ref.read(homeSelectedModuleIndexProvider.notifier).setIndex(safeIdx - 1)
                      : null,
                ),
                // Module Title / Selector
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title Text (toggles collapse/expand or module list)
                      InkWell(
                        onTap: () {
                          if (isCollapsed) {
                            ref.read(homeCardSettingsProvider.notifier).toggleCollapse('feature:parcours');
                            setState(() {
                              _isModuleListExpanded = true;
                            });
                          } else {
                            setState(() {
                              _isModuleListExpanded = !_isModuleListExpanded;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(
                            section.id.startsWith('M') && section.id.length > 1
                                ? 'Module ${section.id.substring(1)} : ${section.title}'
                                : section.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Sub-text button
                      InkWell(
                        onTap: () {
                          if (isCollapsed) {
                            ref.read(homeCardSettingsProvider.notifier).toggleCollapse('feature:parcours');
                            setState(() {
                              _isModuleListExpanded = true;
                            });
                          } else {
                            setState(() {
                              _isModuleListExpanded = !_isModuleListExpanded;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                          child: Text(
                            isCollapsed
                                ? 'Déplier le module ▾'
                                : (_isModuleListExpanded ? 'Fermer la liste ▴' : 'Changer de module ▾'),
                            style: const TextStyle(
                              color: EskoliaTokens.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right chevron
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: EskoliaTokens.cyan),
                  onPressed: safeIdx < formation.sections.length - 1
                      ? () => ref.read(homeSelectedModuleIndexProvider.notifier).setIndex(safeIdx + 1)
                      : null,
                ),
              ],
            ),
            if (!isCollapsed) ...[
              const SizedBox(height: 12),
              if (_isModuleListExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Sélectionner un module :',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...formation.sections.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final sec = entry.value;
                      final isCurrent = idx == safeIdx;
                      final moduleTitle = sec.id.startsWith('M') && sec.id.length > 1
                          ? 'Module ${sec.id.substring(1)} : ${sec.title}'
                          : sec.title;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref.read(homeSelectedModuleIndexProvider.notifier).setIndex(idx);
                              setState(() {
                                _isModuleListExpanded = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? EskoliaTokens.cyan.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCurrent
                                      ? EskoliaTokens.cyan.withValues(alpha: 0.35)
                                      : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      moduleTitle,
                                      style: TextStyle(
                                        color: isCurrent ? Colors.white : Colors.white70,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: EskoliaTokens.cyan,
                                      size: 15,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                )
              else ...[
                // Chapters list inside the module
                if (section.modules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Aucun chapitre dans ce module',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  )
                else
                  Column(
                    children: section.modules.map((chapter) {
                      final isLastClicked = chapter.id == lastClickedChapterId;
                      
                      final bool shouldHighlight;
                      if (lastClickedChapterId != null) {
                        shouldHighlight = isLastClicked;
                      } else {
                        final firstUncompleted = section.modules.firstWhere(
                          (m) => !m.isCompleted,
                          orElse: () => section.modules.last,
                        );
                        shouldHighlight = chapter.id == firstUncompleted.id;
                      }

                      final Color textColor = shouldHighlight
                          ? EskoliaTokens.cyan
                          : chapter.isCompleted
                              ? Colors.white70
                              : Colors.white38;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: () {
                            ref.read(homeLastClickedChapterProvider.notifier).setChapterId(chapter.id);
                            _launchChapter(context, chapter);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: shouldHighlight
                                  ? EskoliaTokens.cyan.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: shouldHighlight
                                    ? EskoliaTokens.cyan.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  chapter.isCompleted
                                      ? Icons.check_circle_rounded
                                      : shouldHighlight
                                          ? Icons.play_circle_filled_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                  size: 16,
                                  color: textColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    chapter.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: shouldHighlight ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ],
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur: $e',
          style: const TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    );
  }

  void _showModuleSelector(BuildContext context, FormationModel formation, int currentIdx) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: EskoliaTokens.bgBase,
          title: const Text(
            'Sélectionner un module',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: formation.sections.length,
              itemBuilder: (context, idx) {
                final sec = formation.sections[idx];
                final isCurrent = idx == currentIdx;
                final moduleTitle = sec.id.startsWith('M') && sec.id.length > 1
                    ? 'Module ${sec.id.substring(1)} : ${sec.title}'
                    : sec.title;
                return ListTile(
                  dense: true,
                  title: Text(
                    moduleTitle,
                    style: TextStyle(
                      color: isCurrent ? EskoliaTokens.cyan : Colors.white70,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isCurrent ? const Icon(Icons.check, color: EskoliaTokens.cyan, size: 16) : null,
                  onTap: () {
                    ref.read(homeSelectedModuleIndexProvider.notifier).setIndex(idx);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _launchChapter(BuildContext context, ModuleModel module) {
    if (module.isLocked) return;
    switch (module.type) {
      case 'exam':
        if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'chapitre':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'quiz':
        context.push('/quiz/${module.id}');
        break;
      case 'cours':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'flashcard':
        context.push('/flashcards');
        break;
      default:
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
    }
  }

  Widget _buildHomePodcastItem(Podcast p, bool isCurrent, bool isPlaying, bool isLoading) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(podcastPlayerProvider.notifier).play(p);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                  border: Border.all(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.40),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: EskoliaTokens.cyan,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.subtitle ?? 'Analyse approfondie',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EskoliaTokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: EskoliaTokens.cyan,
                  ),
                )
              else if (isPlaying)
                const Icon(
                  Icons.volume_up_rounded,
                  color: EskoliaTokens.cyan,
                  size: 18,
                )
              else
                const Icon(
                  Icons.play_arrow_rounded,
                  color: EskoliaTokens.cyan,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastsFeatureBody() {
    final playerState = ref.watch(podcastPlayerProvider);
    final podcastsSnap = ref.watch(allPodcastsProvider);
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = settingsMap['feature:podcasts']?.isCollapsed ?? false;

    return podcastsSnap.when(
      data: (podcasts) {
        if (podcasts.isEmpty) {
          return const Center(
            child: Text(
              'Aucun podcast disponible',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          );
        }

        final activePodcast = playerState.podcast ?? podcasts.first;
        final isPlaying = playerState.podcast?.url == activePodcast.url && playerState.isPlaying;
        final isLoading = playerState.podcast?.url == activePodcast.url && playerState.loading;

        final total = playerState.podcast?.url == activePodcast.url ? (playerState.duration ?? Duration.zero) : Duration.zero;
        final hasDuration = total.inMilliseconds > 0;
        final pos = playerState.podcast?.url == activePodcast.url
            ? playerState.position.inMilliseconds.clamp(0, hasDuration ? total.inMilliseconds : 0).toDouble()
            : 0.0;

        String _fmt(Duration d) {
          final m = d.inMinutes;
          final s = d.inSeconds % 60;
          return '$m:${s < 10 ? '0$s' : '$s'}';
        }

        void _playNextPrev(bool next) {
          final current = playerState.podcast ?? podcasts.first;
          int idx = podcasts.indexWhere((p) => p.url == current.url);
          if (idx == -1) idx = 0;
          if (next) {
            idx = (idx + 1) % podcasts.length;
          } else {
            idx = (idx - 1 + podcasts.length) % podcasts.length;
          }
          ref.read(podcastPlayerProvider.notifier).play(podcasts[idx]);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active podcast info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  // Play/Pause Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading
                          ? null
                          : () => ref.read(podcastPlayerProvider.notifier).play(activePodcast),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [EskoliaTokens.cyan, EskoliaTokens.violet],
                          ),
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activePodcast.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (activePodcast.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            activePodcast.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: EskoliaTokens.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Next/Prev Buttons
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 20),
                    onPressed: () => _playNextPrev(false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 20),
                    onPressed: () => _playNextPrev(true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Progress Bar / Interactive Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: EskoliaTokens.cyan,
                inactiveTrackColor: Colors.white12,
                thumbColor: EskoliaTokens.cyan,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: pos,
                max: hasDuration ? total.inMilliseconds.toDouble() : 1.0,
                onChanged: hasDuration ? (v) {} : null,
                onChangeEnd: hasDuration
                    ? (v) => ref.read(podcastPlayerProvider.notifier).seek(Duration(milliseconds: v.round()))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    playerState.podcast?.url == activePodcast.url ? _fmt(playerState.position) : '0:00',
                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                  ),
                  Text(
                    hasDuration ? _fmt(total) : '--:--',
                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
            // If card is expanded (not collapsed), list all podcasts by section
            if (!isCollapsed) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              const Text(
                'Tous les podcasts',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < podcasts.length; i++) ...[
                if (i > 0) const Divider(color: Colors.white10, height: 1, thickness: 1),
                _buildHomePodcastItem(
                  podcasts[i],
                  activePodcast.url == podcasts[i].url,
                  activePodcast.url == podcasts[i].url && playerState.isPlaying,
                  activePodcast.url == podcasts[i].url && playerState.loading,
                ),
              ],
            ],
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur: $e',
          style: const TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: Colors.white12,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(String key, Widget child, double width) {
    final isWebOrDesktop = kIsWeb || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux;

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.035, // ~2 degrés d'inclinaison
        child: Transform.scale(
          scale: 1.04, // léger zoom
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    return DragTarget<String>(
      key: ValueKey(key),
      onWillAcceptWithDetails: (details) {
        final dragKey = details.data;
        if (dragKey != key) {
          if (_hoveredDragKey != key) {
            _hoveredDragKey = key;
            _dragDebounceTimer?.cancel();
            _dragDebounceTimer = Timer(const Duration(milliseconds: 150), () {
              if (mounted && _hoveredDragKey == key) {
                final pinned = ref.read(homePinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                // Si déplacement vers une section différente, on bascule l'épinglage
                if (isDragPinned != isTargetPinned) {
                  ref.read(homePinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(homeCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(homeCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
                }
              }
            });
          }
        }
        return true;
      },
      onLeave: (data) {
        if (_hoveredDragKey == key) {
          _dragDebounceTimer?.cancel();
          _hoveredDragKey = null;
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        final cardWidget = SizedBox(
          width: width,
          child: child,
        );

        Widget mainChild;
        if (isWebOrDesktop) {
          mainChild = Draggable<String>(
            key: ValueKey(key),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.2,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        } else {
          mainChild = LongPressDraggable<String>(
            key: ValueKey(key),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.2,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
                      color: EskoliaTokens.cyan.withValues(alpha: 0.15),
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

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EskoliaTokens.cyan.withValues(alpha: 0.1),
                border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🚀',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ton Accueil Personnalisé',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cet espace est vide pour l\'instant.\nParcours les différentes rubriques de l\'application et clique sur l\'icône d\'épingle 📌 pour y ajouter tes outils favoris !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    final user = _user!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = width >= 700;
    final sidebarWidth = isDesktopOrTablet ? (ref.watch(sidebarCollapsedProvider) ? 72 : 250) : 0;
    final availableWidth = (width - sidebarWidth - 40).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('home'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final order = ref.watch(homeCardsOrderProvider);
    final pinned = ref.watch(homePinnedCardsProvider);
    final settingsMap = ref.watch(homeCardSettingsProvider);

    final displayKeys = order;

    const availableHomeCards = [
      EskoliaCardOption(key: 'messages', title: 'Messages d\'accueil', emoji: '👋'),
      EskoliaCardOption(key: 'astuces', title: 'Astuces Pro', emoji: '💡'),
      EskoliaCardOption(key: 'it_pro', title: 'Veille Générale', emoji: '🖥️'),
      EskoliaCardOption(key: 'security', title: 'Sécurité & Menaces', emoji: '🛡️'),
      EskoliaCardOption(key: 'hardware', title: 'Veille Hardware', emoji: '🔌'),
      EskoliaCardOption(key: 'software', title: 'Veille Software', emoji: '💿'),
      EskoliaCardOption(key: 'favoris', title: 'Articles Favoris', emoji: '❤️'),
      EskoliaCardOption(key: 'feature:parcours', title: 'Formation TIP', emoji: '🎓'),
      EskoliaCardOption(key: 'feature:examen_blanc', title: 'Examens Blancs TIP', emoji: '🏆'),
      EskoliaCardOption(key: 'feature:podcasts', title: 'Podcasts de cours', emoji: '🎧'),
      EskoliaCardOption(key: 'feature:solo_quiz', title: 'Générateur de Quiz', emoji: '🎮'),
      EskoliaCardOption(key: 'feature:solo_quiz_ai', title: 'Génération IA', emoji: '🧠'),
      EskoliaCardOption(key: 'feature:solo_lacunes', title: 'Mes fautes', emoji: '❌'),
      EskoliaCardOption(key: 'feature:solo_pool', title: 'À revoir', emoji: '📌'),
      EskoliaCardOption(key: 'feature:lobbys_active', title: 'Salons Actifs', emoji: '👥'),
      EskoliaCardOption(key: 'feature:lobbys_create', title: 'Créer un Salon', emoji: '➕'),
      EskoliaCardOption(key: 'feature:duel_quick', title: 'Défi Express', emoji: '⚡'),
      EskoliaCardOption(key: 'feature:notebook', title: 'Mon Bloc-notes', emoji: '📝'),
      EskoliaCardOption(key: 'feature:docs_search', title: 'Recherche de Mémos', emoji: '📖'),
      EskoliaCardOption(key: 'feature:leaderboard_mini', title: 'Classement', emoji: '🏆'),
    ];

    Widget buildGrid(List<String> keys) {
      final cards = keys.map((key) {
        return _buildDraggableCard(key, _buildCardByKey(key, user), cardWidth);
      }).toList();

      double estimateCardHeight(String key) {
        final settings = settingsMap[key];
        final isCollapsed = settings?.isCollapsed ?? false;
        if (isCollapsed) return 85.0;

        if (key == 'feature:parcours') return 250.0;
        if (key == 'feature:podcasts') return 160.0;
        if (key == 'feature:examen_blanc') return 180.0;
        if (key == 'feature:lexique') return 300.0;
        if (key == 'feature:mediatheque') return 300.0;
        if (key == 'feature:lobbys_active') return 260.0;
        if (key == 'feature:lobbys_create') return 340.0;
        if (key == 'feature:lobbys_create_ai') return 340.0;
        if (key == 'feature:lobbys_join_private') return 160.0;
        if (key == 'feature:labo_contrib') return 300.0;
        if (key == 'feature:duel_quick') return 200.0;
        if (key == 'feature:docs_search') return 220.0;
        if (key == 'feature:leaderboard_mini') return 220.0;
        if (key == 'feature:flashcards_deck') return 200.0;
        if (key == 'feature:notebook') return 240.0;
        if (key == 'messages' || key == 'astuces') {
          final limit = settings?.limit ?? 5;
          return 80.0 + (limit * 56.0); // 56px par ligne
        }
        if (key == 'it_pro' ||
            key == 'it' ||
            key == 'security' ||
            key == 'hardware' ||
            key == 'software' ||
            key == 'favoris' ||
            key.startsWith('source:')) {
          final limit = settings?.limit ?? 5;
          return 140.0 + (limit * 52.0);
        }
        if (key.startsWith('note:')) return 160.0;
        return 180.0;
      }

      if (numColumns >= 4) {
        final cols = List.generate(4, (_) => <Widget>[]);
        final heights = List.filled(4, 0.0);
        for (var i = 0; i < keys.length; i++) {
          final key = keys[i];
          final card = cards[i];
          final h = estimateCardHeight(key);
          int shortest = 0;
          for (int c = 1; c < 4; c++) {
            if (heights[c] < heights[shortest]) shortest = c;
          }
          cols[shortest].add(card);
          heights[shortest] += h + 16.0;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(cols[0]))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(cols[1]))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(cols[2]))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(cols[3]))),
          ],
        );
      } else if (numColumns == 3) {
        final col1 = <Widget>[];
        final col2 = <Widget>[];
        final col3 = <Widget>[];
        double h1 = 0.0;
        double h2 = 0.0;
        double h3 = 0.0;

        for (var i = 0; i < keys.length; i++) {
          final key = keys[i];
          final card = cards[i];
          final h = estimateCardHeight(key);

          if (h1 <= h2 && h1 <= h3) {
            col1.add(card);
            h1 += h + 16.0;
          } else if (h2 <= h1 && h2 <= h3) {
            col2.add(card);
            h2 += h + 16.0;
          } else {
            col3.add(card);
            h3 += h + 16.0;
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(col2))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(col3))),
          ],
        );
      } else if (numColumns == 2) {
        final col1 = <Widget>[];
        final col2 = <Widget>[];
        double h1 = 0.0;
        double h2 = 0.0;

        for (var i = 0; i < keys.length; i++) {
          final key = keys[i];
          final card = cards[i];
          final h = estimateCardHeight(key);

          if (h1 <= h2) {
            col1.add(card);
            h1 += h + 16.0;
          } else {
            col2.add(card);
            h2 += h + 16.0;
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _addSpacing(col2))),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _addSpacing(cards),
        );
      }
    }

    Widget content;
    if (displayKeys.isEmpty) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmptyPlaceholder(context),
        ],
      );
    } else {
      final pinnedKeys = displayKeys.where((k) => pinned.contains(k)).toList();
      final otherKeys = displayKeys.where((k) => !pinned.contains(k)).toList();

      if (pinned.isEmpty) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildGrid(displayKeys),
          ],
        );
      } else {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Épinglées'),
            buildGrid(pinnedKeys),
            const SizedBox(height: 24),
            _buildSectionHeader('Autres'),
            buildGrid(otherKeys),
          ],
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EskoliaPageHeaderToolbar(
            title: 'Mon Accueil',
            screenKey: 'home',
            onInfoTap: () => _showCardsInfoDialog(context),
            onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(displayKeys),
            onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(displayKeys),
            availableCards: availableHomeCards,
            maxColumns: 4,
          ),
          // Nouveautés & Flash Info (Cartes dismissibles)
          HomeNewsCardsSection(numColumns: numColumns),
          _animatedSection(0, content),
        ],
      ),
    );
  }

  Widget _animatedSection(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  void _showCardsInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: EskoliaTokens.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: EskoliaTokens.cyan, size: 24),
              const SizedBox(width: 12),
              Text(
                'Fonctionnement des Cartes',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoStep(
                  icon: Icons.drag_indicator_rounded,
                  color: EskoliaTokens.cyan,
                  title: 'Réorganisation par Glisser-Déposer',
                  description: 'Maintenez une carte enfoncée pour la faire glisser et réorganiser l\'ordre de votre accueil selon vos préférences.',
                ),
                const SizedBox(height: 16),
                _buildInfoStep(
                  icon: Icons.push_pin_rounded,
                  color: EskoliaTokens.amber,
                  title: 'Épingler vos cartes favorites',
                  description: 'Cliquez sur l\'icône 📌 en haut d\'une carte pour la placer dans la section "Épinglées" tout en haut de votre accueil.',
                ),
                const SizedBox(height: 16),
                _buildInfoStep(
                  icon: Icons.unfold_less_rounded,
                  color: EskoliaTokens.violet,
                  title: 'Plier / Déplier pour gagner de la place',
                  description: 'Utilisez les boutons "Tout masquer" / "Tout afficher" ou le bouton de réduction sur chaque carte pour adapter la taille de votre tableau de bord.',
                ),
                const SizedBox(height: 16),
                _buildInfoStep(
                  icon: Icons.add_circle_outline_rounded,
                  color: EskoliaTokens.success,
                  title: 'Ajout de nouvelles cartes',
                  description: 'Faites défiler vers le bas et cliquez sur "Créer ou ajouter une carte" pour intégrer des flux de veille RSS personnalisés ou d\'autres modules.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                ref.read(dismissedNewsProvider.notifier).restoreAllNews();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les cartes de nouveautés ont été réaffichées.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réafficher les nouveautés masquées'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white60,
                textStyle: const TextStyle(fontSize: 11.5),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: EskoliaTokens.cyan,
              ),
              child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoStep({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: EskoliaTokens.textSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddCardPlaceholder extends StatefulWidget {
  const AddCardPlaceholder({super.key, required this.width, required this.onTap});
  final double width;
  final VoidCallback onTap;

  @override
  State<AddCardPlaceholder> createState() => _AddCardPlaceholderState();
}

class _AddCardPlaceholderState extends State<AddCardPlaceholder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: 160.0,
        decoration: BoxDecoration(
          color: _isHovered 
              ? EskoliaTokens.cyan.withValues(alpha: 0.04) 
              : Colors.white.withValues(alpha: 0.015),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered 
                ? EskoliaTokens.cyan.withValues(alpha: 0.45) 
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? EskoliaTokens.cyan.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.03),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isHovered
                          ? EskoliaTokens.cyan
                          : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: _isHovered ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.add_rounded,
                      color: _isHovered ? EskoliaTokens.cyan : Colors.white60,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Créer ou ajouter une carte',
                  style: GoogleFonts.outfit(
                    color: _isHovered ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thèmes conseillés ou flux RSS de votre choix',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isHovered ? Colors.white54 : Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
