import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quiz_repository.dart';
import '../services/lacunes_repository.dart';

class QuizState {
  final QuizSession? session;
  final bool isLoading;
  final Object? error;
  final bool isFlipped;
  final bool isValidated;
  final int secondsLeft;
  final bool isTimedOut;
  final int lives;
  final int revealedIndicesCount;
  final List<bool> ticketChecks;

  QuizState({
    this.session,
    this.isLoading = false,
    this.error,
    this.isFlipped = false,
    this.isValidated = false,
    this.secondsLeft = 30,
    this.isTimedOut = false,
    this.lives = 3,
    this.revealedIndicesCount = 0,
    this.ticketChecks = const [],
  });

  QuizState copyWith({
    QuizSession? session,
    bool? isLoading,
    Object? error,
    bool? isFlipped,
    bool? isValidated,
    int? secondsLeft,
    bool? isTimedOut,
    int? lives,
    int? revealedIndicesCount,
    List<bool>? ticketChecks,
  }) {
    return QuizState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFlipped: isFlipped ?? this.isFlipped,
      isValidated: isValidated ?? this.isValidated,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isTimedOut: isTimedOut ?? this.isTimedOut,
      lives: lives ?? this.lives,
      revealedIndicesCount: revealedIndicesCount ?? this.revealedIndicesCount,
      ticketChecks: ticketChecks ?? this.ticketChecks,
    );
  }
}

// In Riverpod 3.x, extend Notifier. Auto-dispose is handled by the provider.
class QuizNotifier extends Notifier<QuizState> {
  QuizNotifier(this.arg);
  final String arg;

  late QuizRepository _repo;
  late LacunesRepository _lacunesRepo;
  Timer? _timer;

  @override
  QuizState build() {
    _repo = ref.watch(quizRepositoryProvider);
    _lacunesRepo = ref.watch(lacunesRepositoryProvider);
    ref.onDispose(() {
      _timer?.cancel();
    });
    return QuizState();
  }

  Future<void> initSession(String sessionId, {QuizSession? initialSession}) async {
    if (initialSession != null) {
      _setupSession(initialSession);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repo.loadSession(sessionId);
      _setupSession(session);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void _setupSession(QuizSession session) {
    state = QuizState(
      session: session,
      lives: session.runMode == QuizRunMode.survival ? 3 : 0,
    );
    _initQuestionSpecifics();
    _startTimer();
  }

  void _initQuestionSpecifics() {
    final s = state.session;
    if (s == null) return;
    if (s.currentIndex < 0 || s.currentIndex >= s.questions.length) return;
    final q = s.questions[s.currentIndex];
    
    state = state.copyWith(
      revealedIndicesCount: 0,
      ticketChecks: (q.type == 'ticket' && q.checklist != null)
          ? List.filled(q.checklist!.length, false)
          : [],
    );
  }

  void _startTimer() {
    _timer?.cancel();
    final s = state.session;
    if (s == null || !s.timed) return;

    state = state.copyWith(secondsLeft: 30, isTimedOut: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.isFlipped || state.isValidated) {
        t.cancel();
        return;
      }
      if (state.secondsLeft <= 1) {
        t.cancel();
        onTimeUp();
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  void onTimeUp() {
    if (state.isFlipped) return;
    state = state.copyWith(isFlipped: true, isTimedOut: true);
  }

  void reveal() {
    if (state.isFlipped) return;
    _timer?.cancel();
    state = state.copyWith(isFlipped: true, isTimedOut: false);
  }

  Future<void> revealAndScoreSequence(List<String> userOrder, List<String> correctOrder) async {
    if (state.isFlipped) return;
    _timer?.cancel();

    int correctCount = 0;
    for (int i = 0; i < correctOrder.length && i < userOrder.length; i++) {
      if (userOrder[i] == correctOrder[i]) correctCount++;
    }
    final score = correctOrder.isEmpty ? 0.0 : correctCount / correctOrder.length;

    final s = state.session!;
    final idx = s.currentIndex;
    final q = s.questions[idx];
    final scores = List<double?>.from(s.userScores);
    scores[idx] = score;

    state = state.copyWith(
      session: s.copyWith(userScores: scores),
      isFlipped: true,
      isValidated: true,
      isTimedOut: false,
    );

    if (score >= 0.5) {
      await _lacunesRepo.removeIfCorrect(q);
    } else {
      await _lacunesRepo.addWrong(q);
    }
  }

  Future<void> revealAndScoreAssociation(Map<String, String> userPairings, List<List<String>> correctPairs) async {
    if (state.isFlipped) return;
    _timer?.cancel();

    int correctCount = 0;
    for (final pair in correctPairs) {
      if (pair.length >= 2 && userPairings[pair[0]] == pair[1]) correctCount++;
    }
    final score = correctPairs.isEmpty ? 0.0 : correctCount / correctPairs.length;

    final s = state.session!;
    final idx = s.currentIndex;
    final q = s.questions[idx];
    final scores = List<double?>.from(s.userScores);
    scores[idx] = score;

    state = state.copyWith(
      session: s.copyWith(userScores: scores),
      isFlipped: true,
      isValidated: true,
      isTimedOut: false,
    );

    if (score >= 0.5) {
      await _lacunesRepo.removeIfCorrect(q);
    } else {
      await _lacunesRepo.addWrong(q);
    }
  }

  void toggleTicketCheck(int index) {
    if (state.isValidated) return;
    final newChecks = List<bool>.from(state.ticketChecks);
    newChecks[index] = !newChecks[index];
    state = state.copyWith(ticketChecks: newChecks);
  }

  void incrementIndices() {
    final q = state.session?.questions[state.session!.currentIndex];
    if (q?.indices == null) return;
    if (state.revealedIndicesCount < q!.indices!.length) {
      state = state.copyWith(revealedIndicesCount: state.revealedIndicesCount + 1);
    }
  }

  Future<void> submitFeedback(bool wasCorrect) async {
    final s = state.session;
    if (s == null || !state.isFlipped || state.isValidated) return;

    final idx = s.currentIndex;
    final q = s.questions[idx];
    final scores = List<double?>.from(s.userScores);

    double finalScore = wasCorrect ? 1.0 : 0.0;


    if (wasCorrect && q.type == 'ticket' && state.ticketChecks.contains(false)) {
      final checkedCount = state.ticketChecks.where((c) => c).length;
      final totalChecks = state.ticketChecks.length;
      if (totalChecks > 0) {
        finalScore = (checkedCount / totalChecks).clamp(0.5, 1.0);
      }
    }

    scores[idx] = finalScore;
    final updatedSession = s.copyWith(userScores: scores);

    state = state.copyWith(
      session: updatedSession,
      isValidated: true,
    );

    // Sync Lacunes
    if (wasCorrect) {
      await _lacunesRepo.removeIfCorrect(q);
    } else {
      await _lacunesRepo.addWrong(q);
    }
  }

  bool nextQuestion() {
    final s = state.session;
    if (s == null) return false;

    int newLives = state.lives;
    if (s.runMode == QuizRunMode.survival && state.isValidated) {
      final score = s.userScores[s.currentIndex] ?? 0.0;
      if (score < 0.5) {
        newLives--;
        if (newLives <= 0) {
          state = state.copyWith(lives: 0);
          return false; // Game Over
        }
      }
    }

    if (s.currentIndex >= s.questions.length - 1) {
      return false; // Finished
    }

    state = state.copyWith(
      session: s.copyWith(currentIndex: s.currentIndex + 1),
      isFlipped: false,
      isValidated: false,
      isTimedOut: false,
      lives: newLives,
    );
    _initQuestionSpecifics();
    _startTimer();
    return true;
  }
}

// In Riverpod 3, the builder function for .family must take the argument and pass it to the Notifier
final quizProvider = NotifierProvider.autoDispose.family<QuizNotifier, QuizState, String>((arg) => QuizNotifier(arg));
