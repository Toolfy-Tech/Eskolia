import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
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
import '../../../shared/widgets/question_thumbs_widget.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_question_context_row.dart';
import '../viewmodels/quiz_notifier.dart';
import 'quiz_result_screen.dart';


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

  // Association drag & drop state
  Map<String, String> _userPairings = {};
  List<String> _assocPool = [];
  String? _assocQuestionId;

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

  void _initAssociationForQuestion(QuizQuestion q) {
    if (q.id == _assocQuestionId) return;
    if (q.matchPairs == null || q.matchPairs!.isEmpty) return;
    setState(() {
      _assocQuestionId = q.id;
      _userPairings = {};
      _assocPool = q.matchPairs!.map((p) => p[1]).toList()..shuffle();
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
    if (q?.type == 'association' && q?.matchPairs != null) {
      ref.read(quizProvider(widget.sessionId).notifier)
          .revealAndScoreAssociation(_userPairings, q!.matchPairs!);
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
      if (q?.type == 'association' && q?.id != _assocQuestionId) {
        _initAssociationForQuestion(q!);
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
        backgroundColor: Colors.transparent,
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
                style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.95)),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => ref.read(quizProvider(widget.sessionId).notifier).initSession(widget.sessionId),
                style: FilledButton.styleFrom(
                  backgroundColor: EskoliaTokens.violetSoft,
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
            final c = Color.lerp(EskoliaTokens.surface2, EskoliaTokens.surface3, t)!;
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
                  Container(color: EskoliaTokens.surface2),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [EskoliaTokens.violetSoft, EskoliaTokens.cyan]),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: QuizQuestionContextRow(
                contextLine: q.contextLine,
                difficultyBucket: q.difficultyBucket,
                categoryGroup: q.categoryGroup,
                authorName: q.authorName,
              ),
            ),
            const SizedBox(width: 8),
            QuestionThumbsWidget(
              questionId: q.id,
              quizTitle: state.session?.title,
              theme: q.theme,
              difficulty: q.difficultyBucket,
              questionType: q.type,
              source: 'solo',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (q.type == 'ticket') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EskoliaTokens.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: EskoliaTokens.orange.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'TICKET D\'INCIDENT',
              style: TextStyle(color: EskoliaTokens.orange, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SelectableText(
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
                style: const TextStyle(color: EskoliaTokens.cyan, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            );
          }),
          if (state.revealedIndicesCount < q.indices!.length && !state.isFlipped)
            TextButton.icon(
              onPressed: () => ref.read(quizProvider(widget.sessionId).notifier).incrementIndices(),
              icon: const Icon(Icons.lightbulb_outline, size: 16),
              label: Text('Révéler l\'indice ${state.revealedIndicesCount + 1}'),
              style: TextButton.styleFrom(foregroundColor: EskoliaTokens.orange),
            ),
        ],
        const SizedBox(height: 16),
        if (q.type == 'sequence') ...[
          _buildSequenceReorder(q),
        ] else if (q.type == 'association') ...[
          _buildAssociationWidget(q),
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
      // Sequence broken (AI forgot items field) — show answer as plain text.
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          q.answer,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_vert_rounded, color: EskoliaTokens.cyan, size: 16),
            const SizedBox(width: 6),
            const Text(
              'GLISSE POUR ORDONNER',
              style: TextStyle(color: EskoliaTokens.cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
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
            shadowColor: EskoliaTokens.violetSoft.withValues(alpha: 0.4),
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
        border: Border.all(color: EskoliaTokens.violetSoft.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: EskoliaTokens.violetSoft.withValues(alpha: 0.25),
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

  Widget _buildAssociationWidget(QuizQuestion q) {
    if (_assocQuestionId != q.id || q.matchPairs == null) return const SizedBox.shrink();
    final pairs = q.matchPairs!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.compare_arrows_rounded, color: EskoliaTokens.violetSoft, size: 16),
            const SizedBox(width: 6),
            const Text(
              'GLISSE POUR ASSOCIER',
              style: TextStyle(color: EskoliaTokens.violetSoft, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_assocPool.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _assocPool.map((item) => Draggable<String>(
              data: item,
              feedback: Material(
                color: Colors.transparent,
                child: _buildAssocChip(item, dragging: true),
              ),
              childWhenDragging: _buildAssocChip(item, ghost: true),
              child: _buildAssocChip(item),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        ...pairs.map((pair) {
          final leftItem = pair[0];
          final placed = _userPairings[leftItem];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Text(leftItem, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white30, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: DragTarget<String>(
                    onAccept: (item) {
                      setState(() {
                        if (_userPairings[leftItem] != null) {
                          _assocPool.add(_userPairings[leftItem]!);
                        }
                        _assocPool.remove(item);
                        _userPairings[leftItem] = item;
                      });
                    },
                    builder: (ctx, candidates, rejected) {
                      final isHovered = candidates.isNotEmpty;
                      if (placed != null) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _assocPool.add(placed);
                              _userPairings.remove(leftItem);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: EskoliaTokens.violetSoft.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: EskoliaTokens.violetSoft.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(placed, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3))),
                                Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.4), size: 14),
                              ],
                            ),
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isHovered ? EskoliaTokens.violetSoft.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isHovered ? EskoliaTokens.violetSoft.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          'Dépose ici...',
                          style: TextStyle(
                            color: isHovered ? EskoliaTokens.violetSoft : Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAssocChip(String item, {bool dragging = false, bool ghost = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ghost
            ? Colors.white.withValues(alpha: 0.04)
            : dragging
                ? EskoliaTokens.violetSoft.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ghost
              ? Colors.white.withValues(alpha: 0.1)
              : EskoliaTokens.violetSoft.withValues(alpha: dragging ? 1.0 : 0.4),
        ),
      ),
      child: Text(
        item,
        style: TextStyle(
          color: ghost ? Colors.white24 : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAssociationComparison(List<List<String>> correctPairs) {
    int correctCount = 0;
    for (final pair in correctPairs) {
      if (pair.length >= 2 && _userPairings[pair[0]] == pair[1]) correctCount++;
    }
    final total = correctPairs.length;
    final allCorrect = correctCount == total;
    final accent = allCorrect ? EskoliaTokens.success : (correctCount > 0 ? EskoliaTokens.orange : EskoliaTokens.error);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                allCorrect ? '\u{1F3C6}' : (correctCount > 0 ? '\u{1F4CA}' : '\u{1F504}'),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                allCorrect
                    ? 'Toutes les paires correctes !'
                    : '$correctCount / $total paire${total > 1 ? 's' : ''} correcte${correctCount > 1 ? 's' : ''}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...correctPairs.map((pair) {
          if (pair.length < 2) return const SizedBox.shrink();
          final left = pair[0];
          final correct = pair[1];
          final placed = _userPairings[left];
          final isOk = placed == correct;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(left, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 4, right: 4),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 14),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isOk ? EskoliaTokens.success.withValues(alpha: 0.1) : EskoliaTokens.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOk ? EskoliaTokens.success.withValues(alpha: 0.4) : EskoliaTokens.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(isOk ? Icons.check_rounded : Icons.close_rounded, color: isOk ? EskoliaTokens.success : EskoliaTokens.error, size: 13),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                placed ?? '—',
                                style: TextStyle(color: isOk ? Colors.white : Colors.white54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (!isOk) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct : $correct',
                            style: const TextStyle(color: EskoliaTokens.success, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBack(QuizState state, QuizQuestion q) {
    final currentScore = state.isValidated && state.session != null
        ? (state.session!.userScores[state.session!.currentIndex] ?? 0.0)
        : null;
    final isCorrect = (currentScore ?? 1.0) >= 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
            if (state.isValidated) ...[
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? EskoliaTokens.success : EskoliaTokens.error,
                size: 16,
              ),
            ],
            const Spacer(),
            QuestionThumbsWidget(
              questionId: q.id,
              quizTitle: state.session?.title,
              theme: q.theme,
              difficulty: q.difficultyBucket,
              questionType: q.type,
              source: 'solo',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (q.type != 'association') AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.isValidated
                ? (isCorrect ? EskoliaTokens.success.withValues(alpha: 0.12) : EskoliaTokens.error.withValues(alpha: 0.10))
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: state.isValidated
                ? Border.all(color: isCorrect ? EskoliaTokens.success.withValues(alpha: 0.4) : EskoliaTokens.error.withValues(alpha: 0.35))
                : null,
          ),
          child: SelectableText(
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
              color: EskoliaTokens.orange,
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
                      color: isChecked ? EskoliaTokens.success : Colors.white30,
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
        if (q.type == 'association' && q.matchPairs != null) ...[
          const SizedBox(height: 20),
          _buildAssociationComparison(q.matchPairs!),
        ] else if (q.type == 'sequence' && q.answerSequence != null) ...[
          const SizedBox(height: 20),
          _buildSequenceComparison(q.answerSequence!),
        ] else if (q.explanation != null) ...[
          const SizedBox(height: 20),
          if (state.isValidated && !isCorrect)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: EskoliaTokens.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EskoliaTokens.orange.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: EskoliaTokens.orange, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'RETIENS BIEN ÇA',
                        style: TextStyle(color: EskoliaTokens.orange, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.explanation!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            )
          else ...[
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
        ],
        const SizedBox(height: 16),
        if (!state.isValidated && q.type != 'sequence' && q.type != 'association') ...[
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
    final userOrder = _sequenceOrder;
    final correctCount = userOrder.isNotEmpty
        ? List.generate(correctOrder.length, (i) =>
            i < userOrder.length && userOrder[i] == correctOrder[i]).where((v) => v).length
        : 0;
    final total = correctOrder.length;
    final allCorrect = correctCount == total;
    final accent = allCorrect ? EskoliaTokens.success : (correctCount > 0 ? EskoliaTokens.orange : EskoliaTokens.error);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bandeau score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                allCorrect ? '\u{1F3C6}' : (correctCount > 0 ? '\u{1F4CA}' : '\u{1F504}'),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                allCorrect
                    ? 'Ordre parfait !'
                    : '$correctCount / $total étape${total > 1 ? 's' : ''} correcte${correctCount > 1 ? 's' : ''}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // En-têtes colonnes
        Row(
          children: [
            Expanded(
              child: Text(
                'TA RÉPONSE',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ORDRE CORRECT',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Lignes de comparaison
        ...List.generate(correctOrder.length, (i) {
          final userStep = i < userOrder.length ? userOrder[i] : null;
          final correctStep = correctOrder[i];
          final isCorrect = userStep == correctStep;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne user
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? EskoliaTokens.success.withValues(alpha: 0.1)
                          : EskoliaTokens.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCorrect
                            ? EskoliaTokens.success.withValues(alpha: 0.4)
                            : EskoliaTokens.error.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? EskoliaTokens.success.withValues(alpha: 0.2)
                                : EskoliaTokens.error.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_rounded : Icons.close_rounded,
                            color: isCorrect ? EskoliaTokens.success : EskoliaTokens.error,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userStep ?? '—',
                            style: TextStyle(
                              color: isCorrect ? Colors.white : Colors.white54,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Colonne correct
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: EskoliaTokens.success.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            correctStep,
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
      final isAssoc = q?.type == 'association';
      return EskoliaButton(
        label: isSeq
            ? 'Vérifier l\'ordre'
            : isAssoc
                ? 'Vérifier les associations'
                : 'Vérifier la réponse',
        icon: (isSeq || isAssoc) ? Icons.check_circle_outline_rounded : Icons.visibility_rounded,
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
    final timerColor = Color.lerp(EskoliaTokens.violetSoft, EskoliaTokens.error, state.secondsLeft < 10 ? (1 - state.secondsLeft / 10).clamp(0.0, 1.0) : 0.0)!;

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
              if (!snap.hasData) return const Center(child: LinearProgressIndicator(color: EskoliaTokens.cyan));
              final list = snap.data ?? [];
              if (list.isEmpty) return const Text('Soyez le premier !', style: TextStyle(color: Colors.white60, fontSize: 12));
              return Column(
                children: list.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.username, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      Text('${e.score}/${e.total}', style: const TextStyle(color: EskoliaTokens.cyan, fontSize: 12, fontWeight: FontWeight.w900)),
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
