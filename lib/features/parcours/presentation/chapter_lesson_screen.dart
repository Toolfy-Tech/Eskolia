import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/asset_cache_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_lesson_markdown.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../podcasts/data/podcast_model.dart';
import '../../podcasts/presentation/podcast_player_card.dart';
import '../data/optimus_content_models.dart';
import '../data/parcours_repository.dart';
import '../data/tip_catalog_loader.dart';
import '../data/tip_progress_repository.dart';
import 'widgets/lexique_section.dart';
import 'widgets/mediatheque_section.dart';
import 'widgets/support_section.dart';
import '../../../core/constants/eskolia_tokens.dart';

const Color _cyan = EskoliaTokens.cyan;
const Color _violet = EskoliaTokens.violetSoft;
const Color _slate = EskoliaTokens.textSecondary;

/// Affiche le cours depuis [ModuleModel.lessonAssetPath] (fichier .md rendu en texte riche).
class ChapterLessonScreen extends StatefulWidget {
  const ChapterLessonScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  State<ChapterLessonScreen> createState() => _ChapterLessonScreenState();
}

class _ChapterLessonScreenState extends State<ChapterLessonScreen> {
  String? _text;
  String? _lessonAssetPath;
  Object? _error;
  Podcast? _podcast;
  final ScrollController _scrollController = ScrollController();

  // Lexique / médiathèque / supports
  List<LexiqueEntry> _chapterTerms = const [];
  List<LexiqueEntry> _moduleTerms = const [];
  List<MediathequeItem> _chapterResources = const [];
  List<MediathequeItem> _moduleResources = const [];
  List<VeilleItem> _moduleVeille = const [];
  List<SupportItem> _chapterSupports = const [];
  bool _isLastChapter = false;

  /// Extrait le moduleId Optimus (ex. "M01") depuis l'id du module.
  /// Format attendu : "optimus_M01_M01-CH05-..." → parts[1] = "M01"
  static String? _sectionId(String moduleId) {
    final parts = moduleId.split('_');
    return parts.length >= 2 ? parts[1] : null;
  }

  /// Extrait le slug du chapitre depuis l'id du module.
  /// Format : "optimus_M01_M01-CH05-outils-..." → parts[2] = "M01-CH05-..."
  static String? _chapterSlug(String moduleId) {
    final parts = moduleId.split('_');
    return parts.length >= 3 ? parts[2] : null;
  }

  Future<void> _ensureCatalogLoaded() async {
    if (ParcoursRepository.moduleCatalog.isEmpty) {
      final base = await TipCatalogLoader.loadOptimusFormation();
      ParcoursRepository.registerModules(base);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadPodcast();
    _loadContent();
  }

  Future<void> _loadContent() async {
    await _ensureCatalogLoaded();
    final secId = _sectionId(widget.moduleId);
    final slug = _chapterSlug(widget.moduleId);
    if (secId == null || slug == null) return;

    // Vérifie si c'est le dernier chapitre de la section
    final loc = ParcoursRepository.moduleLocation[widget.moduleId];
    if (loc != null) {
      final section = ParcoursRepository
          .sectionByCompoundKey['${loc.formationId}::${loc.sectionId}'];
      if (section != null && section.modules.isNotEmpty) {
        _isLastChapter = section.modules.last.id == widget.moduleId;
      }
    }

    final chTerms = await OptimusLexiqueRepository.forChapter(secId, slug);
    final chItems =
        await OptimusMediathequeRepository.specificForChapter(secId, slug);
    final chSupports = await OptimusSupportsRepository.forChapter(secId, slug);

    List<LexiqueEntry> modTerms = const [];
    List<MediathequeItem> modItems = const [];
    List<VeilleItem> modVeille = const [];
    if (_isLastChapter) {
      final modLex = await OptimusLexiqueRepository.loadModule(secId);
      final modMed = await OptimusMediathequeRepository.loadModule(secId);
      modTerms = modLex.terms;
      modItems = modMed.specific;
      modVeille = modMed.veille;
    }

    if (!mounted) return;
    setState(() {
      _chapterTerms = chTerms;
      _chapterResources = chItems;
      _chapterSupports = chSupports;
      _moduleTerms = modTerms;
      _moduleResources = modItems;
      _moduleVeille = modVeille;
    });
  }

  Future<void> _load() async {
    await _ensureCatalogLoaded();
    final mod = ParcoursRepository.moduleById(widget.moduleId);
    final path = mod?.lessonAssetPath;
    if (path == null || path.isEmpty) {
      setState(() => _error = 'Aucun contenu cours pour ce module.');
      return;
    }
    try {
      final t = await AssetCacheService.loadString(path);
      if (!mounted) return;
      setState(() {
        _text = t;
        _lessonAssetPath = path;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  /// Charge le podcast de la section, mais seulement en tete de section
  /// (1er chapitre) pour ne pas le repeter sur chaque chapitre du module.
  Future<void> _loadPodcast() async {
    await _ensureCatalogLoaded();
    final loc = ParcoursRepository.moduleLocation[widget.moduleId];
    if (loc == null) return;
    final section = ParcoursRepository
        .sectionByCompoundKey['${loc.formationId}::${loc.sectionId}'];
    final isFirstChapter = section != null &&
        section.modules.isNotEmpty &&
        section.modules.first.id == widget.moduleId;
    if (!isFirstChapter) return;
    final p = await PodcastCatalog.forSection(loc.sectionId);
    if (!mounted) return;
    setState(() => _podcast = p);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mod = ParcoursRepository.moduleById(widget.moduleId);
    final m = mod;
    final hasQuiz = m != null &&
        m.quizAssetPath != null &&
        m.quizAssetPath!.isNotEmpty;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) return;
        final m = ParcoursRepository.moduleById(widget.moduleId);
        if (m != null &&
            (m.quizAssetPath == null || m.quizAssetPath!.isEmpty)) {
          await OptimusProgressRepository().markModulePassed(m.id);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.transparent,
        appBar: null,
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              child: _buildBody(
                hasQuiz: hasQuiz,
                quizModuleId: hasQuiz ? m.id : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({required bool hasQuiz, required String? quizModuleId}) {
    if (_error != null) {
      return Padding(
        padding: EdgeInsets.all(EskoliaLayout.lessonHorizontalPadding(context)),
        child: Center(
          child: Text(
            _error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: _slate),
          ),
        ),
      );
    }
    if (_text == null) {
      return const Center(
        child: CircularProgressIndicator(color: _cyan),
      );
    }
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          EskoliaLayout.lessonHorizontalPadding(context),
          12,
          EskoliaLayout.lessonHorizontalPadding(context),
          EskoliaLayout.screenPaddingBottom,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: EskoliaLayout.lessonContentMaxWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasQuiz && quizModuleId != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.push('/quiz/$quizModuleId'),
                          icon: const Icon(Icons.quiz_rounded, size: 18),
                          label: const Text('Lancer le Quiz de Maîtrise'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _cyan,
                            foregroundColor: EskoliaTokens.bgBase,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_podcast != null) ...[
                  _PodcastIntro(podcast: _podcast!),
                  const SizedBox(height: 22),
                ],
                EskoliaCardContent(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EskoliaLessonMarkdown(
                        data: _text!,
                        lessonAssetPath: _lessonAssetPath,
                      ),
                      if (_chapterSupports.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(
                            color: Colors.white12,
                            height: 1,
                            thickness: 1,
                          ),
                        ),
                        SupportSection(
                          items: _chapterSupports,
                          title: 'Support de cours',
                        ),
                      ],
                    ],
                  ),
                ),
                // Termes clés liés à ce chapitre spécifiquement
                if (_chapterTerms.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  LexiqueSection(
                    terms: _chapterTerms,
                    title: 'Termes clés du chapitre',
                  ),
                ],
                // Ressources liées à ce chapitre spécifiquement
                if (_chapterResources.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  MediathequeSection(
                    specific: _chapterResources,
                    title: 'Ressources du chapitre',
                  ),
                ],
                // Dernier chapitre du module → tout le lexique + médiathèque
                if (_isLastChapter && _moduleTerms.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  LexiqueSection(
                    terms: _moduleTerms,
                    title: 'Lexique complet du module',
                  ),
                ],
                if (_isLastChapter &&
                    (_moduleResources.isNotEmpty ||
                        _moduleVeille.isNotEmpty)) ...[
                  const SizedBox(height: 12),
                  MediathequeSection(
                    specific: _moduleResources,
                    veille: _moduleVeille,
                    title: 'Médiathèque du module',
                  ),
                ],
                if (hasQuiz && quizModuleId != null) ...[
                  const SizedBox(height: 22),
                  EskoliaCardContent(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              color: _cyan.withValues(alpha: 0.95),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Étape suivante',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.98),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu as fini la lecture : valide tes acquis avec le questionnaire '
                          'du module (Maîtrise).',
                          style: TextStyle(
                            color: _slate.withValues(alpha: 0.95),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        EskoliaButton(
                          label: 'Lancer la Maîtrise du module',
                          icon: Icons.play_arrow_rounded,
                          variant: EskoliaButtonVariant.primary,
                          expand: true,
                          onPressed: () =>
                              context.push('/quiz/$quizModuleId'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandeau-conseil + lecteur du podcast de la section, affiche en tete du cours.
class _PodcastIntro extends StatelessWidget {
  const _PodcastIntro({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _violet.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Text('\u{1F3A7}', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ecoute le podcast avant de lire — il vulgarise le cours en profondeur.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PodcastPlayerCard(podcast: podcast),
          ],
        ),
      ),
    );
  }
}
