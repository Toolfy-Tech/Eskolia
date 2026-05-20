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

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: EskoliaVisual.bgDeep,
        appBar: EskoliaAppBar.standard(
          context,
          title: 'TPs Binaire & Adressage',
          bottom: TabBar(
            tabs: [
              _tab('Facile',    _green),
              _tab('Moyen',     _amber),
              _tab('Difficile', _red),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: _slate,
            indicatorColor: _violet,
            dividerColor: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: TabBarView(
                children: [
                  _TpList(difficulty: TpDifficulty.facile,    hPad: hPad),
                  _TpList(difficulty: TpDifficulty.moyen,     hPad: hPad),
                  _TpList(difficulty: TpDifficulty.difficile, hPad: hPad),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _tab(String label, Color color) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _TpList extends StatelessWidget {
  const _TpList({required this.difficulty, required this.hPad});
  final TpDifficulty difficulty;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final tps = tpsByDifficulty(difficulty);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 100),
      itemCount: tps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TpCard(tp: tps[i], index: i + 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
                    _badge(tp.difficultyLabel, color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalQ exercices · ${tp.totalPoints} points · 6 sections',
                  style: TextStyle(color: _slate.withValues(alpha: 0.75), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
}
