import 'package:flutter/material.dart';

// ── Niveaux de difficulte IA (4 niveaux) ─────────────────────────────────────

enum AiDifficulty { debutant, intermediaire, avance, expert }

extension AiDifficultyX on AiDifficulty {
  String get label => switch (this) {
        AiDifficulty.debutant      => 'Debutant',
        AiDifficulty.intermediaire => 'Intermediaire',
        AiDifficulty.avance        => 'Avance',
        AiDifficulty.expert        => 'Expert',
      };

  String get promptLabel => switch (this) {
        AiDifficulty.debutant      => 'Debutant (adresses privees simples, masques /8 /16 /24)',
        AiDifficulty.intermediaire => 'Intermediaire (valeurs variees, masques /25 /26 /22 /28)',
        AiDifficulty.avance        => 'Avance (masques /19 /21 /27 /29, subnetting non trivial)',
        AiDifficulty.expert        => 'Expert (VLSM, adressage complexe, scenarios reels d\'entreprise)',
      };

  Color get color => switch (this) {
        AiDifficulty.debutant      => const Color(0xFF4CAF50),
        AiDifficulty.intermediaire => const Color(0xFFFFC107),
        AiDifficulty.avance        => const Color(0xFFFF7043),
        AiDifficulty.expert        => const Color(0xFFE53935),
      };

  IconData get icon => switch (this) {
        AiDifficulty.debutant      => Icons.emoji_events_outlined,
        AiDifficulty.intermediaire => Icons.bar_chart_rounded,
        AiDifficulty.avance        => Icons.bolt_rounded,
        AiDifficulty.expert        => Icons.local_fire_department_rounded,
      };
}

// ── Couleurs locales ──────────────────────────────────────────────────────────

const Color _slate = Color(0xFF94A3B8);

// ── Widget reusable ───────────────────────────────────────────────────────────

/// Panneau de configuration universel pour la generation IA.
/// Gere la difficulte (4 niveaux) et le nombre de questions (1-20).
/// La page parente gere l'etat, ce widget est purement reactif.
class AiConfigWidget extends StatelessWidget {
  const AiConfigWidget({
    super.key,
    required this.difficulty,
    required this.questionCount,
    required this.onDifficultyChanged,
    required this.onCountChanged,
    this.enabled = true,
  });

  final AiDifficulty difficulty;
  final int questionCount;
  final ValueChanged<AiDifficulty> onDifficultyChanged;
  final ValueChanged<int> onCountChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Difficulte ────────────────────────────────────────────────────────
        const Text(
          'DIFFICULTE',
          style: TextStyle(
            color: _slate,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DiffChip(
              level: AiDifficulty.debutant,
              selected: difficulty,
              enabled: enabled,
              onTap: onDifficultyChanged,
            ),
            const SizedBox(width: 8),
            _DiffChip(
              level: AiDifficulty.intermediaire,
              selected: difficulty,
              enabled: enabled,
              onTap: onDifficultyChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _DiffChip(
              level: AiDifficulty.avance,
              selected: difficulty,
              enabled: enabled,
              onTap: onDifficultyChanged,
            ),
            const SizedBox(width: 8),
            _DiffChip(
              level: AiDifficulty.expert,
              selected: difficulty,
              enabled: enabled,
              onTap: onDifficultyChanged,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ── Nombre de questions ───────────────────────────────────────────────
        Row(
          children: [
            const Text(
              'NOMBRE DE QUESTIONS',
              style: TextStyle(
                color: _slate,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: difficulty.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: difficulty.color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$questionCount',
                style: TextStyle(
                  color: difficulty.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: difficulty.color,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
            thumbColor: difficulty.color,
            overlayColor: difficulty.color.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackHeight: 4,
          ),
          child: Slider(
            value: questionCount.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: enabled ? (v) => onCountChanged(v.round()) : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(color: _slate.withValues(alpha: 0.45), fontSize: 10)),
              Text('10', style: TextStyle(color: _slate.withValues(alpha: 0.45), fontSize: 10)),
              Text('20', style: TextStyle(color: _slate.withValues(alpha: 0.45), fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Chip de difficulte ────────────────────────────────────────────────────────

class _DiffChip extends StatelessWidget {
  const _DiffChip({
    required this.level,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final AiDifficulty level;
  final AiDifficulty selected;
  final bool enabled;
  final ValueChanged<AiDifficulty> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = level == selected;
    final color      = level.color;

    return Expanded(
      child: GestureDetector(
        onTap: enabled ? () => onTap(level) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.03),
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
              Icon(level.icon, color: isSelected ? color : _slate, size: 15),
              const SizedBox(height: 3),
              Text(
                level.label,
                style: TextStyle(
                  color: isSelected ? color : _slate,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
