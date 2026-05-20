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

enum _Phase { intro, worksheet, corrected }

class _FieldState {
  final ctrl = TextEditingController();
  bool? correct;

  void dispose() => ctrl.dispose();
}

class LexiqueScreen extends StatefulWidget {
  const LexiqueScreen({super.key});

  @override
  State<LexiqueScreen> createState() => _LexiqueScreenState();
}

class _LexiqueScreenState extends State<LexiqueScreen> {
  _Phase _phase = _Phase.intro;
  int _count = 15;
  List<LexiqueEntry> _entries = [];
  List<_FieldState> _fields = [];
  int _score = 0;

  final _rng = Random();

  @override
  void dispose() {
    for (final f in _fields) f.dispose();
    super.dispose();
  }

  void _start() {
    final all = allLexique.toList()..shuffle(_rng);
    final selected = all.take(_count).toList();
    for (final f in _fields) f.dispose();
    setState(() {
      _entries = selected;
      _fields  = List.generate(_count, (_) => _FieldState());
      _score   = 0;
      _phase   = _Phase.worksheet;
    });
  }

  void _correct() {
    var score = 0;
    for (int i = 0; i < _entries.length; i++) {
      final ok = _check(_fields[i].ctrl.text, _entries[i]);
      _fields[i].correct = ok;
      if (ok) score++;
    }
    setState(() {
      _score = score;
      _phase = _Phase.corrected;
    });
    FocusScope.of(context).unfocus();
  }

  void _restart() {
    setState(() => _phase = _Phase.intro);
  }

  // 65 % des mots-clés de l'expansion doivent être présents dans la réponse.
  bool _check(String answer, LexiqueEntry entry) {
    if (answer.trim().isEmpty) return false;
    final expansion = entry.definition.split(' — ').first.toLowerCase();
    final ansLow    = answer.toLowerCase();
    final expWords  = expansion
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();
    if (expWords.isEmpty) return false;
    final hits = expWords.where((w) => ansLow.contains(w)).length;
    return hits / expWords.length >= 0.65;
  }

  String _expansion(LexiqueEntry e) => e.definition.split(' — ').first;

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
              _Phase.intro      => _buildIntro(),
              _Phase.worksheet  => _buildWorksheet(corrected: false),
              _Phase.corrected  => _buildWorksheet(corrected: true),
            },
          ),
        ],
      ),
      floatingActionButton: _phase == _Phase.intro ? null : FloatingActionButton.extended(
        backgroundColor: _phase == _Phase.corrected ? _violet : _green,
        foregroundColor: Colors.white,
        onPressed: _phase == _Phase.corrected ? _restart : _correct,
        icon: Icon(_phase == _Phase.corrected
            ? Icons.replay_rounded
            : Icons.check_rounded),
        label: Text(
          _phase == _Phase.corrected ? 'Recommencer' : 'Corriger tout',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ─── Intro ────────────────────────────────────────────────────────────────

  Widget _buildIntro() {
    final hPad = EskoliaLayout.screenPaddingH;
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 120),
      children: [
        EskoliaCardHero(
          child: Column(
            children: [
              const Text('🔤', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Lexique IT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Une liste d\'acronymes t\'est presentee — ecris la signification de chacun, puis corrige.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _violet, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          child: const Text(
            'NOMBRE D\'ACRONYMES',
            style: TextStyle(
              color: _slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Row(
          children: [10, 15, 20].map((n) {
            final selected = _count == n;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: n != 20 ? 10 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _count = n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? _violet.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? _violet.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          color: selected ? _violet : _slate,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: _slate, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          child: const Text(
            'CATEGORIES COUVERTES',
            style: TextStyle(
              color: _slate,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
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
                  Text(
                    cat.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${cat.count} termes',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: _start,
            style: FilledButton.styleFrom(
              backgroundColor: _violet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Commencer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Worksheet / Corrected ────────────────────────────────────────────────

  Widget _buildWorksheet({required bool corrected}) {
    final hPad = EskoliaLayout.screenPaddingH;

    return Column(
      children: [
        // Score bar (visible après correction)
        if (corrected) _buildScoreBar(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
            itemCount: _entries.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEntry(i, corrected: corrected),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBar() {
    final ratio = _total > 0 ? _score / _total : 0.0;
    final color = ratio >= 0.8 ? _green : ratio >= 0.6 ? _amber : _red;
    return Container(
      color: EskoliaVisual.bgElevated,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_score / $_total corrects',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(ratio * 100).round()} %',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  int get _total => _fields.length;

  Widget _buildEntry(int i, {required bool corrected}) {
    final entry   = _entries[i];
    final field   = _fields[i];
    final correct = field.correct;

    Color borderColor = Colors.white.withValues(alpha: 0.10);
    if (corrected && correct == true)  borderColor = _green;
    if (corrected && correct == false) borderColor = _red;

    return EskoliaCardContent(
      accentBorderColor: corrected ? borderColor : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.acronym,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              _catBadge(entry.category),
              if (corrected) ...[
                const SizedBox(width: 8),
                Icon(
                  correct == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: correct == true ? _green : _red,
                  size: 18,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: field.ctrl,
            enabled: !corrected,
            maxLines: 2,
            minLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'Signification de ${entry.acronym}...',
              hintStyle: TextStyle(
                color: _slate.withValues(alpha: 0.45),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white.withValues(alpha: corrected ? 0.03 : 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _violet, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: corrected && correct == true
                      ? _green.withValues(alpha: 0.4)
                      : corrected
                          ? _red.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          // Réponse attendue si faux
          if (corrected && correct == false) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _amber.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: _amber.withValues(alpha: 0.6), width: 3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right_rounded, color: _amber, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _expansion(entry),
                      style: const TextStyle(
                        color: _amber,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _catBadge(String cat) {
    final (label, color) = switch (cat) {
      'reseau'   => ('Réseau',       _violet),
      'windows'  => ('Windows/AD',   const Color(0xFF00BCD4)),
      'securite' => ('Sécurité',     _red),
      _          => ('Matériel/OS',  _slate),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
