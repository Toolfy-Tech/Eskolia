import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

import '../../features/feedback/data/question_feedback_repository.dart';

/// Boutons 👍 / 👎 affichés en haut à droite de chaque carte de question.
/// Non-bloquant : les erreurs réseau sont silencieuses pour ne pas perturber le quiz.
class QuestionThumbsWidget extends StatefulWidget {
  const QuestionThumbsWidget({
    super.key,
    required this.questionId,
    this.quizTitle,
    this.theme,
    required this.difficulty,
    required this.questionType,
    required this.source,
  });

  final String questionId;
  final String? quizTitle;
  final String? theme;
  final String difficulty;
  final String questionType;

  /// Contexte d'origine : 'solo', 'battle', 'quick', 'survival', 'true_false'
  final String source;

  @override
  State<QuestionThumbsWidget> createState() => _QuestionThumbsWidgetState();
}

class _QuestionThumbsWidgetState extends State<QuestionThumbsWidget> {
  final _repo = QuestionFeedbackRepository();
  int? _vote; // +1, -1 ou null
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadVote();
  }

  @override
  void didUpdateWidget(QuestionThumbsWidget old) {
    super.didUpdateWidget(old);
    if (old.questionId != widget.questionId) {
      setState(() => _vote = null);
      _loadVote();
    }
  }

  Future<void> _loadVote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final v = await _repo.getMyVote(uid, widget.questionId);
    if (mounted) setState(() => _vote = v);
  }

  Future<void> _castVote(int value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _busy) return;
    setState(() => _busy = true);
    final newVote = _vote == value ? 0 : value;
    try {
      await _repo.vote(
        userId: uid,
        questionId: widget.questionId,
        vote: newVote,
        quizTitle: widget.quizTitle,
        theme: widget.theme,
        difficulty: widget.difficulty,
        questionType: widget.questionType,
        source: widget.source,
      );
      if (mounted) setState(() => _vote = newVote == 0 ? null : newVote);
    } catch (_) {
      // Silencieux : ne pas interrompre le quiz
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThumbButton(
          icon: Icons.thumb_up_rounded,
          active: _vote == 1,
          activeColor: EskoliaTokens.success,
          onTap: _busy ? null : () => _castVote(1),
        ),
        const SizedBox(width: 6),
        _ThumbButton(
          icon: Icons.thumb_down_rounded,
          active: _vote == -1,
          activeColor: EskoliaTokens.error,
          onTap: _busy ? null : () => _castVote(-1),
        ),
      ],
    );
  }
}

class _ThumbButton extends StatelessWidget {
  const _ThumbButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: active ? activeColor : Colors.white.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
