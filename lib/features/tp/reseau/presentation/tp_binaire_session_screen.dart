import 'package:flutter/material.dart';

import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_button.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../data/tp_binaire_data.dart';
import 'simple_calculator_sheet.dart';

const Color _slate  = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _green  = Color(0xFF4CAF50);
const Color _amber  = Color(0xFFFFC107);
const Color _red    = Color(0xFFE53935);
const Color _cyan   = Color(0xFF00BCD4);

Color _diffColor(TpDifficulty d) => switch (d) {
      TpDifficulty.facile    => _green,
      TpDifficulty.moyen     => _amber,
      TpDifficulty.difficile => _red,
    };

// ─── State per answer field ───────────────────────────────────────────────────

class _FieldState {
  _FieldState();
  final controller = TextEditingController();
  bool? correct; // null = not checked yet
  String? expected;

  void dispose() => controller.dispose();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class TpBinaireSessionScreen extends StatefulWidget {
  const TpBinaireSessionScreen({super.key, required this.tp});
  final TpBinaire tp;

  @override
  State<TpBinaireSessionScreen> createState() => _TpBinaireSessionScreenState();
}

class _TpBinaireSessionScreenState extends State<TpBinaireSessionScreen> {
  // fields[sectionIdx][questionIdx] = single or sub-question field
  late final List<List<List<_FieldState>>> _fields;

  bool _corrected = false;
  int _score = 0;
  late int _total;

  @override
  void initState() {
    super.initState();
    _fields = widget.tp.sections.map((sec) {
      return sec.questions.map((q) {
        if (q.subQuestions != null) {
          return q.subQuestions!.map((_) => _FieldState()).toList();
        }
        return [_FieldState()];
      }).toList();
    }).toList();
    _total = widget.tp.totalPoints;
  }

  @override
  void dispose() {
    for (final sec in _fields) {
      for (final qFields in sec) {
        for (final f in qFields) {
          f.dispose();
        }
      }
    }
    super.dispose();
  }

  // ── Answer normalization ──────────────────────────────────────────────────

  String _normalize(String s) {
    return s
        .trim()
        .toLowerCase()
        .replaceAll('–', '-') // en-dash
        .replaceAll('—', '-') // em-dash
        .replaceAll(RegExp(r'\s*-\s*'), '-')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isCorrect(String user, String expected) =>
      _normalize(user) == _normalize(expected);

  // ── Correct all ──────────────────────────────────────────────────────────

  void _correctAll() {
    int earned = 0;
    for (int s = 0; s < widget.tp.sections.length; s++) {
      final section = widget.tp.sections[s];
      for (int q = 0; q < section.questions.length; q++) {
        final question = section.questions[q];
        final qFields = _fields[s][q];
        if (question.subQuestions != null) {
          int subEarned = 0;
          for (int sq = 0; sq < question.subQuestions!.length; sq++) {
            final ok = _isCorrect(
                qFields[sq].controller.text, question.subQuestions![sq].answer);
            qFields[sq].correct = ok;
            qFields[sq].expected = question.subQuestions![sq].answer;
            if (ok) subEarned++;
          }
          earned += subEarned; // each sub-question = 1 pt toward total
        } else {
          final ok = _isCorrect(qFields[0].controller.text, question.answer);
          qFields[0].correct = ok;
          qFields[0].expected = question.answer;
          if (ok) earned += question.points;
        }
      }
    }
    setState(() {
      _corrected = true;
      _score = earned;
    });
  }

  void _reset() {
    for (final sec in _fields) {
      for (final qFields in sec) {
        for (final f in qFields) {
          f.controller.clear();
          f.correct = null;
          f.expected = null;
        }
      }
    }
    setState(() {
      _corrected = false;
      _score = 0;
    });
  }

  // ── Calculator ───────────────────────────────────────────────────────────

  void _openCalculator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SimpleCalculatorSheet(),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final diffColor = _diffColor(widget.tp.difficulty);

    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: widget.tp.title,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: diffColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              widget.tp.difficultyLabel,
              style: TextStyle(
                color: diffColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calculate_rounded, color: _cyan),
            tooltip: 'Calculatrice',
            onPressed: _openCalculator,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score bar
          if (_corrected) _buildScoreBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      for (int s = 0; s < widget.tp.sections.length; s++) ...[
                        _buildSection(s),
                        const SizedBox(height: 20),
                      ],
                      if (_corrected) _buildFinalMessage() else _buildCorrectButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_corrected
          ? null
          : FloatingActionButton.extended(
              onPressed: _reset,
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: _violet,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Recommencer'),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _violet.withValues(alpha: 0.4)),
              ),
            ),
    );
  }

  // ── Score bar ─────────────────────────────────────────────────────────────

  Widget _buildScoreBar() {
    final ratio = _total > 0 ? _score / _total : 0.0;
    final barColor = ratio >= 0.8 ? _green : ratio >= 0.6 ? _amber : _red;

    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: _amber, size: 16),
              const SizedBox(width: 6),
              Text(
                'Score : $_score / $_total points',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(ratio * 100).round()}%',
                style: TextStyle(
                  color: barColor, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Final message ─────────────────────────────────────────────────────────

  Widget _buildFinalMessage() {
    final ratio = _total > 0 ? _score / _total : 0.0;
    final msg = ratio >= 0.8
        ? 'Excellent !'
        : ratio >= 0.6
            ? 'Bien !'
            : 'Continue a t\'entrainer !';
    final color = ratio >= 0.8 ? _green : ratio >= 0.6 ? _amber : _red;

    return EskoliaCardContent(
      accentBorderColor: color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            ratio >= 0.8
                ? Icons.emoji_events_rounded
                : ratio >= 0.6
                    ? Icons.thumb_up_rounded
                    : Icons.school_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            msg,
            style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ── Correct button ────────────────────────────────────────────────────────

  Widget _buildCorrectButton() => EskoliaButton(
        label: 'Corriger tout',
        icon: Icons.check_circle_rounded,
        variant: EskoliaButtonVariant.primary,
        expand: true,
        onPressed: _correctAll,
      );

  // ── Section ───────────────────────────────────────────────────────────────

  Widget _buildSection(int sIdx) {
    final section = widget.tp.sections[sIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _violet, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                section.instruction,
                style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        EskoliaCardContent(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (int q = 0; q < section.questions.length; q++) ...[
                if (q > 0)
                  Divider(
                      color: Colors.white.withValues(alpha: 0.06), height: 16),
                _buildQuestion(sIdx, q, section.questions[q]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Question ──────────────────────────────────────────────────────────────

  Widget _buildQuestion(int sIdx, int qIdx, TpQuestion question) {
    if (question.subQuestions != null) {
      return _buildCompoundQuestion(sIdx, qIdx, question);
    }
    return _buildSimpleQuestion(sIdx, qIdx, question);
  }

  Widget _buildSimpleQuestion(int sIdx, int qIdx, TpQuestion question) {
    final field = _fields[sIdx][qIdx][0];
    final checked = _corrected && field.correct != null;
    final isOk = field.correct == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                question.prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _answerField(
                field: field,
                correct: checked ? isOk : null,
              ),
            ),
            if (checked)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  isOk ? Icons.check_rounded : Icons.close_rounded,
                  color: isOk ? _green : _red,
                  size: 18,
                ),
              ),
          ],
        ),
        if (checked && !isOk) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              'Reponse : ${field.expected}',
              style: const TextStyle(
                color: _amber,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompoundQuestion(int sIdx, int qIdx, TpQuestion question) {
    final subFields = _fields[sIdx][qIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.prompt,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        for (int sq = 0; sq < question.subQuestions!.length; sq++) ...[
          const SizedBox(height: 6),
          _buildSubQuestion(
            subQ:  question.subQuestions![sq],
            field: subFields[sq],
          ),
        ],
      ],
    );
  }

  Widget _buildSubQuestion({
    required TpSubQuestion subQ,
    required _FieldState field,
  }) {
    final checked = _corrected && field.correct != null;
    final isOk = field.correct == true;

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  subQ.label,
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _answerField(
                  field: field,
                  correct: checked ? isOk : null,
                ),
              ),
              if (checked)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    isOk ? Icons.check_rounded : Icons.close_rounded,
                    color: isOk ? _green : _red,
                    size: 16,
                  ),
                ),
            ],
          ),
          if (checked && !isOk) ...[
            const SizedBox(height: 3),
            Text(
              'Reponse : ${field.expected}',
              style: const TextStyle(
                color: _amber,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Answer input field ────────────────────────────────────────────────────

  Widget _answerField({required _FieldState field, required bool? correct}) {
    Color borderColor;
    if (correct == true) {
      borderColor = _green;
    } else if (correct == false) {
      borderColor = _red;
    } else {
      borderColor = Colors.white.withValues(alpha: 0.12);
    }

    return TextField(
      controller: field.controller,
      enabled: !_corrected,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontFamily: 'monospace',
      ),
      cursorColor: _cyan,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Colors.white.withValues(alpha: correct != null ? 0.03 : 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: correct != null ? borderColor : _cyan, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        hintText: '...',
        hintStyle: TextStyle(color: _slate.withValues(alpha: 0.3), fontSize: 13),
      ),
    );
  }
}
