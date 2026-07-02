import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../lobby/data/models/custom_quiz_data.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../models/quiz_models.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_catalog_track_selector.dart';
import '../components/quiz_scope_picker.dart';


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
  late final TextEditingController _questionsController;

  @override
  void initState() {
    super.initState();
    _questionsController = TextEditingController(text: '${_maxQuestions.round()}');
    _catalogFuture = TipQuizCatalog.loadChaptersWithQuiz();
  }

  @override
  void dispose() {
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _playEskoliaQuiz() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.quiz);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun quiz dans Eskolia/Quiz/. Genere des quiz depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EskoliaQuizFilePicker(files: files),
    );
    if (picked == null || !mounted) return;
    final raw = await fs.readFile(EskoliaFolder.quiz, picked);
    if (raw == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce fichier.')));
      return;
    }
    try {
      final data = CustomQuizData.fromJsonString(raw);
      final qs = data.questions.asMap().entries.map((e) {
          final q = e.value;
          return QuizQuestion(
            id: 'cq_${e.key}',
            type: q.type,
            question: q.question,
            answer: q.answer,
            difficultyBucket: q.difficulty,
            explanation: q.hint.isNotEmpty ? q.hint : null,
            contextLine: q.contextLine,
            indices: q.indices.isNotEmpty ? q.indices : null,
            answerSequence: q.items.isNotEmpty ? q.items : null,
            options: q.items.isNotEmpty ? q.items : null,
            authorName: data.author,
          );
        }).toList();
      final session = QuizSession(
        sessionId: 'eskolia_${DateTime.now().millisecondsSinceEpoch}',
        title: data.title,
        questions: qs,
        currentIndex: 0,
        userScores: List.filled(qs.length, null),
        startTime: DateTime.now(),
      );
      if (mounted) context.push('/quiz/run', extra: session);
    } on FormatException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fichier invalide : ${e.message}')));
    }
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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
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
              child: CircularProgressIndicator(color: EskoliaTokens.cyan),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur de chargement du catalogue.\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: EskoliaTokens.textSecondary),
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
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
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
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
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
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => context.push('/quiz/revision-lacunes'),
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('\u{1F9EC}', style: TextStyle(fontSize: 28)),
                title: const Text(
                  'Recap IA de mes quiz',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Solo — L\'IA analyse tes bilans enregistres et identifie tes lacunes recurrentes.',
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => context.push('/quiz/bilan-recap'),
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Text('\u{1F4C2}', style: TextStyle(fontSize: 28)),
                title: const Text(
                  'Jouer un quiz Eskolia',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Solo — Lance un quiz .json depuis ton dossier Eskolia/Quiz/.',
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: _playEskoliaQuiz,
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
                style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.95), height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Banque Maîtrise',
                style: TextStyle(
                  color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
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
                style: const TextStyle(color: EskoliaTokens.cyan, fontWeight: FontWeight.w600),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Nombre max de questions (à l\'écrit)',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _maxQuestions > 5
                            ? () {
                                setState(() {
                                  _maxQuestions--;
                                  _questionsController.text = '${_maxQuestions.round()}';
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: EskoliaTokens.cyan),
                      ),
                      Container(
                        width: 70,
                        alignment: Alignment.center,
                        child: TextFormField(
                          controller: _questionsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: EskoliaTokens.cyan),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed >= 5 && parsed <= 100) {
                              setState(() {
                                _maxQuestions = parsed.toDouble();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _maxQuestions < 100
                            ? () {
                                setState(() {
                                  _maxQuestions++;
                                  _questionsController.text = '${_maxQuestions.round()}';
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded, color: EskoliaTokens.cyan),
                      ),
                    ],
                  ),
                ],
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
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 12),
                ),
                value: _prioritizeRevisionPool,
                activeThumbColor: EskoliaTokens.cyan,
                onChanged: (v) =>
                    setState(() => _prioritizeRevisionPool = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _startCustom,
                style: FilledButton.styleFrom(
                  backgroundColor: EskoliaTokens.violetSoft,
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
                EskoliaTokens.violetSoft.withValues(alpha: 0.35),
                EskoliaTokens.cyan.withValues(alpha: 0.2),
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

class _EskoliaQuizFilePicker extends StatelessWidget {
  const _EskoliaQuizFilePicker({required this.files});
  final List<String> files;

  String _label(String f) => f
      .replaceAll('quiz_', '')
      .replaceAll('.json', '')
      .replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Choisir un quiz',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.quiz_rounded, color: EskoliaTokens.violetSoft),
              title: Text(
                _label(files[i]),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: Text(
                files[i],
                style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 11),
              ),
              onTap: () => Navigator.of(context).pop(files[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
