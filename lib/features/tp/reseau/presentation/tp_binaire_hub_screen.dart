import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_button.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../../../ai/data/ai_chat_service.dart';
import '../../../ai/data/ai_key_repository.dart';
import '../data/tp_binaire_ai_generator.dart';
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

class TpBinaireHubScreen extends StatefulWidget {
  const TpBinaireHubScreen({super.key});

  @override
  State<TpBinaireHubScreen> createState() => _TpBinaireHubScreenState();
}

class _TpBinaireHubScreenState extends State<TpBinaireHubScreen> {
  final _aiKeyRepo = AiKeyRepository();

  void _openCalculator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SimpleCalculatorSheet(),
    );
  }

  void _openAiSheet(AiConnectionState aiState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiGenerateSheet(aiState: aiState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AiConnectionState>(
      stream: _aiKeyRepo.watch(),
      builder: (context, snap) {
        final aiState = snap.data;
        final aiConnected = aiState?.isConnected == true;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: EskoliaVisual.bgDeep,
            appBar: EskoliaAppBar.standard(
              context,
              title: 'TPs Binaire & Adressage',
              actions: [
                if (aiConnected)
                  IconButton(
                    icon: const Icon(Icons.auto_awesome_rounded, color: _violet),
                    tooltip: 'Générer un TP avec l\'IA',
                    onPressed: () => _openAiSheet(aiState!),
                  ),
                IconButton(
                  icon: const Icon(Icons.calculate_rounded, color: _cyan),
                  tooltip: 'Calculatrice',
                  onPressed: _openCalculator,
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
                      _TpList(difficulty: TpDifficulty.facile,    aiState: aiState),
                      _TpList(difficulty: TpDifficulty.moyen,     aiState: aiState),
                      _TpList(difficulty: TpDifficulty.difficile, aiState: aiState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
  const _TpList({required this.difficulty, this.aiState});
  final TpDifficulty difficulty;
  final AiConnectionState? aiState;

  @override
  Widget build(BuildContext context) {
    final tps   = tpsByDifficulty(difficulty);
    final color = _diffColor(difficulty);
    final hPad  = EskoliaLayout.screenPaddingH;
    final aiConnected = aiState?.isConnected == true;

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
        const SizedBox(height: 12),
        // AI generate card (shown when AI connected)
        if (aiConnected) ...[
          _AiGenerateCard(difficulty: difficulty, aiState: aiState!),
          const SizedBox(height: 20),
        ] else
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
            'Valeurs complexes, masques /19 /21 /27 /29, subnetting non trivial. Pour les confirmes.',
      };
}

// ─── AI generate card (inline in tab) ────────────────────────────────────────

class _AiGenerateCard extends StatelessWidget {
  const _AiGenerateCard({required this.difficulty, required this.aiState});
  final TpDifficulty difficulty;
  final AiConnectionState aiState;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      accentBorderColor: _violet,
      padding: const EdgeInsets.all(14),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AiGenerateSheet(
          aiState: aiState,
          initialDifficulty: difficulty,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, color: _violet, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Générer un nouveau TP avec l\'IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Exercices uniques generés en temps réel',
                  style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}

// ─── AI Generate bottom sheet ─────────────────────────────────────────────────

class _AiGenerateSheet extends StatefulWidget {
  const _AiGenerateSheet({required this.aiState, this.initialDifficulty});
  final AiConnectionState aiState;
  final TpDifficulty? initialDifficulty;

  @override
  State<_AiGenerateSheet> createState() => _AiGenerateSheetState();
}

class _AiGenerateSheetState extends State<_AiGenerateSheet> {
  late TpDifficulty _selected;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDifficulty ?? TpDifficulty.facile;
  }

  Future<void> _generate() async {
    setState(() { _generating = true; _error = null; });
    try {
      final generator = TpBinaireAiGenerator(
        service: AiChatService(),
        state: widget.aiState,
      );
      final tp = await generator.generate(_selected);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push('/tp/binaire/live', extra: tp);
    } catch (e) {
      if (mounted) {
        setState(() { _generating = false; _error = e.toString(); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: EskoliaVisual.bgElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _violet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, color: _violet, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Générer un TP avec l\'IA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Exercices uniques, corrigés automatiquement',
                      style: TextStyle(color: _slate, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Difficulty label
            const Text(
              'DIFFICULTÉ',
              style: TextStyle(
                color: _slate,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            // Difficulty chips
            Row(
              children: TpDifficulty.values.map((d) {
                final color     = _diffColor(d);
                final isSelected = _selected == d;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: d != TpDifficulty.difficile ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: _generating ? null : () => setState(() => _selected = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.06),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _diffIcon(d),
                              color: isSelected ? color : _slate,
                              size: 18,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _diffLabel(d),
                              style: TextStyle(
                                color: isSelected ? color : _slate,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: _red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: _red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Generate button
            SizedBox(
              width: double.infinity,
              child: _generating
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _violet.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _violet.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _violet,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Génération en cours...',
                            style: TextStyle(
                              color: _violet,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : EskoliaButton(
                      label: 'Générer le TP',
                      icon: Icons.auto_awesome_rounded,
                      variant: EskoliaButtonVariant.primary,
                      color: _violet,
                      expand: true,
                      onPressed: _generate,
                    ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
          ],
        ),
      ),
    );
  }

  IconData _diffIcon(TpDifficulty d) => switch (d) {
        TpDifficulty.facile    => Icons.emoji_events_outlined,
        TpDifficulty.moyen     => Icons.bar_chart_rounded,
        TpDifficulty.difficile => Icons.bolt_rounded,
      };

  String _diffLabel(TpDifficulty d) => switch (d) {
        TpDifficulty.facile    => 'Facile',
        TpDifficulty.moyen     => 'Moyen',
        TpDifficulty.difficile => 'Difficile',
      };
}

// ─── TP Card ─────────────────────────────────────────────────────────────────

class _TpCard extends StatelessWidget {
  const _TpCard({required this.tp, required this.index});
  final TpBinaire tp;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color  = _diffColor(tp.difficulty);
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
                Wrap(
                  spacing: 6,
                  children: [
                    _sectionPill('Dec→Bin',    _violet),
                    _sectionPill('Bin→Dec',    _cyan),
                    _sectionPill('Classes IP', _green),
                    _sectionPill('Masques',    _amber),
                    _sectionPill('CIDR',       _red),
                    _sectionPill('Subnetting', _slate),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
