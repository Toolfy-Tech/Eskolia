import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/flashcard_deck_repository.dart';
import '../flashcard_session_screen.dart';

class FlashcardsDeckCardBody extends ConsumerStatefulWidget {
  const FlashcardsDeckCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<FlashcardsDeckCardBody> createState() => _FlashcardsDeckCardBodyState();
}

class _FlashcardsDeckCardBodyState extends ConsumerState<FlashcardsDeckCardBody> {
  final _deckRepo = FlashcardDeckRepository();
  int _dueCount = 0;
  bool _loading = true;

  // Options
  bool _timed = true;
  bool _survival = false;
  int _cardCount = 10;
  String _mode = 'quick'; // 'quick' (10 cartes), 'due' (cartes dues)
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadDueCount();
  }

  Future<void> _loadDueCount() async {
    try {
      final count = await _deckRepo.countDue();
      if (mounted) {
        setState(() {
          _dueCount = count;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _launchFlashcards() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      List<DeckFlashcard> cards;
      bool ephemeral = false;

      if (_mode == 'due') {
        cards = await _deckRepo.dueCards();
        if (cards.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune carte due aujourd\'hui. Lancez une série rapide !')),
            );
          }
          setState(() => _busy = false);
          return;
        }
      } else {
        cards = await _deckRepo.buildEphemeralQuickSet(
          count: _cardCount,
        );
        ephemeral = true;
      }

      if (!mounted) return;
      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: cards,
          ephemeral: ephemeral,
          timed: _timed,
          survival: _survival,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:flashcards_deck']?.isCollapsed ?? false);

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
          ),
        ),
      );
    }

    if (isCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: EskoliaTokens.cyan, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dueCount == 0
                        ? 'Aucune carte en attente de révision'
                        : _dueCount == 1
                            ? '1 carte due aujourd\'hui'
                            : '$_dueCount cartes dues aujourd\'hui',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/flashcards'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Ouvrir Hub', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _launchFlashcards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EskoliaTokens.cyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 14),
                  label: const Text('Réviser', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Extended Mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selection
        const Text('Mode de révision :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Série rapide', style: TextStyle(fontSize: 11)),
                selected: _mode == 'quick',
                onSelected: (val) => setState(() => _mode = 'quick'),
                selectedColor: EskoliaTokens.cyan.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: _mode == 'quick' ? Colors.white : Colors.white54, fontWeight: _mode == 'quick' ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Text('Dues aujourd\'hui ($_dueCount)', style: const TextStyle(fontSize: 11)),
                selected: _mode == 'due',
                onSelected: (val) => setState(() => _mode = 'due'),
                selectedColor: EskoliaTokens.cyan.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: _mode == 'due' ? Colors.white : Colors.white54, fontWeight: _mode == 'due' ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Settings Toggles
        Row(
          children: [
            Expanded(
              child: SwitchListTile.adaptive(
                title: const Text('Chronomètre', style: TextStyle(color: Colors.white70, fontSize: 11)),
                value: _timed,
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: EskoliaTokens.cyan,
                onChanged: (val) => setState(() => _timed = val),
              ),
            ),
            Expanded(
              child: SwitchListTile.adaptive(
                title: const Text('Mode Survie (3 vies)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                value: _survival,
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: EskoliaTokens.cyan,
                onChanged: (val) => setState(() => _survival = val),
              ),
            ),
          ],
        ),

        if (_mode == 'quick') ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nombre de cartes :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11)),
              Text('$_cardCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: EskoliaTokens.cyan,
              inactiveTrackColor: Colors.white12,
              thumbColor: EskoliaTokens.cyan,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: _cardCount.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              onChanged: (v) => setState(() => _cardCount = v.round()),
            ),
          ),
        ],

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/flashcards'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Ouvrir le Hub', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _launchFlashcards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: _busy
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Lancer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
