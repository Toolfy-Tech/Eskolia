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
import '../../podcasts/data/podcast_model.dart';
import '../../podcasts/presentation/podcast_player_card.dart';
import '../data/parcours_repository.dart';
import '../data/tip_progress_repository.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);

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

  @override
  void initState() {
    super.initState();
    _load();
    _loadPodcast();
  }

  Future<void> _load() async {
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
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(
          context,
          title: m?.title ?? 'Cours',
          actions: [
            if (hasQuiz)
              Padding(
                padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                child: FilledButton.icon(
                  onPressed: () => context.push('/quiz/${m.id}'),
                  icon: const Icon(Icons.quiz_rounded, size: 22),
                  label: const Text('Maîtrise'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    backgroundColor: _cyan,
                    foregroundColor: const Color(0xFF0B1220),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            SafeArea(
              top: false,
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
                if (_podcast != null) ...[
                  _PodcastIntro(podcast: _podcast!),
                  const SizedBox(height: 22),
                ],
                EskoliaCardContent(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                  child: EskoliaLessonMarkdown(
                    data: _text!,
                    lessonAssetPath: _lessonAssetPath,
                  ),
                ),
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
    return Column(
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
    );
  }
}
