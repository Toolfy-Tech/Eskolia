import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OsiStats {
  const OsiStats({
    this.triHighScore = 0,
    this.triMaxStreak = 0,
    this.triGamesPlayed = 0,
    this.voyageEncapCompleted = false,
    this.voyageDecapCompleted = false,
    this.enqueteurCasesSolved = 0,
  });

  final int triHighScore;
  final int triMaxStreak;
  final int triGamesPlayed;
  final bool voyageEncapCompleted;
  final bool voyageDecapCompleted;
  final int enqueteurCasesSolved;

  int get globalMasteryPercent {
    int score = 0;
    // Tri Sélectif (jusqu'à 40%)
    if (triHighScore >= 500) {
      score += 40;
    } else if (triHighScore > 0) {
      score += (triHighScore / 500 * 40).round();
    }
    // Voyage du Paquet (30%)
    if (voyageEncapCompleted) score += 15;
    if (voyageDecapCompleted) score += 15;
    // Enquêteur OSI (30%)
    if (enqueteurCasesSolved >= 6) {
      score += 30;
    } else {
      score += (enqueteurCasesSolved / 6 * 30).round();
    }
    return score.clamp(0, 100);
  }

  OsiStats copyWith({
    int? triHighScore,
    int? triMaxStreak,
    int? triGamesPlayed,
    bool? voyageEncapCompleted,
    bool? voyageDecapCompleted,
    int? enqueteurCasesSolved,
  }) {
    return OsiStats(
      triHighScore: triHighScore ?? this.triHighScore,
      triMaxStreak: triMaxStreak ?? this.triMaxStreak,
      triGamesPlayed: triGamesPlayed ?? this.triGamesPlayed,
      voyageEncapCompleted: voyageEncapCompleted ?? this.voyageEncapCompleted,
      voyageDecapCompleted: voyageDecapCompleted ?? this.voyageDecapCompleted,
      enqueteurCasesSolved: enqueteurCasesSolved ?? this.enqueteurCasesSolved,
    );
  }
}

class OsiProgressRepository {
  static const _kTriHighScore = 'eskolia_osi_tri_high_score';
  static const _kTriMaxStreak = 'eskolia_osi_tri_max_streak';
  static const _kTriGamesPlayed = 'eskolia_osi_tri_games_played';
  static const _kVoyageEncap = 'eskolia_osi_voyage_encap';
  static const _kVoyageDecap = 'eskolia_osi_voyage_decap';
  static const _kEnqueteurSolved = 'eskolia_osi_enqueteur_solved';

  Future<OsiStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return OsiStats(
      triHighScore: prefs.getInt(_kTriHighScore) ?? 0,
      triMaxStreak: prefs.getInt(_kTriMaxStreak) ?? 0,
      triGamesPlayed: prefs.getInt(_kTriGamesPlayed) ?? 0,
      voyageEncapCompleted: prefs.getBool(_kVoyageEncap) ?? false,
      voyageDecapCompleted: prefs.getBool(_kVoyageDecap) ?? false,
      enqueteurCasesSolved: prefs.getInt(_kEnqueteurSolved) ?? 0,
    );
  }

  Future<void> recordTriScore({required int score, required int maxStreak}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = prefs.getInt(_kTriHighScore) ?? 0;
    if (score > currentHigh) {
      await prefs.setInt(_kTriHighScore, score);
    }
    final currentStreak = prefs.getInt(_kTriMaxStreak) ?? 0;
    if (maxStreak > currentStreak) {
      await prefs.setInt(_kTriMaxStreak, maxStreak);
    }
    final games = prefs.getInt(_kTriGamesPlayed) ?? 0;
    await prefs.setInt(_kTriGamesPlayed, games + 1);
  }

  Future<void> markVoyageCompleted({required bool isEncapsulation}) async {
    final prefs = await SharedPreferences.getInstance();
    if (isEncapsulation) {
      await prefs.setBool(_kVoyageEncap, true);
    } else {
      await prefs.setBool(_kVoyageDecap, true);
    }
  }

  Future<void> incrementEnqueteurSolved() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_kEnqueteurSolved) ?? 0;
    await prefs.setInt(_kEnqueteurSolved, count + 1);
  }
}

final osiProgressRepositoryProvider = Provider<OsiProgressRepository>((ref) {
  return OsiProgressRepository();
});

class OsiStatsNotifier extends AsyncNotifier<OsiStats> {
  @override
  Future<OsiStats> build() async {
    final repo = ref.watch(osiProgressRepositoryProvider);
    return repo.loadStats();
  }

  Future<void> saveTriScore(int score, int maxStreak) async {
    final repo = ref.read(osiProgressRepositoryProvider);
    await repo.recordTriScore(score: score, maxStreak: maxStreak);
    if (ref.mounted) {
      state = AsyncValue.data(await repo.loadStats());
    }
  }

  Future<void> markVoyageComplete(bool isEncapsulation) async {
    final repo = ref.read(osiProgressRepositoryProvider);
    await repo.markVoyageCompleted(isEncapsulation: isEncapsulation);
    if (ref.mounted) {
      state = AsyncValue.data(await repo.loadStats());
    }
  }

  Future<void> recordEnqueteurSolve() async {
    final repo = ref.read(osiProgressRepositoryProvider);
    await repo.incrementEnqueteurSolved();
    if (ref.mounted) {
      state = AsyncValue.data(await repo.loadStats());
    }
  }
}

final osiStatsProvider = AsyncNotifierProvider<OsiStatsNotifier, OsiStats>(
  OsiStatsNotifier.new,
);
