import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_catalog_track_selector.dart';
import '../components/quiz_scope_picker.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);

/// Hub quiz : « du jour » ou composition à partir des sections / chapitres.
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final Set<String> _selected = {};
  double _maxQuestions = 18;
  bool _prioritizeRevisionPool = false;
  QuizCatalogTrack _catalogTrack = QuizCatalogTrack.optimusOnly;
  late final Future<List<TipQuizChapterRef>> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = TipQuizCatalog.loadChaptersWithQuiz();
  }

  Future<void> _startCustom() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis au moins un chapitre ou une section.'),
        ),
      );
      return;
    }
    try {
      final session = await QuizRepository().buildMixedSession(
        assetPaths: _selected.toList(),
        title: 'Quiz personnalisé',
        maxQuestions: _maxQuestions.round(),
        prioritizeRevisionPool: _prioritizeRevisionPool,
      );
      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer le quiz : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Quiz'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<List<TipQuizChapterRef>>(
              future: _catalogFuture,
              builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _cyan),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur de chargement du catalogue.\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _slate),
                ),
              ),
            );
          }
          final all = snap.data ?? [];
          final entries = TipQuizCatalog.filterByTrack(all, _catalogTrack);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              EskoliaLayout.screenPaddingH,
              8,
              EskoliaLayout.screenPaddingH,
              EskoliaLayout.screenPaddingBottom,
            ),
            children: [
              _DailyCard(onTap: () => context.push('/quiz/daily')),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('\u{1F446}', style: TextStyle(fontSize: 28)),
                title: const Text(
                  'Vrai / Faux (swipe)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Solo — affirmations rapides : swipe ou boutons, puis courte explication.',
                  style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => context.push('/quiz/true-false'),
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('\u{1F480}', style: TextStyle(fontSize: 28)),
                title: const Text(
                  'Survival',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Solo — 3 vies, difficulté progressive, pas de choix du nombre de questions. Records top 3.',
                  style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => context.push('/quiz/survival'),
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('\u{1F4A1}', style: TextStyle(fontSize: 28)),
                title: const Text(
                  'Révision lacunes',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Solo — Maîtrise (max 10) sur tes erreurs : parcours, solo et multijoueur.',
                  style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => context.push('/quiz/revision-lacunes'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Composer une Maîtrise',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Coche une section entière ou des chapitres précis. Les questions '
                'sont mélangées dans la limite choisie. Des questionnaires validés par la '
                'modération (Labo) peuvent être ajoutés automatiquement pour les '
                'sections concernées.',
                style: TextStyle(color: _slate.withValues(alpha: 0.95), height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Banque Maîtrise',
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              QuizCatalogTrackSelector(
                value: _catalogTrack,
                onChanged: (t) {
                  setState(() {
                    _catalogTrack = t;
                    final allowed = TipQuizCatalog.filterByTrack(all, t)
                        .map((r) => r.quizAssetPath)
                        .toSet();
                    _selected.removeWhere((p) => !allowed.contains(p));
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${_selected.length} fichier(s) Maîtrise sélectionné(s)',
                style: const TextStyle(color: _cyan, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 360,
                child: QuizScopePicker(
                  entries: entries,
                  selectedPaths: _selected,
                  onSelectionChanged: (s) => setState(() {
                    _selected
                      ..clear()
                      ..addAll(s);
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nombre max de questions',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Text(
                    '${_maxQuestions.round()}',
                    style: const TextStyle(color: _cyan, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Slider(
                min: 5,
                max: 40,
                divisions: 35,
                value: _maxQuestions,
                activeColor: _violet,
                onChanged: (v) => setState(() => _maxQuestions = v),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Priorité pool de révision',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                subtitle: Text(
                  'Les questions épinglées 📌 passent en premier (puis tirage aléatoire).',
                  style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12),
                ),
                value: _prioritizeRevisionPool,
                activeThumbColor: _cyan,
                onChanged: (v) =>
                    setState(() => _prioritizeRevisionPool = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _startCustom,
                style: FilledButton.styleFrom(
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lancer la Maîtrise personnalisée'),
              ),
            ],
          );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _violet.withValues(alpha: 0.35),
                _cyan.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const Text('\u{1F9E0}', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Série rapide sur un thème fixe',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
