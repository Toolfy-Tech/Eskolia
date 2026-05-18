import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/quiz_play_session.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../../../features/classement/data/models/daily_leaderboard_entry.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_flip_card.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_question_context_row.dart';
import '../viewmodels/quiz_notifier.dart';
import 'quiz_result_screen.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF4CAF50);
const Color _red = Color(0xFFF44336);
const Color _orange = Color(0xFFFF9800);
const Color _surface = Color(0xFF1E293B);

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.sessionId,
    this.initialSession,
  });

  final String sessionId;
  final QuizSession? initialSession;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  final LeaderboardRepository _leaderboardRepo = LeaderboardRepository();
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  late AnimationController _pulseController;

  // Sequence drag & drop state
  List<String> _sequenceOrder = [];
  String? _sequenceQuestionId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    // Initialisation du Notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider(widget.sessionId).notifier).initSession(
        widget.sessionId,
        initialSession: widget.initialSession,
      );
      _answerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _initSequenceForQuestion(QuizQuestion q) {
    if (q.id == _sequenceQuestionId) return;
    if (q.options == null || q.options!.isEmpty) return;
    setState(() {
      _sequenceQuestionId = q.id;
      _sequenceOrder = List<String>.from(q.options!)..shuffle();
    });
  }

  void _onReveal() {
    final state = ref.read(quizProvider(widget.sessionId));
    final q = state.session?.questions[state.session!.currentIndex];
    if (q?.type == 'sequence' && q?.answerSequence != null && _sequenceOrder.isNotEmpty) {
      ref.read(quizProvider(widget.sessionId).notifier)
          .revealAndScoreSequence(_sequenceOrder, q!.answerSequence!);
      return;
    }
    ref.read(quizProvider(widget.sessionId).notifier).reveal();
  }

  void _onSubmitFeedback(bool wasCorrect) {
    ref.read(quizProvider(widget.sessionId).notifier).submitFeedback(wasCorrect);
  }

  Future<void> _goNextOrFinish() async {
    final notifier = ref.read(quizProvider(widget.sessionId).notifier);
    final state = ref.read(quizProvider(widget.sessionId));
    
    final hasNext = notifier.nextQuestion();
    
    if (!hasNext) {
      await _openResult(
        state.session!,
        survivalEliminated: state.lives <= 0 && state.session!.runMode == QuizRunMode.survival,
      );
    } else {
      _answerController.clear();
      _answerFocusNode.requestFocus();
    }
  }

  Future<void> _openResult(QuizSession s, {bool survivalEliminated = false}) async {
    double totalScore = 0;
    int correctCount = 0;
    int wrongCount = 0;
    int unansweredCount = 0;

    for (final sc in s.userScores) {
      if (sc == null) {
        unansweredCount++;
      } else {
        totalScore += sc;
        if (sc >= 0.75) {
          correctCount++;
        } else if (sc > 0) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }
    
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => QuizResultScreen(
          sessionId: s.sessionId,
          score: totalScore,
          total: s.questions.length,
          correctCount: correctCount,
          wrongCount: wrongCount,
          unansweredCount: unansweredCount,
          questions: s.questions,
          userScores: List<double?>.from(s.userScores),
          sessionTitle: s.title,
          survivalRun: s.runMode == QuizRunMode.survival,
          survivalEliminated: survivalEliminated,
          survivalCatalogTrack: s.survivalCatalogTrack,
          exitDestination: QuizRepository.resultExitDestination(s),
        ),
      ),
    );
    if (!mounted) return;
    // On peut soit quitter soit relancer
    ref.read(quizProvider(widget.sessionId).notifier).initSession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<QuizState>(quizProvider(widget.sessionId), (prev, next) {
      final q = next.session != null && next.session!.questions.isNotEmpty
          ? next.session!.questions[next.session!.currentIndex]
          : null;
      if (q?.type == 'sequence' && q?.id != _sequenceQuestionId) {
        _initSequenceForQuestion(q!);
      }
    });

    final state = ref.watch(quizProvider(widget.sessionId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        confirmNavigateAwayFromQuiz(context).then((ok) {
          if (context.mounted && ok) context.pop();
        });
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            SafeArea(
              child: _buildBody(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    if (state.error != null) return _buildError(context, state.error!);
    if (state.session == null || state.isLoading) return _buildSkeleton();
    return _buildQuiz(context, state);
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate.withValues(alpha: 0.95)),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => ref.read(quizProvider(widget.sessionId).notifier).initSession(widget.sessionId),
                style: FilledButton.styleFrom(
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final t = _pulseController.value;
            final c = Color.lerp(_surface, const Color(0xFF2D3748), t)!;
            return AnimatedContainer(
              duration: Duration.zero,
              height: 220,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, QuizState state) {
    final s = state.session!;
    if (s.currentIndex < 0 || s.currentIndex >= s.questions.length) {
      return const Center(child: CircularProgressIndicator());
    }
    final q = s.questions[s.currentIndex];
    final total = s.questions.length;
    final progress = total > 0 ? s.currentIndex / total : 0.0;
    final maxW = EskoliaLayout.lessonContentMaxWidth(context);
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: _buildTopBar(context, state, s.currentIndex + 1, total),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: _surface),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [_violet, _cyan]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 28,
                    maxWidth: maxW,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        _dailyLeaderboardPanel(s),
                        if (s.sessionId.startsWith('daily_')) const SizedBox(height: 12),
                        EskoliaFlipCard(
                          isFlipped: state.isFlipped,
                          front: _buildFront(state, q),
                          back: _buildBack(state, q),
                        ),
                        const SizedBox(height: 24),
                        _buildActions(state),
                        SizedBox(height: EskoliaLayout.screenPaddingBottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFront(QuizState state, QuizQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizQuestionContextRow(
          contextLine: q.contextLine,
          difficultyBucket: q.difficultyBucket,
          categoryGroup: q.categoryGroup,
          authorName: q.authorName,
        ),
        const SizedBox(height: 12),
        if (q.type == 'ticket') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _orange.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'TICKET D\'INCIDENT',
              style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          q.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        if (q.type == 'diagnostic_indices' && q.indices != null) ...[
          const Text(
            'INDICES DISPONIBLES',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...List.generate(state.revealedIndicesCount, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                q.indices![i],
                style: const TextStyle(color: _cyan, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            );
          }),
          if (state.revealedIndicesCount < q.indices!.length && !state.isFlipped)
            TextButton.icon(
              onPressed: () => ref.read(quizProvider(widget.sessionId).notifier).incrementIndices(),
              icon: const Icon(Icons.lightbulb_outline, size: 16),
              label: Text('Révéler l\'indice ${state.revealedIndicesCount + 1} (-25% points)'),
              style: TextButton.styleFrom(foregroundColor: _orange),
            ),
        ],
        const SizedBox(height: 16),
        if (q.type == 'sequence') ...[
          _buildSequenceReorder(q),
        ] else ...[
          EskoliaTextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            hintText: 'Tape ta réponse ici...',
            onSubmitted: (_) => _onReveal(),
            autofocus: false,
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 8),
          Text(
            'Effort de mémoire : écris avant de révéler !',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSequenceReorder(QuizQuestion q) {
    if (_sequenceQuestionId != q.id || _sequenceOrder.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_vert_rounded, color: _cyan, size: 16),
            const SizedBox(width: 6),
            const Text(
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

  Widget _buildBack(QuizState state, QuizQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'RÉPONSE ATTENDUE',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            q.answer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (q.type == 'ticket' && q.checklist != null) ...[
          const SizedBox(height: 20),
          const Text(
            'CHECKLIST DE RÉSOLUTION',
            style: TextStyle(
              color: _orange,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(q.checklist!.length, (i) {
            final isChecked = state.ticketChecks[i];
            return InkWell(
              onTap: state.isValidated ? null : () => ref.read(quizProvider(widget.sessionId).notifier).toggleTicketCheck(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? _green : Colors.white30,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q.checklist![i],
                        style: TextStyle(
                          color: isChecked ? Colors.white : Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (q.type == 'sequence' && q.answerSequence != null) ...[
          const SizedBox(height: 20),
          _buildSequenceComparison(q.answerSequence!),
        ] else if (q.explanation != null) ...[
          const SizedBox(height: 20),
          const Text(
            'EXPLICATION / ASTUCE',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation!,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.5),
          ),
        ],
        const SizedBox(height: 16),
        if (!state.isValidated && q.type != 'sequence') ...[
          const Text(
            'Étais-tu proche de la réponse ?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EskoliaButton(
                  label: 'À revoir',
                  icon: Icons.close_rounded,
                  variant: EskoliaButtonVariant.secondary,
                  onPressed: () => _onSubmitFeedback(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EskoliaButton(
                  label: 'J\'avais bon',
                  icon: Icons.check_rounded,
                  variant: EskoliaButtonVariant.primary,
                  onPressed: () => _onSubmitFeedback(true),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSequenceComparison(List<String> correctOrder) {
    final correctCount = _sequenceOrder.isNotEmpty
        ? List.generate(correctOrder.length, (i) =>
            i < _sequenceOrder.length && _sequenceOrder[i] == correctOrder[i]).where((v) => v).length
        : 0;
    final total = correctOrder.length;
    final allCorrect = correctCount == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (allCorrect ? _green : correctCount > 0 ? _orange : _red).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (allCorrect ? _green : correctCount > 0 ? _orange : _red).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                allCorrect ? Icons.emoji_events_rounded : Icons.sort_rounded,
                color: allCorrect ? _green : correctCount > 0 ? _orange : _red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$correctCount / $total étape${total > 1 ? 's' : ''} dans le bon ordre',
                style: TextStyle(
                  color: allCorrect ? _green : correctCount > 0 ? _orange : Colors.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'ORDRE CORRECT',
          style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        const SizedBox(height: 8),
        ...List.generate(correctOrder.length, (i) {
          final correct = i < _sequenceOrder.length && _sequenceOrder[i] == correctOrder[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (correct ? _green : _red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: (correct ? _green : _red).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: correct ? _green : _red,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '${i + 1}.',
                  style: TextStyle(
                    color: correct ? _green : _red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    correctOrder[i],
                    style: TextStyle(
                      color: correct ? Colors.white : Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActions(QuizState state) {
    if (!state.isFlipped) {
      final q = state.session?.questions[state.session!.currentIndex];
      final isSeq = q?.type == 'sequence';
      return EskoliaButton(
        label: isSeq ? 'Vérifier l\'ordre' : 'Vérifier la réponse',
        icon: isSeq ? Icons.check_circle_outline_rounded : Icons.visibility_rounded,
        variant: EskoliaButtonVariant.primary,
        onPressed: _onReveal,
      );
    }

    if (state.isValidated) {
      return EskoliaButton(
        label: state.session!.currentIndex >= state.session!.questions.length - 1
            ? 'Voir les résultats'
            : 'Question suivante',
        icon: Icons.arrow_forward_rounded,
        variant: EskoliaButtonVariant.primary,
        onPressed: _goNextOrFinish,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTopBar(BuildContext context, QuizState state, int displayIndex, int total) {
    final s = state.session!;
    final title = s.title;
    final survival = s.runMode == QuizRunMode.survival;
    final timed = s.timed;
    final timerColor = Color.lerp(_violet, _red, state.secondsLeft < 10 ? (1 - state.secondsLeft / 10).clamp(0.0, 1.0) : 0.0)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () async {
              final ok = await confirmNavigateAwayFromQuiz(context);
              if (context.mounted && ok) context.pop();
            },
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          if (survival)
            ...List.generate(state.lives, (_) => const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('❤️', style: TextStyle(fontSize: 14)),
            )),
          if (timed && !state.isFlipped) ...[
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.secondsLeft / 30,
                  strokeWidth: 3,
                  backgroundColor: Colors.white10,
                  color: timerColor,
                ),
                Text('${state.secondsLeft}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), // fontSize 11 -> 15
              ],
            ),
          ],
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text('Q $displayIndex/$total', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _dailyLeaderboardPanel(QuizSession s) {
    final id = s.sessionId;
    if (!id.startsWith('daily_')) return const SizedBox.shrink();
    final dayKey = id.replaceFirst('daily_', '');
    return EskoliaCardContent(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              const Expanded(child: Text('Classement du jour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<DailyLeaderboardEntry>>(
            stream: _leaderboardRepo.watchDailyQuizScores(dayKey: dayKey, limit: 5),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: LinearProgressIndicator(color: _cyan));
              final list = snap.data ?? [];
              if (list.isEmpty) return const Text('Soyez le premier !', style: TextStyle(color: Colors.white60, fontSize: 12));
              return Column(
                children: list.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.username, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      Text('${e.score}/${e.total}', style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.w900)),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
