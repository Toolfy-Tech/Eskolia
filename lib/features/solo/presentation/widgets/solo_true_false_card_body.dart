import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/eskolia_tokens.dart';

class SoloTrueFalseCardBody extends StatefulWidget {
  const SoloTrueFalseCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  State<SoloTrueFalseCardBody> createState() => _SoloTrueFalseCardBodyState();
}

class _SoloTrueFalseCardBodyState extends State<SoloTrueFalseCardBody> {
  int _bestStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('true_false_best_streak') ?? 0;
    if (mounted) {
      setState(() {
        _bestStreak = best;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.isExpandedOverride ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meilleure série',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
              ),
              _loading
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: EskoliaTokens.cyan))
                  : Text(
                      '$_bestStreak 🔥',
                      style: const TextStyle(color: EskoliaTokens.cyan, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 10),
          const Text(
            'Répondez par Vrai ou Faux en swipant les cartes. Idéal pour tester ses réflexes sur des notions rapides.',
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.push('/true-false').then((_) => _loadHighScore()),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.cyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: const Text('Lancer Express', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
