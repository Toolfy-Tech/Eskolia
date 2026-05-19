import 'package:flutter/material.dart';

import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_button.dart';
import '../data/network_exercise_engine.dart';
import 'network_calculator_sheet.dart';

const Color _bg     = Color(0xFF0B1120);
const Color _violet = Color(0xFF6C63FF);
const Color _cyan   = Color(0xFF00BCD4);
const Color _slate  = Color(0xFF94A3B8);
const Color _green  = Color(0xFF4CAF50);
const Color _red    = Color(0xFFE53935);

class ReseauSessionScreen extends StatefulWidget {
  const ReseauSessionScreen({super.key, required this.category});
  final NetworkExerciseCategory category;

  @override
  State<ReseauSessionScreen> createState() => _ReseauSessionScreenState();
}

class _ReseauSessionScreenState extends State<ReseauSessionScreen> {
  final _engine     = NetworkExerciseEngine();
  late NetworkExercise _current;
  final _controller = TextEditingController();

  int  _score       = 0;
  int  _total       = 0;
  bool _showResult  = false;
  bool? _lastCorrect;
  bool _sessionDone = false;

  // ------------------------------------------------------------------ lifecycle

  @override
  void initState() {
    super.initState();
    _current = _engine.generate(widget.category);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ helpers

  String _categoryLabel(NetworkExerciseCategory c) => switch (c) {
    NetworkExerciseCategory.binaryConversion => 'Conversion Binaire',
    NetworkExerciseCategory.ipClass         => 'Classes IP',
    NetworkExerciseCategory.defaultMask     => 'Masques par defaut',
    NetworkExerciseCategory.cidrNotation    => 'Notation CIDR',
    NetworkExerciseCategory.subnetCalc      => 'Calcul de sous-reseau',
  };

  void _validate() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;
    final correct = _engine.check(_current, answer);
    setState(() {
      if (correct) _score++;
      _total++;
      _lastCorrect = correct;
      _showResult  = true;
      if (_total == 10) _sessionDone = true;
    });
  }

  void _nextQuestion() {
    _controller.clear();
    setState(() {
      _current     = _engine.generate(widget.category);
      _showResult  = false;
      _lastCorrect = null;
    });
  }

  void _restart() {
    _controller.clear();
    setState(() {
      _score       = 0;
      _total       = 0;
      _showResult  = false;
      _lastCorrect = null;
      _sessionDone = false;
      _current     = _engine.generate(widget.category);
    });
  }

  void _openCalculator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NetworkCalculatorSheet(),
    );
  }

  // ------------------------------------------------------------------ score screen

  Widget _buildScoreScreen() {
    final msg = _score >= 8
        ? 'Excellent !'
        : _score >= 5
            ? 'Bien joue !'
            : 'Continue a t\'entrainer !';

    final scoreColor = _score >= 8
        ? _green
        : _score >= 5
            ? _cyan
            : _red;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    '$_score/10',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_score} bonne${_score > 1 ? 's' : ''} reponse${_score > 1 ? 's' : ''} sur 10',
                    style: TextStyle(color: _slate, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            EskoliaButton(
              label: 'Recommencer',
              expand: true,
              onPressed: _restart,
            ),
            const SizedBox(height: 12),
            EskoliaButton(
              label: 'Changer de categorie',
              variant: EskoliaButtonVariant.secondary,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ question card

  Widget _buildQuestionCard() {
    final isBinary = widget.category == NetworkExerciseCategory.binaryConversion;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        _current.question,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: isBinary ? 'monospace' : null,
          height: 1.45,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ input area

  Widget _buildInputArea() {
    final isBinary = widget.category == NetworkExerciseCategory.binaryConversion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isBinary ? 'monospace' : null,
          ),
          decoration: InputDecoration(
            hintText: isBinary ? 'Ex : 11000000' : 'Votre reponse...',
            hintStyle: TextStyle(color: _slate.withValues(alpha: 0.6)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _cyan, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (_) => _validate(),
        ),
        const SizedBox(height: 14),
        EskoliaButton(
          label: 'Valider',
          expand: true,
          icon: Icons.check_rounded,
          onPressed: _validate,
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ result card

  Widget _buildResultCard() {
    final isCorrect = _lastCorrect == true;
    final borderColor = isCorrect ? _green : _red;
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final title = isCorrect ? 'Bonne reponse !' : 'Incorrect';

    final isLastQuestion = _total == 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: borderColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: borderColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 10),
                Text(
                  'Bonne reponse : ${_current.correctAnswer}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              if (_current.explanation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _current.explanation,
                  style: TextStyle(color: _slate, fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        EskoliaButton(
          label: isLastQuestion ? 'Voir mon score' : 'Question suivante',
          expand: true,
          icon: isLastQuestion ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
          onPressed: isLastQuestion
              ? () => setState(() {})
              : _nextQuestion,
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(
        context,
        title: _categoryLabel(widget.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_rounded, color: _cyan),
            tooltip: 'Calculatrice reseau',
            onPressed: _openCalculator,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          _sessionDone
              ? SafeArea(child: _buildScoreScreen())
              : SafeArea(
                  child: Column(
                    children: [
                      // Progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _total / 10,
                                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                                  valueColor: const AlwaysStoppedAnimation<Color>(_violet),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Score badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, color: _violet, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_score / $_total',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildQuestionCard(),
                              const SizedBox(height: 16),
                              if (!_showResult) _buildInputArea(),
                              if (_showResult) _buildResultCard(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
