import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../quiz/presentation/quiz_question_context_row.dart';
import '../../quiz/services/revision_pool_repository.dart';
import '../data/lobby_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _red = Color(0xFFE53935);
const Color _slate = Color(0xFF94A3B8);
const Color _orange = Color(0xFFFF9800);
const Color _green = Color(0xFF4CAF50);
const Color _surface = Colors.white10;

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.lobbyId});

  final String lobbyId;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final LobbyRepository _repo = LobbyRepository();
  final RevisionPoolRepository _poolRepo = RevisionPoolRepository();
  final TextEditingController _answerController = TextEditingController();

  StreamSubscription<BattleState>? _sub;
  StreamSubscription<LobbyModel?>? _lobbySub;

  BattleState? _state;
  bool _isHost = false;
  String _countLabel = '';
  Timer? _qTimer;
  int _qSeconds = 20;

  // Sequence drag & drop state
  List<String> _sequenceOrder = [];
  String? _sequenceQuestionId;

  Set<String> _poolKeys = {};

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _sub = _repo.watchBattle(widget.lobbyId).listen(_onBattle);
    _lobbySub = _repo.watchLobby(widget.lobbyId).listen((l) {
      if (mounted) setState(() => _isHost = l?.hostId == _uid);
    });
    _loadPool();
  }

  Future<void> _loadPool() async {
    final keys = await _poolRepo.readKeySet();
    if (mounted) setState(() => _poolKeys = keys);
  }

  void _onBattle(BattleState s) {
    if (!mounted) return;
    final prev = _state;
    _state = s;

    if (s.phase == 'countdown' && prev?.phase != 'countdown') {
      _runCountdown();
    }

    if (s.phase == 'question' && (prev?.phase != 'question' || prev?.currentQuestion != s.currentQuestion)) {
      _answerController.clear();
      _qTimer?.cancel();
      if (s.questions.isNotEmpty && s.currentQuestion < s.questions.length) {
        final q = s.questions[s.currentQuestion];
        if (q.type == 'sequence') _initSequenceForQuestion(q);
      }
    }

    if (s.phase == 'finished' && prev?.phase != 'finished') {
      _countLabel = '';
      _grantBattleAchievements(s);
    }

    setState(() {});
  }

  Future<void> _grantBattleAchievements(BattleState s) async {
    if (_uid.isEmpty || s.players.isEmpty) return;
    final sorted = List<PlayerState>.from(s.players)..sort((a, b) => b.score.compareTo(a.score));
    final won = sorted.isNotEmpty && sorted.first.userId == _uid;
    await AchievementTriggers(
      onUnlocked: (emoji, title) {
        if (mounted) showAchievementSnackBar(context, emoji, title);
      },
    ).onBattleFinished(_uid, won: won);
  }

  Future<void> _runCountdown() async {
    const seq = ['3', '2', '1', 'GO!'];
    for (final t in seq) {
      if (!mounted) return;
      setState(() => _countLabel = t);
      await Future.delayed(const Duration(milliseconds: 650));
    }
    // La transition vers la phase 'question' est gérée par le Future.delayed
    // dans startBattleCountdown (currentQuestion reste à 0 — première question).
  }

  PlayerState? _me(BattleState s) => s.players.where((p) => p.userId == _uid).firstOrNull;

  void _initSequenceForQuestion(BattleQuestion q) {
    if (q.id == _sequenceQuestionId) return;
    if (q.options == null || q.options!.isEmpty) return;
    setState(() {
      _sequenceQuestionId = q.id;
      _sequenceOrder = List<String>.from(q.options!)..shuffle();
    });
  }

  Future<void> _submitSequence() async {
    if (_sequenceOrder.isEmpty) return;
    await _repo.submitAnswer(widget.lobbyId, _uid, jsonEncode(_sequenceOrder));
  }

  Future<void> _submit(String text) async {
    if (text.trim().isEmpty) return;
    await _repo.submitAnswer(widget.lobbyId, _uid, text.trim());
  }

  Future<void> _togglePool(BattleQuestion bq) async {
    final q = bq.toQuizQuestion();
    // On essaie de retrouver l'index (pas idéal ici mais keyForQuestion gère par ID si dispo)
    final key = RevisionPoolRepository.keyForQuestion(q, 0);
    if (_poolKeys.contains(key)) {
      // Pour remove il faut une entry, RevisionPoolEntry.storageKey doit matcher
      final entries = await _poolRepo.readEntries();
      final entry = entries.where((e) => e.storageKey == key).firstOrNull;
      if (entry != null) {
        await _poolRepo.remove(entry);
      }
    } else {
      await _poolRepo.add(q);
    }
    await _loadPool();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _lobbySub?.cancel();
    _qTimer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          if (s == null) const Center(child: CircularProgressIndicator(color: _cyan))
          else EskoliaShellBody(child: _buildPhase(context, s)),
        ],
      ),
    );
  }

  Widget _buildPhase(BuildContext context, BattleState s) {
    switch (s.phase) {
      case 'countdown': return _buildCountdown();
      case 'question': return _buildQuestion(context, s);
      case 'final_judgment':
        return _isHost ? _buildFinalJudgment(context, s) : _buildWaitingFinalJudgment();
      case 'finished': return _buildFinished(context, s);
      default: return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildCountdown() {
    return Center(child: Text(_countLabel, style: const TextStyle(color: Colors.white, fontSize: 84, fontWeight: FontWeight.w900)));
  }

  Widget _buildQuestion(BuildContext context, BattleState s) {
    final q = s.questions[s.currentQuestion];
    final me = _me(s);
    final answered = me?.hasAnswered ?? false;
    final isLast = s.currentQuestion >= s.totalQuestions - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, s),
        _scoreBar(s),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuizQuestionContextRow(contextLine: q.contextLine, difficultyBucket: q.difficultyBucket),
                      const SizedBox(height: 12),
                      if (q.type == 'ticket') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _orange.withValues(alpha:0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: _orange.withValues(alpha:0.5))),
                          child: const Text('TICKET D\'INCIDENT', style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),

                      if (q.type == 'diagnostic_indices' && q.indices != null) ...[
                        const SizedBox(height: 16),
                        ...List.generate(s.revealedIndices, (i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), borderRadius: BorderRadius.circular(8)),
                            child: Text(q.indices![i], style: const TextStyle(color: _cyan, fontSize: 13, fontStyle: FontStyle.italic)),
                          );
                        }),
                      ],

                      const SizedBox(height: 32),
                      if (!answered) ...[
                        if (q.type == 'sequence') ...[
                          _buildSequenceReorder(q),
                          const SizedBox(height: 16),
                          EskoliaButton(
                            label: 'Valider mon ordre',
                            icon: Icons.check_circle_outline_rounded,
                            variant: EskoliaButtonVariant.primary,
                            onPressed: _submitSequence,
                          ),
                        ] else ...[
                          EskoliaTextField(controller: _answerController, hintText: 'Tape ta réponse...', autofocus: true, onSubmitted: _submit),
                          const SizedBox(height: 16),
                          EskoliaButton(label: 'Envoyer', icon: Icons.send_rounded, variant: EskoliaButtonVariant.primary, onPressed: () => _submit(_answerController.text)),
                        ],
                      ] else ...[
                        const Center(child: CircularProgressIndicator(color: _violet)),
                        const SizedBox(height: 16),
                        Text('Réponse envoyée ! En attente du prof...', style: TextStyle(color: _slate, fontSize: 14, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
                // Seul le host peut passer à la suite
                if (_isHost) ...[
                  const SizedBox(height: 16),
                  if (q.type == 'diagnostic_indices' && q.indices != null && s.revealedIndices < q.indices!.length)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EskoliaButton(
                        label: 'Révéler un indice à la classe',
                        icon: Icons.lightbulb_outline,
                        variant: EskoliaButtonVariant.secondary,
                        expand: true,
                        onPressed: () => _repo.revealIndice(widget.lobbyId),
                      ),
                    ),
                  EskoliaButton(
                    label: isLast ? 'Terminer le quiz →' : 'Question suivante →',
                    icon: isLast ? Icons.checklist_rounded : Icons.arrow_forward_rounded,
                    variant: EskoliaButtonVariant.primary,
                    expand: true,
                    onPressed: () => _repo.advanceToNextQuestion(widget.lobbyId),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _poolPin(BattleQuestion bq, {bool large = false}) {
    final q = bq.toQuizQuestion();
    final key = RevisionPoolRepository.keyForQuestion(q, 0);
    final inPool = _poolKeys.contains(key);

    return IconButton(
      onPressed: () => _togglePool(bq),
      iconSize: large ? 32 : 24,
      icon: Icon(
        inPool ? Icons.push_pin_rounded : Icons.push_pin_outlined,
        color: inPool ? _orange : Colors.white30,
      ),
      tooltip: inPool ? 'Retirer du pool de révision' : 'Épingler pour réviser plus tard',
    );
  }

  Widget _buildSequenceReorder(BattleQuestion q) {
    if (_sequenceQuestionId != q.id || _sequenceOrder.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: const [
            Icon(Icons.swap_vert_rounded, color: _cyan, size: 16),
            SizedBox(width: 6),
            Text(
              'GLISSE POUR ORDONNER',
              style: TextStyle(color: _cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _sequenceOrder.removeAt(oldIndex);
              _sequenceOrder.insert(newIndex, item);
            });
          },
          proxyDecorator: (child, index, animation) => Material(
            color: Colors.transparent,
            elevation: 6,
            shadowColor: _violet.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          children: [
            for (int i = 0; i < _sequenceOrder.length; i++)
              _buildSequenceItem(
                key: ValueKey(_sequenceOrder[i]),
                index: i,
                label: _sequenceOrder[i],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSequenceItem({required Key key, required int index, required String label}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _violet.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.drag_handle_rounded, color: Colors.white30, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingFinalJudgment() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.checklist_rounded, color: _cyan, size: 64),
          const SizedBox(height: 24),
          const Text('Correction en cours…', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Le prof corrige les réponses de tout le monde.', style: TextStyle(color: _slate, fontSize: 15), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFinalJudgment(BuildContext context, BattleState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: _cyan, width: 3)),
                ),
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  'CORRECTION FINALE',
                  style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.88),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: s.questions.length,
            itemBuilder: (context, qi) {
              final q = s.questions[qi];
              final answers = qi < s.allAnswers.length ? s.allAnswers[qi] : <String, String>{};
              final judgments = qi < s.allJudgments.length ? s.allJudgments[qi] : <String, bool?>{};

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // En-tête question
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Q${qi + 1}', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _green.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_rounded, color: _green, size: 14),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(q.answer, style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      // Réponses des joueurs
                      ...s.players.map((p) {
                        final playerAnswer = answers[p.userId] ?? '—';
                        final judgment = judgments[p.userId];
                        final alreadyJudged = judgment != null;

                        Color bg = Colors.transparent;
                        Color border = Colors.white10;
                        if (alreadyJudged) {
                          bg = judgment! ? _green.withValues(alpha: 0.07) : _red.withValues(alpha: 0.07);
                          border = judgment ? _green.withValues(alpha: 0.3) : _red.withValues(alpha: 0.3);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Text(p.avatar, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(playerAnswer,
                                      style: TextStyle(
                                        color: alreadyJudged
                                            ? (judgment! ? _green : _red)
                                            : Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (alreadyJudged)
                                Icon(judgment! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: judgment ? _green : _red, size: 22)
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: _red, size: 24),
                                      onPressed: () => _repo.judgeAnswerAtEnd(widget.lobbyId, qi, p.userId, false),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check_rounded, color: _green, size: 24),
                                      onPressed: () => _repo.judgeAnswerAtEnd(widget.lobbyId, qi, p.userId, true),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: EskoliaButton(
            label: 'Afficher les scores finaux',
            icon: Icons.emoji_events_rounded,
            variant: EskoliaButtonVariant.primary,
            expand: true,
            onPressed: () => _repo.finalizeBattle(widget.lobbyId),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, BattleState s) {
    return Padding(padding: const EdgeInsets.fromLTRB(12, 8, 16, 8), child: Row(children: [
      IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () async {
          final leave = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF151B2E),
              title: const Text('Quitter la battle ?', style: TextStyle(color: Colors.white)),
              content: const Text(
                'Tu vas abandonner la partie en cours. Le host pourra continuer sans toi.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(backgroundColor: _red),
                  child: const Text('Quitter'),
                ),
              ],
            ),
          );
          if (leave == true && context.mounted) {
            await _repo.leaveLobby(widget.lobbyId, _uid);
            if (context.mounted) Navigator.of(context).pop();
          }
        },
      ),
      if (s.timed) _timerBadge(s),
      const SizedBox(width: 12),
      Expanded(child: LinearProgressIndicator(value: (s.currentQuestion + 1) / s.totalQuestions, backgroundColor: _surface, valueColor: const AlwaysStoppedAnimation<Color>(_violet))),
      const SizedBox(width: 12),
      _indexBadge(s),
    ]));
  }

  Widget _timerBadge(BattleState s) {
    return SizedBox(width: 40, height: 40, child: Stack(alignment: Alignment.center, children: [
      CircularProgressIndicator(value: _qSeconds / s.secondsPerQuestion, strokeWidth: 3, color: _qSeconds < 6 ? _red : _violet, backgroundColor: Colors.white12),
      Text('$_qSeconds', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    ]));
  }

  Widget _indexBadge(BattleState s) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: Text('Q ${s.currentQuestion + 1}/${s.totalQuestions}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)));
  }

  Widget _scoreBar(BattleState s) {
    return SizedBox(height: 70, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: s.players.length, separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final p = s.players[i];
        return Column(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: p.hasAnswered ? _violet.withValues(alpha:0.2) : Colors.white10, border: Border.all(color: p.hasAnswered ? _violet : Colors.white10)), alignment: Alignment.center, child: Text(p.avatar, style: const TextStyle(fontSize: 20))),
          const SizedBox(height: 4),
          Text(p.score.toStringAsFixed(1), style: const TextStyle(color: _cyan, fontWeight: FontWeight.bold, fontSize: 10)),
        ]);
      }));
  }

  Widget _buildFinished(BuildContext context, BattleState s) {
    final sorted = List<PlayerState>.from(s.players)..sort((a, b) => b.score.compareTo(a.score));
    const medals = ['🥇', '🥈', '🥉'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('PODIUM FINAL', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('${s.totalQuestions} questions · ${sorted.length} joueurs', style: TextStyle(color: _slate, fontSize: 13)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = sorted[i];
                final medal = i < medals.length ? medals[i] : '${i + 1}.';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: i == 0 ? const Color(0xFFFFD700).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: i == 0 ? const Color(0xFFFFD700).withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Text(medal, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(p.avatar, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                      Text('${p.score.toStringAsFixed(0)} pts', style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          EskoliaButton(
            label: 'Quitter le lobby',
            icon: Icons.logout_rounded,
            variant: EskoliaButtonVariant.secondary,
            expand: true,
            onPressed: () async {
              await _repo.leaveLobby(widget.lobbyId, _uid);
              if (context.mounted) context.go('/lobbys');
            },
          ),
        ],
      ),
    );
  }
}
