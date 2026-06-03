import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../data/true_false_repository.dart';
import '../../../core/constants/eskolia_tokens.dart';

/// Révision rapide : swipe gauche = **Faux**, droite = **Vrai** (ou boutons).
class TrueFalseSwipeScreen extends StatefulWidget {
  const TrueFalseSwipeScreen({super.key, this.roundSize = 10});

  final int roundSize;

  @override
  State<TrueFalseSwipeScreen> createState() => _TrueFalseSwipeScreenState();
}

class _TrueFalseSwipeScreenState extends State<TrueFalseSwipeScreen>
    with SingleTickerProviderStateMixin {
  final _repo = TrueFalseRepository();

  List<TrueFalseItem> _round = [];
  int _index = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  Object? _loadError;

  double _dragX = 0;
  bool _busyLoad = true;
  bool _roundOver = false;
  bool _answering = false;

  late final AnimationController _shake;

  TrueFalseItem? get _current =>
      !_roundOver && _index < _round.length ? _round[_index] : null;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _load();
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busyLoad = true;
      _loadError = null;
    });
    try {
      final list = await _repo.loadRound(count: widget.roundSize);
      if (!mounted) return;
      setState(() {
        _round = list;
        _index = 0;
        _score = 0;
        _streak = 0;
        _bestStreak = 0;
        _roundOver = false;
        _dragX = 0;
        _busyLoad = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e;
          _busyLoad = false;
        });
      }
    }
  }

  void _onAnswer(bool choseTrue) {
    final c = _current;
    if (c == null || _roundOver || _answering) return;
    _answering = true;

    final ok = choseTrue == c.answer;
    if (ok) {
      setState(() {
        _score++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      });
    } else {
      setState(() => _streak = 0);
      _shake.forward(from: 0);
    }

    _showResultSheet(c, ok, choseTrue);
  }

  Future<void> _showResultSheet(TrueFalseItem c, bool ok, bool choseTrue) async {
    try {
      await showModalBottomSheet<void>(
      context: context,
      backgroundColor: EskoliaTokens.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ok ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  color: ok ? EskoliaTokens.success : EskoliaTokens.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tu as répondu : ${choseTrue ? 'VRAI' : 'FAUX'} — '
                'réponse attendue : ${c.answer ? 'VRAI' : 'FAUX'}.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              if (c.explanation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  c.explanation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: EskoliaVisual.neonViolet,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continuer'),
              ),
            ],
          ),
        );
      },
    );
    } finally {
      if (mounted) {
        setState(() {
          _answering = false;
          _dragX = 0;
          _index++;
          if (_index >= _round.length) _roundOver = true;
        });
      }
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dx;
    const threshold = 96.0;
    if (_dragX > threshold || v > 520) {
      _onAnswer(true);
      return;
    }
    if (_dragX < -threshold || v < -520) {
      _onAnswer(false);
      return;
    }
    setState(() => _dragX = 0);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final tint = _dragX.abs() < 8
        ? 0.0
        : math.min(0.35, _dragX.abs() / (w * 0.45));
    final greenBg = _dragX > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Vrai / Faux',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              color: Color.lerp(
                Colors.transparent,
                greenBg
                    ? EskoliaTokens.success.withValues(alpha: 0.22)
                    : EskoliaTokens.error.withValues(alpha: 0.22),
                _dragX == 0 ? 0 : tint,
              ),
            ),
          ),
          EskoliaShellBody(
            safeAreaTop: false,
            child: _busyLoad
                ? const Center(
                    child: CircularProgressIndicator(color: EskoliaTokens.cyan),
                  )
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Impossible de charger les affirmations.\n$_loadError',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: EskoliaTokens.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _load,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _round.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Aucune affirmation disponible pour le moment.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 15),
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton(
                                    onPressed: () => context.pop(),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: EskoliaVisual.neonViolet,
                                    ),
                                    child: const Text('Retour'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _roundOver
                            ? _EndCard(
                                score: _score,
                                total: _round.length,
                                bestStreak: _bestStreak,
                                onReplay: _load,
                                onClose: () => context.pop(),
                              )
                            : _PlayArea(
                                dragX: _dragX,
                                shake: _shake,
                                current: _current!,
                                index: _index,
                                total: _round.length,
                                score: _score,
                                streak: _streak,
                                onDragUpdate: (dx) => setState(() => _dragX += dx),
                                onDragEnd: _onDragEnd,
                                onTapFalse: () => _onAnswer(false),
                                onTapTrue: () => _onAnswer(true),
                              ),
          ),
        ],
      ),
    );
  }
}

class _PlayArea extends StatelessWidget {
  const _PlayArea({
    required this.dragX,
    required this.shake,
    required this.current,
    required this.index,
    required this.total,
    required this.score,
    required this.streak,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTapFalse,
    required this.onTapTrue,
  });

  final double dragX;
  final AnimationController shake;
  final TrueFalseItem current;
  final int index;
  final int total;
  final int score;
  final int streak;
  final void Function(double dx) onDragUpdate;
  final void Function(DragEndDetails d) onDragEnd;
  final VoidCallback onTapFalse;
  final VoidCallback onTapTrue;

  @override
  Widget build(BuildContext context) {
    final rot = (dragX / 4000).clamp(-0.12, 0.12);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        12,
        EskoliaLayout.screenPaddingH,
        EskoliaLayout.screenPaddingBottom,
      ),
      children: [
        Row(
          children: [
            Text(
              '${index + 1} / $total',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              'Score $score · Série $streak',
              style: const TextStyle(
                color: EskoliaTokens.cyan,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Swipe ← FAUX · VRAI → ou utilise les boutons.',
          style: TextStyle(
            color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: shake,
          builder: (context, child) {
            final o = shake.value == 0
                ? 0.0
                : math.sin(shake.value * math.pi * 6) * 8 * (1 - shake.value);
            return Transform.translate(
              offset: Offset(o, 0),
              child: child,
            );
          },
          child: GestureDetector(
            onHorizontalDragUpdate: (d) => onDragUpdate(d.delta.dx),
            onHorizontalDragEnd: onDragEnd,
            child: Transform.translate(
              offset: Offset(dragX, 0),
              child: Transform.rotate(
                angle: rot,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 220),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: EskoliaTokens.surface1,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      current.statement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTapFalse,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EskoliaTokens.error,
                  side: const BorderSide(color: EskoliaTokens.error, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('FAUX'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton.icon(
                onPressed: onTapTrue,
                style: FilledButton.styleFrom(
                  backgroundColor: EskoliaTokens.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('VRAI'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EndCard extends StatelessWidget {
  const _EndCard({
    required this.score,
    required this.total,
    required this.bestStreak,
    required this.onReplay,
    required this.onClose,
  });

  final int score;
  final int total;
  final int bestStreak;
  final VoidCallback onReplay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : score / total;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EskoliaLayout.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Partie terminée',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$score / $total bonnes réponses '
              '(${ratio >= 0.8 ? 'bravo !' : ratio >= 0.5 ? 'pas mal.' : 'on révise encore un peu ?'})',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meilleure série : $bestStreak',
              style: const TextStyle(
                color: EskoliaTokens.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onReplay,
              style: FilledButton.styleFrom(
                backgroundColor: EskoliaVisual.neonViolet,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Rejouer (nouveau mélange)'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClose,
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
