import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/eskolia_tokens.dart';

class TextScaleNotifier extends Notifier<double> {
  static const String _prefKey = 'eskolia_text_scale_factor_v1';
  static const double defaultScale = 1.0;

  @override
  double build() {
    _loadFromPrefs();
    return defaultScale;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getDouble(_prefKey);
      if (val != null && val >= 0.80 && val <= 2.10) {
        state = val;
      }
    } catch (e) {
      debugPrint('[TextScaleNotifier] Error loading scale: $e');
    }
  }

  Future<void> setScale(double newScale) async {
    final clamped = newScale.clamp(0.85, 2.00);
    final rounded = (clamped * 100).round() / 100.0;
    state = rounded;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKey, state);
    } catch (e) {
      debugPrint('[TextScaleNotifier] Error saving scale: $e');
    }
  }

  Future<void> increase() async => setScale(state + 0.05);
  Future<void> decrease() async => setScale(state - 0.05);
  Future<void> reset() async => setScale(1.0);
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(TextScaleNotifier.new);

/// Ouvre une modale interactive pour ajuster la taille de police et le zoom de l'application
Future<void> showTextScaleDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return const _TextScaleDialog();
    },
  );
}

class _TextScaleDialog extends ConsumerWidget {
  const _TextScaleDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScale = ref.watch(textScaleProvider);
    final percentage = (currentScale * 100).round();

    final presets = [
      (scale: 0.90, label: '90%', desc: 'Compact'),
      (scale: 1.00, label: '100%', desc: 'Normal'),
      (scale: 1.15, label: '115%', desc: 'Confort'),
      (scale: 1.30, label: '130%', desc: 'Grand'),
      (scale: 1.50, label: '150%', desc: 'Très grand'),
      (scale: 1.75, label: '175%', desc: 'Maxi'),
      (scale: 2.00, label: '200%', desc: 'Ultra'),
    ];

    return AlertDialog(
      backgroundColor: EskoliaTokens.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: EskoliaTokens.cyan.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EskoliaTokens.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.zoom_in_rounded,
              color: EskoliaTokens.cyan,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zoom & Taille du texte',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'Ajuste la lisibilité sur votre écran',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aperçu dynamique
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EskoliaTokens.surface2.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aperçu en direct',
                          style: TextStyle(
                            color: EskoliaTokens.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: EskoliaTokens.cyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$percentage %',
                            style: const TextStyle(
                              color: EskoliaTokens.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Réseau, adressage IP, PowerShell & examens blancs.',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14 * currentScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ce texte s\'adapte en temps réel à l\'échelle sélectionnée.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12 * currentScale,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Slider avec boutons - / +
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white70),
                    tooltip: 'Diminuer (-5%)',
                    onPressed: () => ref.read(textScaleProvider.notifier).decrease(),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: EskoliaTokens.cyan,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: EskoliaTokens.cyan,
                        overlayColor: EskoliaTokens.cyan.withValues(alpha: 0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: currentScale,
                        min: 0.85,
                        max: 2.00,
                        divisions: 23,
                        label: '$percentage %',
                        onChanged: (val) {
                          ref.read(textScaleProvider.notifier).setScale(val);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: EskoliaTokens.cyan),
                    tooltip: 'Augmenter (+5%)',
                    onPressed: () => ref.read(textScaleProvider.notifier).increase(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Boutons de préréglages rapides
              const Text(
                'Préréglages rapides',
                style: TextStyle(
                  color: EskoliaTokens.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: presets.map((p) {
                  final isSelected = (currentScale - p.scale).abs() < 0.02;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => ref.read(textScaleProvider.notifier).setScale(p.scale),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? EskoliaTokens.cyan.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? EskoliaTokens.cyan : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            p.label,
                            style: TextStyle(
                              color: isSelected ? EskoliaTokens.cyan : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${p.desc})',
                            style: TextStyle(
                              color: isSelected ? EskoliaTokens.cyan.withValues(alpha: 0.8) : Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('100% (Défaut)'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white60,
          ),
          onPressed: () => ref.read(textScaleProvider.notifier).reset(),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: EskoliaTokens.cyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
