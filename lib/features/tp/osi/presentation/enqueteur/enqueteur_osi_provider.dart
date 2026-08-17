import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/osi_enqueteur_data.dart';
import '../../data/osi_progress_repository.dart';
import '../../models/osi_incident_case_model.dart';

enum EnqueteStep {
  chooseLayer, // Étape 1 : Choisir la couche OSI responsable
  chooseAction, // Étape 2 : Choisir l'action corrective appropriée
  resolved, // Étape 3 : Résumé et explication RCA
}

class EnqueteurOsiState {
  const EnqueteurOsiState({
    this.cases = const [],
    this.currentIndex = 0,
    this.currentStep = EnqueteStep.chooseLayer,
    this.selectedLayer,
    this.selectedActionId,
    this.isLayerCorrect,
    this.isActionCorrect,
    this.solvedCount = 0,
    this.totalAttempts = 0,
    this.feedbackMessage,
  });

  final List<OsiIncidentCase> cases;
  final int currentIndex;
  final EnqueteStep currentStep;
  final int? selectedLayer;
  final String? selectedActionId;
  final bool? isLayerCorrect;
  final bool? isActionCorrect;
  final int solvedCount;
  final int totalAttempts;
  final String? feedbackMessage;

  OsiIncidentCase? get currentCase =>
      (currentIndex >= 0 && currentIndex < cases.length) ? cases[currentIndex] : null;

  bool get isLastCase => currentIndex >= cases.length - 1;

  EnqueteurOsiState copyWith({
    List<OsiIncidentCase>? cases,
    int? currentIndex,
    EnqueteStep? currentStep,
    int? selectedLayer,
    String? selectedActionId,
    bool? isLayerCorrect,
    bool? isActionCorrect,
    int? solvedCount,
    int? totalAttempts,
    String? feedbackMessage,
  }) {
    return EnqueteurOsiState(
      cases: cases ?? this.cases,
      currentIndex: currentIndex ?? this.currentIndex,
      currentStep: currentStep ?? this.currentStep,
      selectedLayer: selectedLayer,
      selectedActionId: selectedActionId,
      isLayerCorrect: isLayerCorrect,
      isActionCorrect: isActionCorrect,
      solvedCount: solvedCount ?? this.solvedCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      feedbackMessage: feedbackMessage,
    );
  }
}

class EnqueteurOsiNotifier extends Notifier<EnqueteurOsiState> {
  @override
  EnqueteurOsiState build() {
    final list = List<OsiIncidentCase>.from(OsiEnqueteurData.cases)..shuffle();
    return EnqueteurOsiState(
      cases: list,
      currentIndex: 0,
      currentStep: EnqueteStep.chooseLayer,
    );
  }

  void reset() {
    final list = List<OsiIncidentCase>.from(OsiEnqueteurData.cases)..shuffle();
    state = EnqueteurOsiState(
      cases: list,
      currentIndex: 0,
      currentStep: EnqueteStep.chooseLayer,
    );
  }

  void validateLayer(int layerNumber) {
    final current = state.currentCase;
    if (current == null) return;

    final isCorrect = current.correctLayerNumber == layerNumber;

    if (isCorrect) {
      state = state.copyWith(
        selectedLayer: layerNumber,
        isLayerCorrect: true,
        currentStep: EnqueteStep.chooseAction,
        feedbackMessage: '✓ Excellente déduction ! C\'est bien la Couche $layerNumber. Choisis l\'action de remédiation.',
      );
    } else {
      state = state.copyWith(
        selectedLayer: layerNumber,
        isLayerCorrect: false,
        feedbackMessage: '❌ Ce n\'est pas la couche ${layerNumber}. Indice : ${current.diagnosticHint}',
      );
    }
  }

  void validateAction(OsiSupportAction action) {
    final current = state.currentCase;
    if (current == null) return;

    final isCorrect = action.isCorrect;

    if (isCorrect) {
      state = state.copyWith(
        selectedActionId: action.id,
        isActionCorrect: true,
        currentStep: EnqueteStep.resolved,
        solvedCount: state.solvedCount + 1,
        totalAttempts: state.totalAttempts + 1,
        feedbackMessage: '🎉 Incident résolu avec succès !',
      );
      ref.read(osiStatsProvider.notifier).recordEnqueteurSolve();
    } else {
      state = state.copyWith(
        selectedActionId: action.id,
        isActionCorrect: false,
        totalAttempts: state.totalAttempts + 1,
        feedbackMessage: '❌ Action inefficace : ${action.explanation}',
      );
    }
  }

  void nextCase() {
    if (state.isLastCase) {
      // Re-mélanger
      final list = List<OsiIncidentCase>.from(OsiEnqueteurData.cases)..shuffle();
      state = EnqueteurOsiState(
        cases: list,
        currentIndex: 0,
        currentStep: EnqueteStep.chooseLayer,
        solvedCount: state.solvedCount,
        totalAttempts: state.totalAttempts,
      );
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        currentStep: EnqueteStep.chooseLayer,
        selectedLayer: null,
        selectedActionId: null,
        isLayerCorrect: null,
        isActionCorrect: null,
        feedbackMessage: null,
      );
    }
  }
}

final enqueteurOsiProvider = NotifierProvider<EnqueteurOsiNotifier, EnqueteurOsiState>(
  EnqueteurOsiNotifier.new,
);
