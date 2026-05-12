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
      _startQuestionFlow(s);
      if (s.questions.isNotEmpty && s.currentQuestion < s.questions.length) {
        final q = s.questions[s.currentQuestion];
        if (q.type == 'sequence') _initSequenceForQuestion(q);
      }
    }

    if (s.phase == 'finished' && prev?.phase != 'finished') {
      _countLabel = ''; // Reset countdown label
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

  void _startQuestionFlow(BattleState s) {
    _qTimer?.cancel();
    _qSeconds = s.secondsPerQuestion;
    if (!s.timed) return;
    _qTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _state?.phase != 'question') {
        timer.cancel();
        return;
      }
      setState(() {
        _qSeconds--;
        if (_qSeconds <= 0) {
          timer.cancel();
          if (_isHost) _repo.setBattlePhaseJudgment(widget.lobbyId);
        }
      });
    });
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
      case 'judgment': return _isHost ? _buildHostJudgment(context, s) : _buildWaitingForHost(context, s);
      case 'result': return _buildResult(context, s);
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
                      
                      // Affichage des indices pour tous les joueurs (piloté par le Host)
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
                        Text('Réponse envoyée ! En attente...', style: TextStyle(color: _slate, fontSize: 14, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
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
                        onPressed: () => _repo.revealIndice(widget.lobbyId)
                      ),
                    ),
                  EskoliaButton(label: 'Passer au jugement', icon: Icons.gavel_rounded, variant: EskoliaButtonVariant.primary, expand: true, onPressed: () => _repo.setBattlePhaseJudgment(widget.lobbyId)),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostJudgment(BuildContext context, BattleState s) {
    final q = s.questions[s.currentQuestion];
    if (q.type == 'sequence') return _buildSequenceJudgment(context, s, q);
    return Column(
      children: [
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: _cyan, width: 3)),
                ),
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  'CORRECTION COLLECTIVE',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.88),
                ),
              ),
              const Spacer(),
              _poolPin(q),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Question
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(q.question, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        // Réponse attendue
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _green.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_rounded, color: _green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.answer,
                  style: const TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Liste joueurs côte à côte
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            itemCount: s.players.length,
            itemBuilder: (context, i) {
              final p = s.players[i];
              final judged = p.lastJudgment != null;
              final playerAnswer = p.lastAnswerText ?? '—';
              final bgColor = judged
                  ? (p.lastJudgment! ? _green.withValues(alpha: 0.08) : _red.withValues(alpha: 0.08))
                  : Colors.white.withValues(alpha: 0.04);
              final borderColor = judged
                  ? (p.lastJudgment! ? _green.withValues(alpha: 0.35) : _red.withValues(alpha: 0.35))
                  : Colors.white.withValues(alpha: 0.08);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Text(p.avatar, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      // Réponses côte à côte
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Joueur', style: TextStyle(color: _slate, fontSize: 10, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(
                                        playerAnswer,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: judged
                                              ? (p.lastJudgment! ? _green : _red)
                                              : Colors.white.withValues(alpha: 0.85),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1), margin: const EdgeInsets.symmetric(horizontal: 10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Attendu', style: TextStyle(color: _slate, fontSize: 10, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(
                                        q.answer,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: _green, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Boutons jugement ou score
                      if (judged)
                        Text(
                          '${p.lastScore.toStringAsFixed(0)} pts',
                          style: TextStyle(color: p.lastJudgment! ? _green : _red, fontWeight: FontWeight.w900, fontSize: 13),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: _red, size: 26),
                                onPressed: () => _repo.judgePlayerAnswer(widget.lobbyId, p.userId, false),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                icon: const Icon(Icons.check_rounded, color: _green, size: 26),
                                onPressed: () => _repo.judgePlayerAnswer(widget.lobbyId, p.userId, true),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                              ),
                            ),
                          ],
                        ),
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
            label: 'Valider la manche',
            icon: Icons.arrow_forward_rounded,
            variant: EskoliaButtonVariant.primary,
            expand: true,
            onPressed: () => _repo.showRoundResult(widget.lobbyId),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForHost(BuildContext context, BattleState s) {
    final q = s.questions[s.currentQuestion];
    final myAnswer = _me(s)?.lastAnswerText;
    final isSeq = q.type == 'sequence';

    Widget? answerWidget;
    if (myAnswer != null && myAnswer.isNotEmpty) {
      if (isSeq) {
        List<String> order = [];
        try {
          final decoded = jsonDecode(myAnswer);
          if (decoded is List) order = List<String>.from(decoded);
        } catch (_) {}
        answerWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ton ordre soumis', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (int i = 0; i < order.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${i + 1}. ${order[i]}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
          ],
        );
      } else {
        answerWidget = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ta réponse', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(myAnswer, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.gavel_rounded, color: _cyan, size: 64),
        const SizedBox(height: 20),
        const Text('Correction en cours...', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          isSeq ? 'Les scores sont calculés automatiquement.' : 'Le Host examine les réponses de la classe.',
          style: const TextStyle(color: _slate, fontSize: 15),
        ),
        if (answerWidget != null) ...[
          const SizedBox(height: 24),
          answerWidget,
        ],
        const SizedBox(height: 24),
        _poolPin(q, large: true),
        const SizedBox(height: 12),
        const Text('Besoin de réviser cette question ?', style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
      ]),
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

  /// Jugement automatique pour type == 'sequence' : score calculé par position.
  Widget _buildSequenceJudgment(BuildContext context, BattleState s, BattleQuestion q) {
    final correct = q.answerSequence ?? [];
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: _cyan, width: 3)),
                ),
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  'CORRECTION — ORDRE À REMETTRE',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.88),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Ordre correct de référence
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ORDRE CORRECT', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                const SizedBox(height: 8),
                for (int i = 0; i < correct.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${i + 1}. ${correct[i]}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            itemCount: s.players.length,
            itemBuilder: (context, i) {
              final p = s.players[i];
              List<String> playerOrder = [];
              try {
                final decoded = jsonDecode(p.lastAnswerText ?? '[]');
                if (decoded is List) playerOrder = List<String>.from(decoded);
              } catch (_) {}

              int okCount = 0;
              for (int j = 0; j < correct.length; j++) {
                if (j < playerOrder.length && playerOrder[j] == correct[j]) okCount++;
              }
              final score = correct.isEmpty ? 0.0 : okCount / correct.length;
              final color = score == 1.0 ? _green : score > 0 ? _orange : _red;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(p.avatar, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            for (int j = 0; j < correct.length && j < playerOrder.length; j++)
                              Row(
                                children: [
                                  Icon(
                                    playerOrder[j] == correct[j] ? Icons.check_rounded : Icons.close_rounded,
                                    size: 14,
                                    color: playerOrder[j] == correct[j] ? _green : _red,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${j + 1}. ${playerOrder[j]}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: playerOrder[j] == correct[j] ? Colors.white70 : _red.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '$okCount/${correct.length}',
                        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
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
            label: 'Valider les scores',
            icon: Icons.arrow_forward_rounded,
            variant: EskoliaButtonVariant.primary,
            expand: true,
            onPressed: () async {
              await _repo.judgeSequenceAnswers(widget.lobbyId);
              await _repo.showRoundResult(widget.lobbyId);
            },
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

  Widget _buildResult(BuildContext context, BattleState s) {
    return Column(children: [
      const SizedBox(height: 32),
      const Text('Résultats de la manche', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: s.players.map((p) => Card(color: Colors.white.withValues(alpha:0.05), child: ListTile(
        leading: Text(p.avatar, style: const TextStyle(fontSize: 24)),
        title: Text(p.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(p.lastAnswerText ?? '', style: TextStyle(color: _slate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(p.lastJudgment == true ? Icons.check_circle : Icons.cancel, color: p.lastJudgment == true ? _green : _red),
            Text(p.lastScore.toStringAsFixed(2), style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ))).toList())),
      if (_isHost) Padding(padding: const EdgeInsets.all(20), child: EskoliaButton(label: 'Question suivante', icon: Icons.arrow_forward_rounded, variant: EskoliaButtonVariant.primary, expand: true, onPressed: () => _repo.advanceToNextQuestion(widget.lobbyId))),
    ]);
  }

  Widget _buildFinished(BuildContext context, BattleState s) {
    final sorted = List<PlayerState>.from(s.players)..sort((a, b) => b.score.compareTo(a.score));
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('PODIUM FINAL', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
      const SizedBox(height: 40),
      ...sorted.take(3).map((p) => ListTile(leading: Text(p.avatar, style: const TextStyle(fontSize: 32)), title: Text(p.displayName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), trailing: Text('${p.score.toStringAsFixed(1)} pts', style: const TextStyle(color: _cyan, fontSize: 20, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 48),
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
    ]));
  }
}
