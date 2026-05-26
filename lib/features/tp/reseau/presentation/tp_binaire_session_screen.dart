import 'package:flutter/material.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_button.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../data/tp_binaire_data.dart';
import 'simple_calculator_sheet.dart';

const Color _slate  = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _cyan   = Color(0xFF00BCD4);
const Color _green  = Color(0xFF4CAF50);
const Color _amber  = Color(0xFFFFC107);
const Color _red    = Color(0xFFE53935);

Color _diffColor(TpDifficulty d) => switch (d) {
      TpDifficulty.facile    => _green,
      TpDifficulty.moyen     => _amber,
      TpDifficulty.difficile => _red,
    };

// ─── Per-field state ──────────────────────────────────────────────────────────

class _FieldState {
  _FieldState();
  final controller = TextEditingController();
  bool?   correct;
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
  // _fields[sectionIdx][questionIdx][subIdx]
  late final List<List<List<_FieldState>>> _fields;

  bool _corrected = false;
  int  _score     = 0;
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
      for (final qf in sec) {
        for (final f in qf) {
          f.dispose();
        }
      }
    }
    super.dispose();
  }

  // ── Normalise answers ─────────────────────────────────────────────────────

  String _normalizeAnswer(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('.', '')
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll('–', '')
      .replaceAll('—', '');

  // Keep alias so nothing else breaks if referenced elsewhere.
  String _norm(String s) => _normalizeAnswer(s);

  bool _ok(String user, String expected) => _norm(user) == _norm(expected);

  // ── Correct ───────────────────────────────────────────────────────────────

  void _correctAll() {
    int earned = 0;
    for (int s = 0; s < widget.tp.sections.length; s++) {
      final section = widget.tp.sections[s];
      for (int q = 0; q < section.questions.length; q++) {
        final question = section.questions[q];
        final qFields  = _fields[s][q];
        if (question.subQuestions != null) {
          for (int sq = 0; sq < question.subQuestions!.length; sq++) {
            final correct = _ok(
                qFields[sq].controller.text, question.subQuestions![sq].answer);
            qFields[sq].correct  = correct;
            qFields[sq].expected = question.subQuestions![sq].answer;
            if (correct) earned++;
          }
        } else {
          final correct = _ok(qFields[0].controller.text, question.answer);
          qFields[0].correct  = correct;
          qFields[0].expected = question.answer;
          if (correct) earned += question.points;
        }
      }
    }
    setState(() {
      _corrected = true;
      _score     = earned;
    });
  }

  void _reset() {
    for (final sec in _fields) {
      for (final qf in sec) {
        for (final f in qf) {
          f.controller.clear();
          f.correct  = null;
          f.expected = null;
        }
      }
    }
    setState(() { _corrected = false; _score = 0; });
  }

  // ── Calculator ────────────────────────────────────────────────────────────

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
    final hPad = EskoliaLayout.screenPaddingH;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: widget.tp.title,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          Column(
            children: [
              // Score bar — visible after correction
              if (_corrected) _buildScoreBar(),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: EskoliaLayout.shellContentMaxWidth,
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 120),
                        children: [
                          for (int s = 0; s < widget.tp.sections.length; s++)
                            if (widget.tp.sections[s].questions.isNotEmpty) ...[
                              _buildSection(s),
                              const SizedBox(height: 24),
                            ],
                          if (_corrected)
                            _buildFinalMessage()
                          else
                            _buildCorrectButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _corrected
          ? FloatingActionButton.extended(
              onPressed: _reset,
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: _violet,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Recommencer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: _violet.withValues(alpha: 0.4)),
              ),
            )
          : null,
    );
  }

  // ── Score bar ─────────────────────────────────────────────────────────────

  Widget _buildScoreBar() {
    final ratio      = _total > 0 ? _score / _total : 0.0;
    final barColor   = ratio >= 0.8 ? _green : ratio >= 0.6 ? _amber : _red;
    final hPad = EskoliaLayout.screenPaddingH;

    return Container(
      color: EskoliaVisual.bgElevated,
      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
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
    final ratio  = _total > 0 ? _score / _total : 0.0;
    final color  = ratio >= 0.8 ? _green : ratio >= 0.6 ? _amber : _red;
    final msg    = ratio >= 0.8
        ? 'Excellent !'
        : ratio >= 0.6
            ? 'Bien joue !'
            : 'Continue a t\'entrainer !';
    final icon   = ratio >= 0.8
        ? Icons.emoji_events_rounded
        : ratio >= 0.6
            ? Icons.thumb_up_rounded
            : Icons.school_rounded;

    return EskoliaCardContent(
      accentBorderColor: color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg,
                  style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_score points sur $_total',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.75), fontSize: 12),
                ),
              ],
            ),
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
        // Section header — same pattern as TpHubScreen
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
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        EskoliaCardContent(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (int q = 0; q < section.questions.length; q++) ...[
                if (q > 0)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.06),
                    height: 20,
                  ),
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
    return question.subQuestions != null
        ? _buildCompound(sIdx, qIdx, question)
        : _buildSimple(sIdx, qIdx, question);
  }

  Widget _buildSimple(int sIdx, int qIdx, TpQuestion q) {
    final field   = _fields[sIdx][qIdx][0];
    final checked = _corrected && field.correct != null;
    final isOk    = field.correct == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                q.prompt,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: _field(field: field, ok: checked ? isOk : null),
            ),
            const SizedBox(width: 6),
            _statusIcon(checked, isOk),
          ],
        ),
        if (checked && !isOk) _wrongHint(field.expected!),
      ],
    );
  }

  Widget _buildCompound(int sIdx, int qIdx, TpQuestion q) {
    final subFields = _fields[sIdx][qIdx];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main prompt
        Row(
          children: [
            const Icon(Icons.lan_outlined, color: _cyan, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                q.prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sub-questions
        for (int sq = 0; sq < q.subQuestions!.length; sq++) ...[
          if (sq > 0) const SizedBox(height: 6),
          _buildSubQ(q.subQuestions![sq], subFields[sq]),
        ],
      ],
    );
  }

  Widget _buildSubQ(TpSubQuestion subQ, _FieldState field) {
    final checked = _corrected && field.correct != null;
    final isOk    = field.correct == true;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 168,
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
                child: _field(field: field, ok: checked ? isOk : null),
              ),
              const SizedBox(width: 6),
              _statusIcon(checked, isOk),
            ],
          ),
          if (checked && !isOk) _wrongHint(field.expected!),
        ],
      ),
    );
  }

  // ── Shared field widgets ──────────────────────────────────────────────────

  Widget _field({required _FieldState field, required bool? ok}) {
    final Color border;
    final Color fill;
    if (ok == true) {
      border = _green.withValues(alpha: 0.6);
      fill   = _green.withValues(alpha: 0.05);
    } else if (ok == false) {
      border = _red.withValues(alpha: 0.6);
      fill   = _red.withValues(alpha: 0.04);
    } else {
      border = Colors.white.withValues(alpha: 0.12);
      fill   = Colors.white.withValues(alpha: 0.05);
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: ok != null ? border : _cyan.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        hintText: '...',
        hintStyle: TextStyle(
          color: _slate.withValues(alpha: 0.25),
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _statusIcon(bool checked, bool isOk) {
    if (!checked) return const SizedBox(width: 20);
    return Icon(
      isOk ? Icons.check_rounded : Icons.close_rounded,
      color: isOk ? _green : _red,
      size: 18,
    );
  }

  Widget _wrongHint(String expected) => Padding(
        padding: const EdgeInsets.only(top: 4, left: 2),
        child: Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: _amber, size: 14),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                expected,
                style: const TextStyle(
                  color: _amber,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}
