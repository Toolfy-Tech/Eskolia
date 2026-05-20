import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../data/lexique_data.dart';

const Color _slate  = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _green  = Color(0xFF43E97B);
const Color _red    = Color(0xFFEF4444);
const Color _amber  = Color(0xFFFFC107);

enum _Phase { intro, playing, done }

class LexiqueScreen extends StatefulWidget {
  const LexiqueScreen({super.key});

  @override
  State<LexiqueScreen> createState() => _LexiqueScreenState();
}

class _LexiqueScreenState extends State<LexiqueScreen> {
  static const _questionsPerRound = 20;
  static const _secondsPerQuestion = 10;

  _Phase _phase = _Phase.intro;
  List<LexiqueEntry> _questions = [];
  int _currentIndex = 0;
  List<LexiqueEntry> _options = [];
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;
  int _timeLeft = _secondsPerQuestion;
  Timer? _timer;

  final _rng = Random();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final all = allLexique.toList()..shuffle(_rng);
    setState(() {
      _questions = all.take(_questionsPerRound).toList();
      _currentIndex = 0;
      _score = 0;
      _phase = _Phase.playing;
    });
    _loadQuestion();
  }

  void _loadQuestion() {
    final correct = _questions[_currentIndex];
    final wrongPool = allLexique.where((e) => e.acronym != correct.acronym).toList()
      ..shuffle(_rng);
    final opts = [correct, ...wrongPool.take(3)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedOption = null;
      _answered = false;
      _timeLeft = _secondsPerQuestion;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 1) {
        setState(() => _timeLeft--);
      } else {
        _autoAdvance();
      }
    });
  }

  void _autoAdvance() {
    _timer?.cancel();
    if (!_answered) setState(() { _answered = true; _selectedOption = null; });
    Future.delayed(const Duration(milliseconds: 1300), _nextQuestion);
  }

  void _selectOption(int idx) {
    if (_answered) return;
    _timer?.cancel();
    final correct = _options[idx].acronym == _questions[_currentIndex].acronym;
    setState(() {
      _selectedOption = idx;
      _answered = true;
      if (correct) _score++;
    });
    Future.delayed(const Duration(milliseconds: 1300), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _phase = _Phase.done);
    } else {
      setState(() => _currentIndex++);
      _loadQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Lexique IT'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: switch (_phase) {
              _Phase.intro   => _buildIntro(),
              _Phase.playing => _buildGame(),
              _Phase.done    => _buildDone(),
            },
          ),
        ],
      ),
    );
  }

  // ─── Intro ────────────────────────────────────────────────────────────────

  Widget _buildIntro() {
    final hPad = EskoliaLayout.screenPaddingH;
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 100),
      children: [
        EskoliaCardHero(
          child: Column(
            children: [
              const Text('🔤', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Lexique IT',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Connais-tu tes acronymes IT ? Retrouve la bonne definition parmi 4 choix avant la fin du compte a rebours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statChip('📝 ${allLexique.length} termes',      _violet),
            _statChip('⏱ 10 s / question',                   _amber),
            _statChip('🎯 $_questionsPerRound questions',     _green),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _violet, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          child: const Text(
            'CATEGORIES',
            style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
          ),
        ),
        for (final cat in lexiqueCategories)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EskoliaCardContent(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(cat.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${cat.count} termes', style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _startGame,
            style: FilledButton.styleFrom(
              backgroundColor: _violet,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Commencer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  // ─── Game ─────────────────────────────────────────────────────────────────

  Widget _buildGame() {
    final question   = _questions[_currentIndex];
    final correctIdx = _options.indexWhere((e) => e.acronym == question.acronym);
    final progress   = (_currentIndex + 1) / _questions.length;
    final timerPct   = _timeLeft / _secondsPerQuestion;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_currentIndex + 1} / ${_questions.length}', style: const TextStyle(color: _slate, fontSize: 12)),
                  Text('Score : $_score', style: const TextStyle(color: _violet, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  color: _violet,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: timerPct,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  color: _timeLeft <= 3 ? _red : _amber,
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_timeLeft s',
                  style: TextStyle(
                    color: _timeLeft <= 3 ? _red : _slate,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: EskoliaCardHero(
            child: Column(
              children: [
                Text(
                  question.acronym,
                  style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
                const SizedBox(height: 4),
                Text(
                  question.category,
                  style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            itemCount: _options.length,
            itemBuilder: (_, idx) {
              final isSelected = _selectedOption == idx;
              final isCorrect  = idx == correctIdx;
              Color? borderColor;
              Color? bgColor;
              if (_answered) {
                if (isCorrect) {
                  borderColor = _green;
                  bgColor     = _green.withValues(alpha: 0.08);
                } else if (isSelected) {
                  borderColor = _red;
                  bgColor     = _red.withValues(alpha: 0.08);
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: _answered ? null : () => _selectOption(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgColor ?? const Color(0xFF1E1E38),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor ?? Colors.white.withValues(alpha: 0.10),
                        width: borderColor != null ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: (borderColor ?? _violet).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _answered && isCorrect
                                ? const Icon(Icons.check_rounded, color: _green, size: 16)
                                : _answered && isSelected
                                    ? const Icon(Icons.close_rounded, color: _red, size: 16)
                                    : Text(
                                        String.fromCharCode(65 + idx),
                                        style: TextStyle(
                                          color: borderColor ?? _violet,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _options[idx].definition,
                            style: TextStyle(
                              color: _answered && isCorrect
                                  ? _green
                                  : _answered && isSelected
                                      ? _red.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: _answered && isCorrect ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Done ─────────────────────────────────────────────────────────────────

  Widget _buildDone() {
    final hPad  = EskoliaLayout.screenPaddingH;
    final total = _questions.length;
    final pct   = _score / total;
    final (emoji, msg, color) = pct >= 0.8
        ? ('🏆', 'Excellent !', _green)
        : pct >= 0.6
            ? ('👍', 'Bon score !', _amber)
            : ('📚', 'Continue a t\'entrainer !', _red);

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 100),
      children: [
        EskoliaCardHero(
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(msg, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                '$_score / $total bonnes reponses',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${(pct * 100).round()} %',
                style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _startGame,
            style: FilledButton.styleFrom(
              backgroundColor: _violet,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Rejouer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}
