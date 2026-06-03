import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/services/asset_cache_service.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../solo/data/practical_missions_firestore_repository.dart';

/// Mapping trackId → chemin asset JSON du scénario (AD + PS).
const Map<String, String> _kScenarioAssets = {
  'tp_ad_aerotech':       'assets/tp/AD/scenario_a_aerotech.json',
  'tp_ad_pixel':          'assets/tp/AD/scenario_b_pixel_academy.json',
  'tp_ad_saint_lazare':   'assets/tp/AD/scenario_c_saint_lazare.json',
  'tp_ps_fondamentaux':   'assets/tp/PS/scenario_ps_fondamentaux.json',
  'tp_ps_systeme':        'assets/tp/PS/scenario_ps_systeme.json',
  'tp_ps_scripting':      'assets/tp/PS/scenario_ps_scripting.json',
  'tp_pt_fondamentaux':   'assets/tp/PT/scenario_pt_fondamentaux.json',
  'tp_pt_depannage_1':    'assets/tp/PT/scenario_pt_depannage_1.json',
  'tp_pt_vlans':          'assets/tp/PT/scenario_pt_vlans.json',
  'tp_pt_multisites':     'assets/tp/PT/scenario_pt_multisites.json',
};

class TpScenarioScreen extends StatefulWidget {
  const TpScenarioScreen({super.key, required this.trackId});
  final String trackId;

  @override
  State<TpScenarioScreen> createState() => _TpScenarioScreenState();
}

class _TpScenarioScreenState extends State<TpScenarioScreen> {
  final _progressRepo = PracticalMissionsFirestoreRepository();

  Map<String, dynamic>? _scenario;
  int _nextMissionIndex = 0;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final assetPath = _kScenarioAssets[widget.trackId];
    if (assetPath == null) {
      if (mounted) setState(() { _errorMessage = 'Scénario introuvable.'; _loading = false; });
      return;
    }
    try {
      final raw = await AssetCacheService.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final next = await _progressRepo.readNextMissionIndex(widget.trackId);
      if (!mounted) return;
      setState(() {
        _scenario = data;
        _nextMissionIndex = next;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _errorMessage = 'Impossible de charger le scénario.'; _loading = false; });
    }
  }

  /// Aplatit toutes les missions de tous les niveaux dans l'ordre.
  List<Map<String, dynamic>> _flatMissions(List<dynamic> levels) {
    final flat = <Map<String, dynamic>>[];
    for (final level in levels) {
      final missions = (level['missions'] as List<dynamic>?) ?? [];
      for (final m in missions) {
        flat.add(Map<String, dynamic>.from(m));
      }
    }
    return flat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: _scenario?['title'] as String? ?? 'Scénario TP',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: EskoliaTokens.violet))
                : _errorMessage != null
                    ? _buildError()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () { setState(() { _loading = true; _errorMessage = null; }); _load(); },
              style: FilledButton.styleFrom(backgroundColor: EskoliaTokens.violet),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final s = _scenario!;
    final levels = (s['levels'] as List<dynamic>?) ?? [];
    final flatMissions = _flatMissions(levels);
    final completedCount = _nextMissionIndex.clamp(0, flatMissions.length);
    final totalMissions = flatMissions.length;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isLoggedIn = uid != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // ── Header ──────────────────────────────────────────────
        _buildHeader(s, completedCount, totalMissions),
        const SizedBox(height: 20),

        // ── Context intro ────────────────────────────────────────
        if ((s['context_intro'] as String?)?.isNotEmpty == true) ...[
          EskoliaCardContent(
            padding: const EdgeInsets.all(16),
            child: Text(
              s['context_intro'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── CTA continuer ────────────────────────────────────────
        if (isLoggedIn && flatMissions.isNotEmpty)
          FilledButton.icon(
            onPressed: () {
              final idx = completedCount.clamp(0, flatMissions.length - 1);
              _showMissionDetail(flatMissions[idx], idx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: EskoliaTokens.violet,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(completedCount == 0
                ? 'Commencer le parcours'
                : completedCount >= totalMissions
                    ? 'Revoir — Mission 1'
                    : 'Continuer — Mission ${completedCount + 1} / $totalMissions'),
          ),
        const SizedBox(height: 24),

        // ── Niveaux ──────────────────────────────────────────────
        const Text(
          'NIVEAUX',
          style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),

        // Compteur plat pour les états
        Builder(builder: (context) {
          int flatIndex = 0;
          return Column(
            children: [
              for (int li = 0; li < levels.length; li++) ...[
                _buildLevelCard(
                  level: Map<String, dynamic>.from(levels[li]),
                  flatIndexStart: flatIndex,
                  nextMissionIndex: _nextMissionIndex,
                  totalFlatMissions: totalMissions,
                ),
                const SizedBox(height: 12),
                // Avance flatIndex
                () {
                  final missions = (levels[li]['missions'] as List<dynamic>?) ?? [];
                  flatIndex += missions.length;
                  return const SizedBox.shrink();
                }(),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> s, int done, int total) {
    final difficulty = s['difficulty_label'] as String? ?? s['difficulty'] as String? ?? '';
    final hours = s['estimated_hours'] as String? ?? '';
    final emoji = s['emoji'] as String? ?? '🖥️';
    final diffColor = _difficultyColor(s['difficulty'] as String? ?? '');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EskoliaTokens.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EskoliaTokens.violet.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title'] as String? ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _badge(difficulty, diffColor),
                        if (hours.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _badge('⏱ $hours', _slate),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$done / $total missions', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12)),
                Text(
                  done >= total ? 'Terminé ✓' : done == 0 ? 'Non commencé' : 'En cours',
                  style: TextStyle(
                    color: done >= total ? const Color(0xFF43E97B) : EskoliaTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? done / total : 0,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
                color: EskoliaTokens.violet,
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required Map<String, dynamic> level,
    required int flatIndexStart,
    required int nextMissionIndex,
    required int totalFlatMissions,
  }) {
    final missions = (level['missions'] as List<dynamic>?) ?? [];
    final levelColor = _hexColor(level['color'] as String? ?? '#7C6FFF');

    return Container(
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(width: 3, height: 18, decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text(
                  level['emoji'] as String? ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    level['title'] as String? ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Missions
          for (int mi = 0; mi < missions.length; mi++)
            _buildMissionTile(
              mission: Map<String, dynamic>.from(missions[mi]),
              flatIndex: flatIndexStart + mi,
              nextMissionIndex: nextMissionIndex,
              accentColor: levelColor,
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMissionTile({
    required Map<String, dynamic> mission,
    required int flatIndex,
    required int nextMissionIndex,
    required Color accentColor,
  }) {
    final isCompleted = flatIndex < nextMissionIndex;
    final isCurrent = flatIndex == nextMissionIndex;
    final isLocked = flatIndex > nextMissionIndex;
    final minutes = mission['estimated_minutes'] as int? ?? 0;
    final tappable = !isLocked;

    return Opacity(
      opacity: isLocked ? 0.45 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: tappable ? () => _showMissionDetail(mission, flatIndex) : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: isCompleted
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B), size: 18)
                    : isCurrent
                        ? Icon(Icons.radio_button_checked_rounded, color: accentColor, size: 18)
                        : const Icon(Icons.lock_rounded, color: EskoliaTokens.textSecondary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'] as String? ?? '',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.white.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    if (minutes > 0)
                      Text(
                        '$minutes min',
                        style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.8), fontSize: 11),
                      ),
                  ],
                ),
              ),
              if (tappable)
                Icon(Icons.chevron_right_rounded, color: EskoliaTokens.textSecondary.withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetail(Map<String, dynamic> mission, int flatIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MissionDetailSheet(
        mission: mission,
        flatIndex: flatIndex,
        trackId: widget.trackId,
        onComplete: () async {
          await _progressRepo.setNextMissionIndex(widget.trackId, flatIndex + 1);
          if (mounted) {
            setState(() => _nextMissionIndex = flatIndex + 1);
          }
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'debutant': return const Color(0xFF43E97B);
      case 'intermediaire': return const Color(0xFFEF9F27);
      case 'avance': return const Color(0xFFEF4444);
      default: return _slate;
    }
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }
}

class _MissionDetailSheet extends StatefulWidget {
  const _MissionDetailSheet({
    required this.mission,
    required this.flatIndex,
    required this.trackId,
    required this.onComplete,
  });

  final Map<String, dynamic> mission;
  final int flatIndex;
  final String trackId;
  final VoidCallback onComplete;

  @override
  State<_MissionDetailSheet> createState() => _MissionDetailSheetState();
}

class _MissionDetailSheetState extends State<_MissionDetailSheet> {
  final Map<String, bool> _expanded = {
    'context':  false,
    'steps':    false,
    'expected': false,
    'help':     false,
    'commands': false,
  };

  final _answerController = TextEditingController();
  int? _selectedChoice;
  bool _validationPassed = false;
  bool _validationWrong = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _validation {
    final v = widget.mission['validation'];
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  void _checkAnswer() {
    final v = _validation;
    if (v == null) return;
    final type = v['type'] as String? ?? 'text';
    final expected = (v['expected_answer'] as String? ?? '').trim().toLowerCase();

    bool passed = false;
    if (type == 'qcm') {
      final choices = v['choices'];
      if (choices is List && _selectedChoice != null) {
        final chosen = (choices[_selectedChoice!] as String).trim().toLowerCase();
        passed = chosen == expected;
      }
    } else {
      passed = _answerController.text.trim().toLowerCase() == expected;
    }
    setState(() {
      _validationPassed = passed;
      _validationWrong = !passed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mission['title'] as String? ?? '';
    final objective = widget.mission['objective'] as String? ?? '';
    final missionContext = widget.mission['context'] as String? ?? '';
    final steps = (widget.mission['steps'] as List<dynamic>?)?.cast<String>() ?? [];
    final expected = (widget.mission['expected_result'] as List<dynamic>?)?.cast<String>() ?? [];
    final helpMap = widget.mission['help'] as Map<String, dynamic>?;
    final minutes = widget.mission['estimated_minutes'] as int? ?? 0;
    final rawCommands = widget.mission['ios_commands'];
    final iosCommands = rawCommands is List ? rawCommands : <dynamic>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: EskoliaTokens.surface1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Poignée
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mission ${widget.flatIndex + 1}',
                            style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          if (minutes > 0)
                            Text('⏱ $minutes min', style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: EskoliaTokens.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.12), height: 24),
              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    if (objective.isNotEmpty) ...[
                      _sectionTitle('🎯 Objectif'),
                      const SizedBox(height: 8),
                      _card(Text(objective, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5))),
                      const SizedBox(height: 16),
                    ],
                    if (missionContext.isNotEmpty) ...[
                      _collapsibleSection(
                        key: 'context',
                        title: '📖 Contexte',
                        child: _card(Text(missionContext, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5))),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (steps.isNotEmpty) ...[
                      _collapsibleSection(
                        key: 'steps',
                        title: '📋 Étapes à réaliser',
                        child: _card(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: steps.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(top: 1, right: 10),
                                  decoration: BoxDecoration(
                                    color: EskoliaTokens.violet.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: EskoliaTokens.violet.withValues(alpha: 0.5)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('${e.key + 1}', style: const TextStyle(color: EskoliaTokens.violet, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )).toList(),
                        )),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (expected.isNotEmpty) ...[
                      _collapsibleSection(
                        key: 'expected',
                        title: '✅ Résultat attendu',
                        child: _card(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: expected.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: Color(0xFF43E97B), fontWeight: FontWeight.bold)),
                                Expanded(child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
                              ],
                            ),
                          )).toList(),
                        )),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (iosCommands.isNotEmpty) ...[
                      _collapsibleSection(
                        key: 'commands',
                        title: '\u{1F4BB} Commandes Cisco IOS',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final block in iosCommands)
                              if (block is Map) ...[
                                _iosCommandBlock(block),
                                const SizedBox(height: 8),
                              ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (helpMap != null) ...[
                      _collapsibleSection(
                        key: 'help',
                        title: '💡 Aide',
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: EskoliaTokens.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: EskoliaTokens.amber.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(helpMap['text'] as String? ?? '', style: const TextStyle(color: EskoliaTokens.amber, fontSize: 13, fontWeight: FontWeight.w600)),
                              if ((helpMap['where'] as String?)?.isNotEmpty == true) ...[
                                const SizedBox(height: 6),
                                Text(helpMap['where'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.4)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_validation != null) ...[
                      _buildValidationSection(_validation!),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.icon(
                      onPressed: (_validation == null || _validationPassed) ? widget.onComplete : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF43E97B),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFF43E97B).withValues(alpha: 0.25),
                        disabledForegroundColor: Colors.white30,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Mission terminée', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iosCommandBlock(Map block) {
    final device = block['device'] as String? ?? '';
    final label = block['label'] as String? ?? '';
    final rawCmds = block['commands'];
    final commands = rawCmds is List ? rawCmds.map((c) => c.toString()).toList() : <String>[];

    return Container(
      decoration: BoxDecoration(
        color: EskoliaTokens.bgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Text('\u{1F4BB}', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  device.isNotEmpty ? device : label,
                  style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.w600),
                ),
                if (device.isNotEmpty && label.isNotEmpty) ...[
                  const Text(' — ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  Expanded(
                    child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: commands.map((cmd) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  cmd,
                  style: const TextStyle(
                    color: Color(0xFF4ADE80),
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSection(Map<String, dynamic> v) {
    final type = v['type'] as String? ?? 'text';
    final question = v['question'] as String? ?? '';
    final hint = v['hint'] as String?;
    final rawChoices = v['choices'];
    final choices = rawChoices is List ? rawChoices.map((c) => c.toString()).toList() : <String>[];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _validationPassed
            ? const Color(0xFF43E97B).withValues(alpha: 0.08)
            : _validationWrong
                ? EskoliaTokens.error.withValues(alpha: 0.08)
                : EskoliaTokens.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _validationPassed
              ? const Color(0xFF43E97B).withValues(alpha: 0.4)
              : _validationWrong
                  ? EskoliaTokens.error.withValues(alpha: 0.4)
                  : EskoliaTokens.violet.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _validationPassed ? '\u{2705}' : '\u{1F9E0}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Question de validation',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(question, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          if (type == 'qcm') ...[
            for (int i = 0; i < choices.length; i++)
              _choiceTile(i, choices[i]),
          ] else ...[
            TextField(
              controller: _answerController,
              enabled: !_validationPassed,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Ta réponse...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: EskoliaTokens.violet),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
          if (_validationWrong && hint != null) ...[
            const SizedBox(height: 8),
            Text(
              '\u{1F4A1} $hint',
              style: TextStyle(color: EskoliaTokens.amber.withValues(alpha: 0.9), fontSize: 12, height: 1.4),
            ),
          ],
          if (_validationPassed) ...[
            const SizedBox(height: 8),
            const Text(
              'Bonne réponse ! Tu peux valider la mission.',
              style: TextStyle(color: Color(0xFF43E97B), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.violet.withValues(alpha: 0.2),
                  foregroundColor: EskoliaTokens.violet,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: EskoliaTokens.violet.withValues(alpha: 0.5)),
                  ),
                ),
                child: const Text('Valider ma réponse', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _choiceTile(int index, String label) {
    final isSelected = _selectedChoice == index;
    return GestureDetector(
      onTap: _validationPassed ? null : () => setState(() {
        _selectedChoice = index;
        _validationWrong = false;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? EskoliaTokens.violet.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? EskoliaTokens.violet.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? EskoliaTokens.violet : Colors.white30,
                  width: 2,
                ),
                color: isSelected ? EskoliaTokens.violet : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collapsibleSection({required String key, required String title, required Widget child}) {
    final isExpanded = _expanded[key] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded[key] = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: _sectionTitle(title)),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: EskoliaTokens.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: child,
  );
}
