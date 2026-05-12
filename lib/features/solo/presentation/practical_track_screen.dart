import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../quiz/data/quiz_repository.dart';
import '../data/practical_catalog_repository.dart';
import '../data/practical_track_models.dart';
import 'practical_markdown_screen.dart';

const Color _slate = Color(0xFF94A3B8);

/// Un theme « Exercices pratiques » : tutoriels, liste de TP, QCM.
class PracticalTrackScreen extends StatefulWidget {
  const PracticalTrackScreen({super.key, required this.trackId});

  final String trackId;

  @override
  State<PracticalTrackScreen> createState() => _PracticalTrackScreenState();
}

class _PracticalTrackScreenState extends State<PracticalTrackScreen> {
  PracticalTrackManifest? _manifest;
  List<PracticalExercise>? _exercises;
  Object? _error;
  bool _quizTheoryBusy = false;
  bool _quizPratBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final m =
          await PracticalCatalogRepository.loadTrackManifest(widget.trackId);
      final ex =
          await PracticalCatalogRepository.loadExercises(m.exercisesAsset);
      if (!mounted) return;
      setState(() {
        _manifest = m;
        _exercises = ex;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _openQuiz(
    BuildContext context, {
    required String asset,
    required String title,
    required bool pratique,
  }) async {
    if (pratique) {
      if (_quizPratBusy) return;
      setState(() => _quizPratBusy = true);
    } else {
      if (_quizTheoryBusy) return;
      setState(() => _quizTheoryBusy = true);
    }
    try {
      final session = await QuizRepository().buildSoloBundleQuizSession(
        assetKey: asset,
        title: title,
      );
      if (!context.mounted) return;
      context.push('/quiz/run', extra: session);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QCM : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (pratique) {
            _quizPratBusy = false;
          } else {
            _quizTheoryBusy = false;
          }
        });
      }
    }
  }

  void _openTip(BuildContext context, String moduleId) {
    final m = ParcoursRepository.moduleById(moduleId);
    if (m?.lessonAssetPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapitre TIP introuvable.')),
      );
      return;
    }
    context.push('/cours/$moduleId');
  }

  void _openTutorial(BuildContext context, PracticalTutorialRef t) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => PracticalMarkdownScreen(
          assetPath: t.asset,
          title: t.label,
        ),
      ),
    );
  }

  void _showExercise(
    BuildContext context,
    PracticalExercise e,
    List<PracticalTutorialRef> tutorials,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (_, scroll) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ListView(
                controller: scroll,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    e.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.id,
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  if (e.objectif.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Objectif',
                      style: TextStyle(
                        color: EskoliaVisual.neonCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      e.objectif,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Etapes',
                    style: TextStyle(
                      color: EskoliaVisual.neonCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (var i = 0; i < e.etapes.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.etapes[i],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (tutorials.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Bloque sur une etape ?',
                      style: TextStyle(
                        color: EskoliaVisual.neonCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final t in tutorials)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              _openTutorial(context, t);
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                                color: Colors.white.withValues(alpha: 0.03),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: _slate,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t.label,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    color: _slate,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    final m = _manifest;
    final ex = _exercises;

    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EskoliaAppBar.standard(
                  context,
                  title: m?.title ?? 'Theme',
                ),
                Expanded(
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(hPad),
                            child: Text(
                              '$_error',
                              style: TextStyle(color: Colors.red.shade200),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : m == null || ex == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: EskoliaVisual.neonCyan,
                              ),
                            )
                          : DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    hPad,
                                    8,
                                    hPad,
                                    10,
                                  ),
                                  child: Text(
                                    m.subtitle,
                                    style: TextStyle(
                                      color: _slate.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                if (m.missionsAsset != null &&
                                    m.missionsAsset!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      hPad,
                                      0,
                                      hPad,
                                      10,
                                    ),
                                    child: EskoliaButton(
                                      label: 'Parcours missions (VM)',
                                      variant: EskoliaButtonVariant.secondary,
                                      expand: true,
                                      icon: Icons.flag_outlined,
                                      onPressed: () => context.push(
                                        '/tp/${widget.trackId}/missions',
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: hPad),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: EskoliaButton(
                                          label: _quizTheoryBusy
                                              ? '...'
                                              : 'QCM rappels (16)',
                                          variant: EskoliaButtonVariant.secondary,
                                          expand: true,
                                          onPressed: _quizTheoryBusy ||
                                                  m.quizTheoryAsset.isEmpty
                                              ? null
                                              : () => _openQuiz(
                                                    context,
                                                    asset: m.quizTheoryAsset,
                                                    title:
                                                        '${m.title} — QCM rappels',
                                                    pratique: false,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: EskoliaButton(
                                          label: _quizPratBusy
                                              ? '...'
                                              : 'QCM pratique (15)',
                                          variant: EskoliaButtonVariant.primary,
                                          expand: true,
                                          onPressed: _quizPratBusy ||
                                                  m.quizPratiqueAsset.isEmpty
                                              ? null
                                              : () => _openQuiz(
                                                    context,
                                                    asset: m.quizPratiqueAsset,
                                                    title:
                                                        '${m.title} — QCM pratique',
                                                    pratique: true,
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (m.tipModuleId.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      hPad,
                                      8,
                                      hPad,
                                      0,
                                    ),
                                    child: EskoliaButton(
                                      label: 'Cours TIP (complet)',
                                      variant: EskoliaButtonVariant.ghost,
                                      expand: true,
                                      onPressed: () =>
                                          _openTip(context, m.tipModuleId),
                                    ),
                                  ),
                                Material(
                                  color: Colors.transparent,
                                  child: TabBar(
                                    indicatorColor: EskoliaVisual.neonCyan,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.white
                                        .withValues(alpha: 0.45),
                                    tabs: [
                                      const Tab(text: 'Tutoriels'),
                                      Tab(text: 'TP (${ex.length})'),
                                      const Tab(text: 'Aide'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      ListView(
                                        padding: EdgeInsets.fromLTRB(
                                          hPad,
                                          12,
                                          hPad,
                                          kEskoliaBottomNavReserve,
                                        ),
                                        children: [
                                          for (final t in m.tutorials)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: ListTile(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                    side: BorderSide(
                                                      color: Colors.white
                                                          .withValues(
                                                        alpha: 0.15,
                                                      ),
                                                    ),
                                                  ),
                                                  tileColor: Colors.white
                                                      .withValues(alpha: 0.04),
                                                  title: Text(
                                                    t.label,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    t.asset,
                                                    style: TextStyle(
                                                      color: _slate.withValues(
                                                        alpha: 0.75,
                                                      ),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  trailing: const Icon(
                                                    Icons.open_in_new_rounded,
                                                    color: _slate,
                                                  ),
                                                  onTap: () =>
                                                      _openTutorial(context, t),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      ListView.separated(
                                        padding: EdgeInsets.fromLTRB(
                                          hPad,
                                          12,
                                          hPad,
                                          kEskoliaBottomNavReserve,
                                        ),
                                        itemCount: ex.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (ctx, i) {
                                          final e = ex[i];
                                          return Material(
                                            color: Colors.transparent,
                                            child: ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: EskoliaVisual
                                                      .neonViolet
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              tileColor: Colors.white
                                                  .withValues(alpha: 0.04),
                                              leading: CircleAvatar(
                                                backgroundColor: EskoliaVisual
                                                    .neonViolet
                                                    .withValues(alpha: 0.25),
                                                foregroundColor: Colors.white,
                                                child: Text(
                                                  '${i + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                e.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              subtitle: Text(
                                                e.objectif,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: _slate.withValues(
                                                    alpha: 0.9,
                                                  ),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.expand_more_rounded,
                                                color: _slate,
                                              ),
                                              onTap: () =>
                                                  _showExercise(
                                                    context,
                                                    e,
                                                    m.tutorials,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListView(
                                        padding: EdgeInsets.fromLTRB(
                                          hPad,
                                          16,
                                          hPad,
                                          kEskoliaBottomNavReserve,
                                        ),
                                        children: [
                                          Text(
                                            'Conseils examen',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            '• Pour l’oral, entraine-toi a definir l’AD et a dessiner l’arborescence sans internet.\n'
                                            '• En cas d’echec de jointure : DNS client, ping du DC, FQDN exact.\n'
                                            '• Les QCM pratiques portent sur des situations ; les QCM rappels sur les definitions.\n'
                                            '• Si tu bloques sur un TP, ouvre un tutoriel du theme puis reviens sur l’exercice.',
                                            style: TextStyle(
                                              color: _slate.withValues(
                                                alpha: 0.92,
                                              ),
                                              fontSize: 14,
                                              height: 1.45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
