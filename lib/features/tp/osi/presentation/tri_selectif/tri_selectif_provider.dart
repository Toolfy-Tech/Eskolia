import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/osi_progress_repository.dart';
import '../../data/osi_tri_selectif_data.dart';
import '../../models/osi_card_item.dart';

enum TriGameMode {
  express(10, 'Série Express (10)', '10 cartes pour un entraînement rapide'),
  standard(20, 'Série Complète (20)', '20 cartes réparties sur les 7 couches'),
  sansFaute(-1, 'Défi Sans-Faute (Survie)', 'Objectif record : la moindre erreur arrête la partie !');

  const TriGameMode(this.cardCount, this.label, this.description);
  final int cardCount;
  final String label;
  final String description;
}

class TriMistake {
  const TriMistake({
    required this.card,
    required this.wrongLayer,
  });

  final OsiCardItem card;
  final int wrongLayer;
}

class TriSelectifState {
  const TriSelectifState({
    this.mode = TriGameMode.standard,
    this.targetCount = 20,
    this.score = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.currentCard,
    this.deck = const [],
    this.mistakes = const [],
    this.isGameOver = false,
    this.isPlaying = false,
    this.lastDropSuccess,
  });

  final TriGameMode mode;
  final int targetCount; // 10, 20 or -1 (sans-faute)
  final int score;
  final int streak;
  final int maxStreak;
  final int correctCount;
  final int totalAttempts;
  final OsiCardItem? currentCard;
  final List<OsiCardItem> deck;
  final List<TriMistake> mistakes;
  final bool isGameOver;
  final bool isPlaying;
  final bool? lastDropSuccess;

  double get accuracy => totalAttempts > 0 ? (correctCount / totalAttempts) * 100 : 0;
  int get remainingCards => targetCount > 0 ? (targetCount - totalAttempts).clamp(0, targetCount) : deck.length;

  TriSelectifState copyWith({
    TriGameMode? mode,
    int? targetCount,
    int? score,
    int? streak,
    int? maxStreak,
    int? correctCount,
    int? totalAttempts,
    OsiCardItem? currentCard,
    List<OsiCardItem>? deck,
    List<TriMistake>? mistakes,
    bool? isGameOver,
    bool? isPlaying,
    bool? lastDropSuccess,
  }) {
    return TriSelectifState(
      mode: mode ?? this.mode,
      targetCount: targetCount ?? this.targetCount,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      currentCard: currentCard ?? this.currentCard,
      deck: deck ?? this.deck,
      mistakes: mistakes ?? this.mistakes,
      isGameOver: isGameOver ?? this.isGameOver,
      isPlaying: isPlaying ?? this.isPlaying,
      lastDropSuccess: lastDropSuccess,
    );
  }
}

class TriSelectifNotifier extends Notifier<TriSelectifState> {
  @override
  TriSelectifState build() {
    return const TriSelectifState();
  }

  void startNewGame({TriGameMode? mode}) {
    final selectedMode = mode ?? state.mode;
    final count = selectedMode.cardCount;

    final shuffled = List<OsiCardItem>.from(OsiTriSelectifData.allCards)..shuffle();
    final deckCards = count > 0 ? shuffled.take(count).toList() : shuffled;

    final firstCard = deckCards.isNotEmpty ? deckCards.first : null;
    final remainingDeck = deckCards.length > 1 ? deckCards.sublist(1) : <OsiCardItem>[];

    state = TriSelectifState(
      mode: selectedMode,
      targetCount: count,
      score: 0,
      streak: 0,
      maxStreak: 0,
      correctCount: 0,
      totalAttempts: 0,
      currentCard: firstCard,
      deck: remainingDeck,
      mistakes: [],
      isGameOver: false,
      isPlaying: true,
    );
  }

  void dropCardOnLayer(int targetLayer) {
    if (!state.isPlaying || state.isGameOver || state.currentCard == null) return;

    final current = state.currentCard!;
    final isCorrect = current.targetLayer == targetLayer;

    final int newStreak = isCorrect ? state.streak + 1 : 0;
    final int newMaxStreak = newStreak > state.maxStreak ? newStreak : state.maxStreak;
    int pointsEarned = 0;

    if (isCorrect) {
      // Score de base + bonus multiplicateur combo
      final multiplier = newStreak >= 5 ? 3 : (newStreak >= 3 ? 2 : 1);
      pointsEarned = 20 * multiplier;
    }

    final newMistakes = List<TriMistake>.from(state.mistakes);
    if (!isCorrect) {
      newMistakes.add(TriMistake(card: current, wrongLayer: targetLayer));
    }

    final newTotalAttempts = state.totalAttempts + 1;
    final newCorrectCount = isCorrect ? state.correctCount + 1 : state.correctCount;
    final newScore = state.score + pointsEarned;

    // Condition de fin de partie :
    // 1) Mode Sans-Faute et première erreur
    if (state.mode == TriGameMode.sansFaute && !isCorrect) {
      state = state.copyWith(
        score: newScore,
        streak: newStreak,
        maxStreak: newMaxStreak,
        correctCount: newCorrectCount,
        totalAttempts: newTotalAttempts,
        mistakes: newMistakes,
        isGameOver: true,
        isPlaying: false,
        lastDropSuccess: false,
      );
      _saveScore();
      return;
    }

    // 2) Nombre cible atteint (10 ou 20)
    if (state.targetCount > 0 && newTotalAttempts >= state.targetCount) {
      state = state.copyWith(
        score: newScore,
        streak: newStreak,
        maxStreak: newMaxStreak,
        correctCount: newCorrectCount,
        totalAttempts: newTotalAttempts,
        mistakes: newMistakes,
        isGameOver: true,
        isPlaying: false,
        lastDropSuccess: isCorrect,
      );
      _saveScore();
      return;
    }

    // Tirage de la carte suivante
    OsiCardItem? nextCard;
    List<OsiCardItem> nextDeck = List<OsiCardItem>.from(state.deck);

    if (nextDeck.isNotEmpty) {
      nextCard = nextDeck.removeAt(0);
    } else {
      if (state.mode == TriGameMode.sansFaute) {
        // En mode sans faute infini, on recharge le deck
        nextDeck = List<OsiCardItem>.from(OsiTriSelectifData.allCards)..shuffle();
        nextCard = nextDeck.removeAt(0);
      } else {
        // Fin de série
        state = state.copyWith(
          score: newScore,
          streak: newStreak,
          maxStreak: newMaxStreak,
          correctCount: newCorrectCount,
          totalAttempts: newTotalAttempts,
          mistakes: newMistakes,
          isGameOver: true,
          isPlaying: false,
          lastDropSuccess: isCorrect,
        );
        _saveScore();
        return;
      }
    }

    state = state.copyWith(
      score: newScore,
      streak: newStreak,
      maxStreak: newMaxStreak,
      correctCount: newCorrectCount,
      totalAttempts: newTotalAttempts,
      currentCard: nextCard,
      deck: nextDeck,
      mistakes: newMistakes,
      lastDropSuccess: isCorrect,
    );
  }

  void _saveScore() {
    ref.read(osiStatsProvider.notifier).saveTriScore(state.score, state.maxStreak);
  }
}

final triSelectifProvider = NotifierProvider<TriSelectifNotifier, TriSelectifState>(
  TriSelectifNotifier.new,
);
