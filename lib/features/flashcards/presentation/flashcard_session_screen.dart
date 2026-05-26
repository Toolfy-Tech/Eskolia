import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../economy/data/daily_quest_reward_service.dart';
import '../../home/data/daily_quests_repository.dart';
import '../data/flashcard_deck_repository.dart';

/// Arguments pour [GoRouter] (`/flashcards/session`).
class FlashcardSessionRouteArgs {
  const FlashcardSessionRouteArgs({
    required this.cards,
    this.ephemeral = false,
    this.timed = false,
    this.survival = false,
  });

  final List<DeckFlashcard> cards;
  final bool ephemeral;
  final bool timed;
  final bool survival;
}

/// Session flashcards : flip + auto-évaluation (blueprint v3).
class FlashcardSessionScreen extends StatefulWidget {
  const FlashcardSessionScreen({
    super.key,
    required this.cards,
    this.ephemeral = false,
    this.timed = false,
    this.survival = false,
  });

  final List<DeckFlashcard> cards;
  final bool ephemeral;
  final bool timed;
  final bool survival;

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen> {
  final _deckRepo = FlashcardDeckRepository();
  late List<DeckFlashcard> _cards;
  int _index = 0;
  bool _showBack = false;
  int _knew = 0;
  int _almost = 0;
  int _forgot = 0;
  static const int _secondsPerCard = 20;
  int _secondsLeft = _secondsPerCard;
  Timer? _timer;
  bool _timedOut = false;
  int _lives = 0;

  @override
  void initState() {
    super.initState();
    _cards = List<DeckFlashcard>.from(widget.cards);
    _lives = widget.survival ? 3 : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerCard;
    _timedOut = false;
    if (!widget.timed) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          t.cancel();
          _onTimeUp();
        }
      });
    });
  }

  void _onTimeUp() {
    if (!widget.timed) return;
    if (_index >= _cards.length) return;
    if (_timedOut) return;
    setState(() => _timedOut = true);
    _onGrade(FlashcardGrade.forgot);
  }

  Future<void> _onGrade(FlashcardGrade g) async {
    if (_index >= _cards.length) return;
    _timer?.cancel();
    final cur = _cards[_index];
    switch (g) {
      case FlashcardGrade.knew:
        _knew++;
        break;
      case FlashcardGrade.almost:
        _almost++;
        break;
      case FlashcardGrade.forgot:
        _forgot++;
        break;
    }
    if (widget.survival && g == FlashcardGrade.forgot) {
      setState(() => _lives--);
      if (_lives <= 0) {
        await _finish(survivalEliminated: true);
        return;
      }
    }
    final next = DeckFlashcard.applyGrade(cur, g);
    _cards[_index] = next;
    if (!widget.ephemeral) {
      await _deckRepo.upsert(next);
    }
    if (_index >= _cards.length - 1) {
      await _finish(survivalEliminated: false);
      return;
    }
    setState(() {
      _index++;
      _showBack = false;
      _timedOut = false;
    });
    _startTimer();
  }

  Future<void> _finish({required bool survivalEliminated}) async {
    _timer?.cancel();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _cards.isNotEmpty) {
      final xp = 5 + _knew * 3 + _almost;
      try {
        await UserRepository().addXp(uid, xp);
      } catch (_) {}
    }
    if (uid != null) {
      await DailyQuestRewardService().onFlashSessionCompleted(uid);
      await AchievementTriggers(
        onUnlocked: (emoji, title) {
          if (mounted) showAchievementSnackBar(context, emoji, title);
        },
      ).onFlashSessionCompleted(uid);
      final u = await UserRepository().getUserById(uid);
      if (u != null) {
        await AchievementTriggers().syncFromUserSnapshot(u);
      }
    } else {
      await DailyQuestsRepository().markFlashcardSessionDone();
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        title: const Text(
          'Session terminée',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.survival && survivalEliminated) ...[
              Text(
                'Survival : plus de vies.',
                style: TextStyle(
                  color: Colors.red.shade200,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              '✅ Je savais : $_knew\n🤔 Presque : $_almost\n❌ Pas encore : $_forgot',
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              widget.ephemeral
                  ? 'Mode rapide : cartes non enregistrées dans ton paquet.'
                  : 'Progression enregistrée (répétition espacée).',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: EskoliaVisual.bgDeep,
        appBar: EskoliaAppBar.standard(context, title: 'Flashcards'),
        body: const Center(
          child: Text('Aucune carte', style: TextStyle(color: Colors.white54)),
        ),
      );
    }
    final c = _cards[_index];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Flashcards ${_index + 1}/${_cards.length}',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                8,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.timed || widget.survival) ...[
                    Row(
                      children: [
                        if (widget.survival)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _lives.clamp(0, 5),
                              (_) => const Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Text(
                                  '\u{2764}\u{FE0F}',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        if (widget.survival) const SizedBox(width: 10),
                        if (widget.timed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              '⏱ $_secondsLeft s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (widget.timed && _timedOut)
                          Text(
                            'Temps écoulé',
                            style: TextStyle(
                              color: Colors.red.shade200,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showBack = !_showBack),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        layoutBuilder: (current, prev) => Stack(
                          alignment: Alignment.center,
                          children: [
                            ...prev,
                            if (current != null) current,
                          ],
                        ),
                        child: Container(
                          key: ValueKey<bool>(_showBack),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: EskoliaVisual.neonViolet.withValues(
                                  alpha: 0.45),
                            ),
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showBack ? 'Verso' : 'Recto',
                                  style: TextStyle(
                                    color: EskoliaVisual.neonGreen
                                        .withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _showBack ? c.back : c.front,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Appuie pour retourner',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comment tu t’es senti ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _GradeButton(
                          label: 'Pas encore',
                          emoji: '\u{274C}',
                          color: const Color(0xFFEF4444),
                          onPressed: () => _onGrade(FlashcardGrade.forgot),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GradeButton(
                          label: 'Presque',
                          emoji: '\u{1F914}',
                          color: const Color(0xFFF59E0B),
                          onPressed: () => _onGrade(FlashcardGrade.almost),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GradeButton(
                          label: 'Je savais',
                          emoji: '\u{2705}',
                          color: EskoliaVisual.neonGreen,
                          onPressed: () => _onGrade(FlashcardGrade.knew),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.55)),
            color: color.withValues(alpha: 0.12),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color.withValues(alpha: 0.95),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
