import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_button.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
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

class TpBinaireHubScreen extends StatelessWidget {
  const TpBinaireHubScreen({super.key});

  void _openCalculator(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SimpleCalculatorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: EskoliaVisual.bgDeep,
        appBar: EskoliaAppBar.standard(
          context,
          title: 'TPs Binaire & Adressage',
          actions: [
            IconButton(
              icon: const Icon(Icons.calculate_rounded, color: _cyan),
              tooltip: 'Calculatrice',
              onPressed: () => _openCalculator(context),
            ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            tabs: [
              _diffTab('Facile',    _green),
              _diffTab('Moyen',     _amber),
              _diffTab('Difficile', _red),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: _slate,
            indicatorColor: _violet,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.white.withValues(alpha: 0.06),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: TabBarView(
                children: [
                  _TpList(difficulty: TpDifficulty.facile),
                  _TpList(difficulty: TpDifficulty.moyen),
                  _TpList(difficulty: TpDifficulty.difficile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _diffTab(String label, Color color) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      );
}

// ─── Tab content ─────────────────────────────────────────────────────────────

class _TpList extends StatelessWidget {
  const _TpList({required this.difficulty});
  final TpDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final tps   = tpsByDifficulty(difficulty);
    final color = _diffColor(difficulty);
    final hPad  = EskoliaLayout.screenPaddingH;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 100),
      children: [
        // Intro banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(_diffIcon(difficulty), color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _diffDescription(difficulty),
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Section label
        Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(bottom: 14),
          child: Text(
            '${tps.length} TRAVAUX PRATIQUES · ${difficulty.name.toUpperCase()}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (int i = 0; i < tps.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _TpCard(tp: tps[i], index: i + 1),
        ],
      ],
    );
  }

  IconData _diffIcon(TpDifficulty d) => switch (d) {
        TpDifficulty.facile    => Icons.emoji_events_outlined,
        TpDifficulty.moyen     => Icons.bar_chart_rounded,
        TpDifficulty.difficile => Icons.bolt_rounded,
      };

  String _diffDescription(TpDifficulty d) => switch (d) {
        TpDifficulty.facile =>
            'Nombres ronds, classes A/B/C simples, masques /8 /16 /24. Ideal pour debuter.',
        TpDifficulty.moyen =>
            'Valeurs variees, masques /25 /26 /22 /28, classes mixtes. Pour consolider.',
        TpDifficulty.difficile =>
            'Valeurs complexes, masques /19 /21 /27 /29, subnetting non trivial. Pour les confirmés.',
      };
}

// ─── TP Card ─────────────────────────────────────────────────────────────────

class _TpCard extends StatelessWidget {
  const _TpCard({required this.tp, required this.index});
  final TpBinaire tp;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = _diffColor(tp.difficulty);
    final totalQ = tp.sections.fold(0, (s, sec) => s + sec.questions.length);

    return EskoliaCardContent(
      accentBorderColor: color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Index box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TP N°$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _badge('${tp.totalPoints} pts', color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalQ questions · 6 sections',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                // Section dots
                Wrap(
                  spacing: 6,
                  children: [
                    _sectionPill('Dec↔Bin',    _violet),
                    _sectionPill('IP+Classe',  _cyan),
                    _sectionPill('Masques',    _green),
                    _sectionPill('CIDR',       _amber),
                    _sectionPill('Subnetting', _red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Button
          EskoliaButton(
            label: 'Commencer',
            icon: Icons.play_arrow_rounded,
            variant: EskoliaButtonVariant.secondary,
            color: color,
            textColor: color,
            onPressed: () => context.push('/tp/binaire/${tp.id}'),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );

  Widget _sectionPill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
