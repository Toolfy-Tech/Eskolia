import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../solo/data/practical_missions_firestore_repository.dart';

const Color _slate = Color(0xFF94A3B8);
const Color _surface = Color(0xFF1A1A2E);

/// Mapping trackId → chemin asset JSON du scénario AD.
const Map<String, String> _kScenarioAssets = {
  'tp_ad_aerotech':    'assets/tp/AD/scenario_a_aerotech.json',
  'tp_ad_pixel':       'assets/tp/AD/scenario_b_pixel_academy.json',
  'tp_ad_saint_lazare':'assets/tp/AD/scenario_c_saint_lazare.json',
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
      final raw = await rootBundle.loadString(assetPath);
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
      backgroundColor: EskoliaVisual.bgDeep,
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
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
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
              style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () { setState(() { _loading = true; _errorMessage = null; }); _load(); },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
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
        if (isLoggedIn)
          FilledButton.icon(
            onPressed: () => context.push('/tp/${widget.trackId}/missions'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(completedCount == 0
                ? 'Commencer le parcours'
                : completedCount >= totalMissions
                    ? 'Revoir le parcours'
                    : 'Continuer — Mission ${completedCount + 1} / $totalMissions'),
          ),
        const SizedBox(height: 24),

        // ── Niveaux ──────────────────────────────────────────────
        const Text(
          'NIVEAUX',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
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
        color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.35)),
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
                Text('$done / $total missions', style: TextStyle(color: _slate, fontSize: 12)),
                Text(
                  done >= total ? 'Terminé ✓' : done == 0 ? 'Non commencé' : 'En cours',
                  style: TextStyle(
                    color: done >= total ? const Color(0xFF43E97B) : _slate,
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
                backgroundColor: Colors.white10,
                color: const Color(0xFF6C63FF),
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
    final levelColor = _hexColor(level['color'] as String? ?? '#6C63FF');

    return Container(
      decoration: BoxDecoration(
        color: _surface,
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

    return Opacity(
      opacity: isLocked ? 0.45 : 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // État icône
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: isCompleted
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B), size: 18)
                  : isCurrent
                      ? Icon(Icons.radio_button_checked_rounded, color: accentColor, size: 18)
                      : const Icon(Icons.lock_rounded, color: _slate, size: 16),
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
                      style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
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
