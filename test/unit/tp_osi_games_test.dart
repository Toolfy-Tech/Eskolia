import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eskolia/features/tp/osi/data/osi_layers_data.dart';
import 'package:eskolia/features/tp/osi/data/osi_tri_selectif_data.dart';
import 'package:eskolia/features/tp/osi/data/osi_encapsulation_data.dart';
import 'package:eskolia/features/tp/osi/data/osi_enqueteur_data.dart';
import 'package:eskolia/features/tp/osi/models/osi_packet_step_model.dart';
import 'package:eskolia/features/tp/osi/presentation/tri_selectif/tri_selectif_provider.dart';
import 'package:eskolia/features/tp/osi/presentation/voyage_paquet/voyage_paquet_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eskolia/features/tp/osi/presentation/enqueteur/enqueteur_osi_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Modèle OSI Data Tests', () {
    test('Les 7 couches OSI sont correctement ordonnées et complètes', () {
      expect(OsiLayersData.layers.length, 7);
      expect(OsiLayersData.layers.first.number, 7); // Application
      expect(OsiLayersData.layers.last.number, 1); // Physique

      final l3 = OsiLayersData.getLayer(3);
      expect(l3.name, 'Réseau');
      expect(l3.pdu, 'Paquet (Packet)');
    });

    test('Le pool du Tri Sélectif contient plus de 30 cartes réparties sur toutes les couches', () {
      expect(OsiTriSelectifData.allCards.length, greaterThanOrEqualTo(30));
      for (int l = 1; l <= 7; l++) {
        final count = OsiTriSelectifData.allCards.where((c) => c.targetLayer == l).length;
        expect(count, greaterThan(0), reason: 'La couche $l doit avoir des cartes');
      }
    });

    test('Les données d\'encapsulation et décapsulation contiennent les 7 étapes ordonnées', () {
      expect(OsiEncapsulationData.encapsulationSteps.length, 7);
      expect(OsiEncapsulationData.encapsulationSteps.first.layerNumber, 7);
      expect(OsiEncapsulationData.encapsulationSteps.last.layerNumber, 1);

      expect(OsiEncapsulationData.decapsulationSteps.length, 7);
      expect(OsiEncapsulationData.decapsulationSteps.first.layerNumber, 1);
      expect(OsiEncapsulationData.decapsulationSteps.last.layerNumber, 7);
    });

    test('L\'Enquêteur OSI propose des cas d\'incidents cohérents avec solution exacte', () {
      expect(OsiEnqueteurData.cases.length, greaterThanOrEqualTo(5));
      for (final c in OsiEnqueteurData.cases) {
        expect(c.correctLayerNumber, inInclusiveRange(1, 7));
        final correctActions = c.actions.where((a) => a.isCorrect).toList();
        expect(correctActions.length, 1, reason: 'Chaque cas doit avoir exactement 1 bonne action');
      }
    });
  });

  group('Modèle OSI Providers Tests', () {
    test('TriSelectifNotifier calcule les points et gère les combos', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(triSelectifProvider.notifier);
      notifier.startNewGame();

      var state = container.read(triSelectifProvider);
      expect(state.isPlaying, isTrue);
      expect(state.currentCard, isNotNull);

      final card = state.currentCard!;
      // Drop correct
      notifier.dropCardOnLayer(card.targetLayer);

      state = container.read(triSelectifProvider);
      expect(state.correctCount, 1);
      expect(state.score, 20);
      expect(state.streak, 1);

      // Drop incorrect
      final nextCard = state.currentCard!;
      final wrongLayer = nextCard.targetLayer == 1 ? 2 : 1;
      notifier.dropCardOnLayer(wrongLayer);

      state = container.read(triSelectifProvider);
      expect(state.streak, 0); // Reset combo
      expect(state.mistakes.length, 1);
    });

    test('VoyagePaquetNotifier gère l\'assemblage des slots et la validation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(voyagePaquetProvider.notifier);
      var state = container.read(voyagePaquetProvider);
      expect(state.slottedSteps.length, 0);
      expect(state.availableSteps.length, 7);

      // Placement d'une mauvaise séquence intentionnelle
      final reversedSteps = state.allSteps.reversed.toList();
      for (final step in reversedSteps) {
        notifier.selectPiece(step);
      }

      state = container.read(voyagePaquetProvider);
      expect(state.slottedSteps.length, 7);
      expect(state.availableSteps.length, 0);

      // Validation de la séquence inversée (doit échouer)
      notifier.validateSequence();
      state = container.read(voyagePaquetProvider);
      expect(state.hasValidated, isTrue);
      expect(state.isSuccess, isFalse);
      expect(state.correctSlotsCount, lessThan(7));

      // Réinitialisation et placement de la bonne séquence
      notifier.reset();
      for (final step in state.allSteps) {
        notifier.selectPiece(step);
      }
      notifier.validateSequence();

      state = container.read(voyagePaquetProvider);
      expect(state.hasValidated, isTrue);
      expect(state.isSuccess, isTrue);
      expect(state.correctSlotsCount, 7);
    });

    test('EnqueteurOsiNotifier gère le flux en 2 étapes (Couche puis Action)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(enqueteurOsiProvider.notifier);
      var state = container.read(enqueteurOsiProvider);
      expect(state.currentStep, EnqueteStep.chooseLayer);

      final c = state.currentCase!;
      // Validation de la bonne couche
      notifier.validateLayer(c.correctLayerNumber);

      state = container.read(enqueteurOsiProvider);
      expect(state.currentStep, EnqueteStep.chooseAction);
      expect(state.isLayerCorrect, isTrue);

      // Validation de la bonne action
      final correctAction = c.actions.firstWhere((a) => a.isCorrect);
      notifier.validateAction(correctAction);

      state = container.read(enqueteurOsiProvider);
      expect(state.currentStep, EnqueteStep.resolved);
      expect(state.solvedCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
  });
}
