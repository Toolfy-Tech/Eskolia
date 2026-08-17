import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/osi_encapsulation_data.dart';
import '../../data/osi_progress_repository.dart';
import '../../models/osi_packet_step_model.dart';

class VoyagePaquetState {
  const VoyagePaquetState({
    this.mode = PacketDirection.encapsulation,
    this.allSteps = const [],
    this.availableSteps = const [],
    this.slottedSteps = const [],
    this.validationResults = const [],
    this.hasValidated = false,
    this.isSuccess = false,
    this.attempts = 0,
    this.lastFeedbackMessage,
  });

  final PacketDirection mode;
  final List<OsiPacketStep> allSteps; // L'ordre exact attendu (7)
  final List<OsiPacketStep> availableSteps; // Les pièces restantes dans la pioche
  final List<OsiPacketStep> slottedSteps; // Les pièces assemblées par l'élève (0..7)
  final List<bool> validationResults; // Résultat de validation pour chaque slot
  final bool hasValidated;
  final bool isSuccess;
  final int attempts;
  final String? lastFeedbackMessage;

  int get correctSlotsCount => validationResults.where((r) => r == true).length;
  bool get isFullySlotted => slottedSteps.length == allSteps.length;

  VoyagePaquetState copyWith({
    PacketDirection? mode,
    List<OsiPacketStep>? allSteps,
    List<OsiPacketStep>? availableSteps,
    List<OsiPacketStep>? slottedSteps,
    List<bool>? validationResults,
    bool? hasValidated,
    bool? isSuccess,
    int? attempts,
    String? lastFeedbackMessage,
  }) {
    return VoyagePaquetState(
      mode: mode ?? this.mode,
      allSteps: allSteps ?? this.allSteps,
      availableSteps: availableSteps ?? this.availableSteps,
      slottedSteps: slottedSteps ?? this.slottedSteps,
      validationResults: validationResults ?? this.validationResults,
      hasValidated: hasValidated ?? this.hasValidated,
      isSuccess: isSuccess ?? this.isSuccess,
      attempts: attempts ?? this.attempts,
      lastFeedbackMessage: lastFeedbackMessage,
    );
  }
}

class VoyagePaquetNotifier extends Notifier<VoyagePaquetState> {
  @override
  VoyagePaquetState build() {
    return _initState(PacketDirection.encapsulation);
  }

  VoyagePaquetState _initState(PacketDirection mode) {
    final original = mode == PacketDirection.encapsulation
        ? OsiEncapsulationData.encapsulationSteps
        : OsiEncapsulationData.decapsulationSteps;

    final shuffled = List<OsiPacketStep>.from(original)..shuffle();

    return VoyagePaquetState(
      mode: mode,
      allSteps: original,
      availableSteps: shuffled,
      slottedSteps: [],
      validationResults: [],
      hasValidated: false,
      isSuccess: false,
      attempts: 0,
      lastFeedbackMessage: mode == PacketDirection.encapsulation
          ? 'Assemble les 7 étapes dans l\'ordre d\'émission (de la couche Haute vers la couche Basse), puis valide ton paquet.'
          : 'Assemble les 7 étapes dans l\'ordre de réception (du signal physique vers l\'application), puis valide ton paquet.',
    );
  }

  void switchMode(PacketDirection mode) {
    state = _initState(mode);
  }

  void reset() {
    state = _initState(state.mode);
  }

  /// Ajoute une pièce dans le prochain slot disponible
  void selectPiece(OsiPacketStep step) {
    if (state.isSuccess || state.isFullySlotted) return;

    final nextSlotted = [...state.slottedSteps, step];
    final nextAvailable = state.availableSteps.where((s) => s.id != step.id).toList();

    state = state.copyWith(
      slottedSteps: nextSlotted,
      availableSteps: nextAvailable,
      hasValidated: false,
      validationResults: [],
      lastFeedbackMessage: 'Étape ajoutée au slot ${nextSlotted.length} / ${state.allSteps.length}.',
    );
  }

  /// Retire une pièce du slot et la remet dans la pioche disponible
  void removePiece(int index) {
    if (state.isSuccess || index < 0 || index >= state.slottedSteps.length) return;

    final removed = state.slottedSteps[index];
    final nextSlotted = List<OsiPacketStep>.from(state.slottedSteps)..removeAt(index);
    final nextAvailable = [...state.availableSteps, removed];

    state = state.copyWith(
      slottedSteps: nextSlotted,
      availableSteps: nextAvailable,
      hasValidated: false,
      validationResults: [],
      lastFeedbackMessage: 'Étape retirée.',
    );
  }

  /// Déplace une pièce dans l'ordre d'assemblage
  void reorderPiece(int oldIndex, int newIndex) {
    if (state.isSuccess) return;

    final nextSlotted = List<OsiPacketStep>.from(state.slottedSteps);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = nextSlotted.removeAt(oldIndex);
    nextSlotted.insert(newIndex, item);

    state = state.copyWith(
      slottedSteps: nextSlotted,
      hasValidated: false,
      validationResults: [],
    );
  }

  /// Valide la séquence entière assemblée par l'élève
  void validateSequence() {
    if (state.slottedSteps.length < state.allSteps.length) {
      state = state.copyWith(
        hasValidated: false,
        lastFeedbackMessage: '⚠️ Place d\'abord les 7 étapes avant de valider l\'assemblage.',
      );
      return;
    }

    final results = <bool>[];
    int correctCount = 0;

    for (int i = 0; i < state.allSteps.length; i++) {
      final isCorrect = state.slottedSteps[i].id == state.allSteps[i].id;
      results.add(isCorrect);
      if (isCorrect) correctCount++;
    }

    final isAllCorrect = correctCount == state.allSteps.length;
    final newAttempts = state.attempts + 1;

    String feedback;
    if (isAllCorrect) {
      feedback = state.mode == PacketDirection.encapsulation
          ? '🎉 Parfait ! L\'encapsulation complète est validée avec succès (7/7) !'
          : '🎉 Parfait ! La décapsulation complète est validée avec succès (7/7) !';
    } else {
      feedback = '❌ $correctCount / ${state.allSteps.length} étapes bien positionnées. Observe les slots en rouge et réorganise-les !';
    }

    state = state.copyWith(
      validationResults: results,
      hasValidated: true,
      isSuccess: isAllCorrect,
      attempts: newAttempts,
      lastFeedbackMessage: feedback,
    );

    if (isAllCorrect) {
      ref.read(osiStatsProvider.notifier).markVoyageComplete(
        state.mode == PacketDirection.encapsulation,
      );
    }
  }
}

final voyagePaquetProvider = NotifierProvider<VoyagePaquetNotifier, VoyagePaquetState>(
  VoyagePaquetNotifier.new,
);
