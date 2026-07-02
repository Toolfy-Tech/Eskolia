import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../data/lexique_data.dart';
import '../../../../core/constants/eskolia_tokens.dart';

enum _Phase { intro, worksheet, corrected }

class _FieldState {
  final ctrl = TextEditingController();
  // null = pas encore auto-corrige, true = correct, false = faux
  bool? selfValidated;

  void dispose() => ctrl.dispose();
}

class LexiqueScreen extends StatefulWidget {
  const LexiqueScreen({
    super.key,
    this.startWithCount,
    this.startWithCategory,
  });

  final int? startWithCount;
  final String? startWithCategory;

  @override
  State<LexiqueScreen> createState() => _LexiqueScreenState();
}

class _LexiqueScreenState extends State<LexiqueScreen> {
  _Phase _phase = _Phase.intro;
  late int _count;
  List<LexiqueEntry> _entries = [];
  List<_FieldState> _fields = [];

  final _rng = Random();

  int get _validatedCount => _fields.where((f) => f.selfValidated != null).length;
  int get _correctCount   => _fields.where((f) => f.selfValidated == true).length;

  @override
  void initState() {
    super.initState();
    _count = widget.startWithCount ?? 15;
    if (widget.startWithCount != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _start();
      });
    }
  }

  @override
  void dispose() {
    for (final f in _fields) f.dispose();
    super.dispose();
  }

  void _start() {
    var all = allLexique.toList();
    if (widget.startWithCategory != null && widget.startWithCategory != 'all') {
      final keys = widget.startWithCategory!.split(',');
      all = all.where((e) => keys.contains(e.category)).toList();
    }
    all.shuffle(_rng);
    final selected = all.take(_count).toList();
    for (final f in _fields) f.dispose();
    setState(() {
      _entries = selected;
      _fields  = List.generate(selected.length, (_) => _FieldState());
      _phase   = _Phase.worksheet;
    });
  }

  void _showAnswers() {
    FocusScope.of(context).unfocus();
    setState(() => _phase = _Phase.corrected);
  }

  void _validate(int i, bool correct) {
    setState(() => _fields[i].selfValidated = correct);
  }

  void _restart() {
    setState(() => _phase = _Phase.intro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: _phase != _Phase.intro,
            child: switch (_phase) {
              _Phase.intro      => _buildIntro(),
              _Phase.worksheet  => _buildWorksheet(corrected: false),
              _Phase.corrected  => _buildWorksheet(corrected: true),
            },
          ),
        ],
      ),
      floatingActionButton: _phase == _Phase.intro ? null : FloatingActionButton.extended(
        backgroundColor: _phase == _Phase.corrected ? EskoliaTokens.violet : EskoliaTokens.success,
        foregroundColor: Colors.white,
        onPressed: _phase == _Phase.corrected ? _restart : _showAnswers,
        icon: Icon(_phase == _Phase.corrected
            ? Icons.replay_rounded
            : Icons.check_rounded),
        label: Text(
          _phase == _Phase.corrected ? 'Recommencer' : 'Voir les reponses',
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
                'Lexique TIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Un terme, un acronyme ou un concept du metier t\'est presente. '
                'Ecris ta definition, puis compare avec la correction et auto-evalue-toi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
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
            border: Border(left: BorderSide(color: EskoliaTokens.violet, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          child: const Text(
            'NOMBRE DE TERMES',
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
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
                          ? EskoliaTokens.violet.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? EskoliaTokens.violet.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          color: selected ? EskoliaTokens.violet : EskoliaTokens.textSecondary,
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
            border: Border(left: BorderSide(color: EskoliaTokens.textSecondary, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 12),
          child: const Text(
            'CATEGORIES COUVERTES',
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
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
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
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
              backgroundColor: EskoliaTokens.violet,
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
    final validated = _validatedCount;
    final correct   = _correctCount;
    final total     = _fields.length;
    final ratio     = validated > 0 ? correct / validated : 0.0;
    final color     = ratio >= 0.8 ? EskoliaTokens.success : ratio >= 0.6 ? EskoliaTokens.amber : EskoliaTokens.error;

    return Container(
      color: EskoliaVisual.bgElevated,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                validated < total
                    ? '$correct corrects · $validated / $total evalues'
                    : '$correct / $total corrects',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (validated > 0)
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
              value: validated > 0 ? correct / total : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(int i, {required bool corrected}) {
    final entry     = _entries[i];
    final field     = _fields[i];
    final validated = field.selfValidated;

    Color accentColor = Colors.transparent;
    if (corrected && validated == true)  accentColor = EskoliaTokens.success;
    if (corrected && validated == false) accentColor = EskoliaTokens.error;

    return EskoliaCardContent(
      accentBorderColor: corrected ? accentColor : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tete : terme + badge categorie
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.term,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _catBadge(entry.category),
              if (corrected && validated != null) ...[
                const SizedBox(width: 8),
                Icon(
                  validated ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: validated ? EskoliaTokens.success : EskoliaTokens.error,
                  size: 18,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Champ de saisie
          TextField(
            controller: field.ctrl,
            enabled: !corrected,
            maxLines: 2,
            minLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Ta definition...',
              hintStyle: TextStyle(
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.45),
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
                borderSide: const BorderSide(color: EskoliaTokens.violet, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
          ),
          // Correction ouverte : definition complete affichee apres "Voir les reponses"
          if (corrected) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: EskoliaTokens.violet.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: EskoliaTokens.violet.withValues(alpha: 0.5), width: 3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: EskoliaTokens.violet.withValues(alpha: 0.8), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.definition,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Auto-evaluation
            if (validated == null)
              Row(
                children: [
                  Expanded(
                    child: _ValidationButton(
                      label: 'J\'avais bon',
                      icon: Icons.check_rounded,
                      color: EskoliaTokens.success,
                      onTap: () => _validate(i, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ValidationButton(
                      label: 'J\'avais faux',
                      icon: Icons.close_rounded,
                      color: EskoliaTokens.error,
                      onTap: () => _validate(i, false),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(
                    validated ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: (validated ? EskoliaTokens.success : EskoliaTokens.error).withValues(alpha: 0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    validated ? 'Marque comme correct' : 'Marque comme faux',
                    style: TextStyle(
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _fields[i].selfValidated = null),
                    child: Text(
                      'Modifier',
                      style: TextStyle(
                        color: EskoliaTokens.violet.withValues(alpha: 0.7),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: EskoliaTokens.violet.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _catBadge(String cat) {
    final (label, color) = switch (cat) {
      'metier'   => ('Métier',       EskoliaTokens.amber),
      'reseau'   => ('Réseau',       EskoliaTokens.violet),
      'windows'  => ('Windows/AD',   EskoliaTokens.cyan),
      'securite' => ('Sécurité',     EskoliaTokens.error),
      _          => ('Matériel/OS',  EskoliaTokens.textSecondary),
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

// ── Bouton d'auto-evaluation ─────────────────────────────────────────────────

class _ValidationButton extends StatelessWidget {
  const _ValidationButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
