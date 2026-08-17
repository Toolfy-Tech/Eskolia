import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eskolia/core/constants/eskolia_tokens.dart';
import 'package:eskolia/core/theme/eskolia_layout.dart';
import 'package:eskolia/shared/widgets/eskolia_ambient_background.dart';
import 'package:eskolia/shared/widgets/eskolia_app_bar.dart';
import 'package:eskolia/shared/widgets/eskolia_shell_body.dart';
import 'package:eskolia/features/tp/osi/data/osi_layers_data.dart';
import 'package:eskolia/features/tp/osi/models/osi_incident_case_model.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_layer_badge.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_memento_dialog.dart';
import 'enqueteur_osi_provider.dart';

class EnqueteurOsiScreen extends ConsumerWidget {
  const EnqueteurOsiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(enqueteurOsiProvider);
    final notifier = ref.read(enqueteurOsiProvider.notifier);
    final currentCase = state.currentCase;
    final hPad = EskoliaLayout.screenPaddingH;

    if (currentCase == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'L\'Enquêteur OSI (Diagnostic)',
        actions: [
          IconButton(
            tooltip: 'Mémento OSI (Aide & Cours)',
            icon: const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan),
            onPressed: () => OsiMementoDialog.show(context),
          ),
          IconButton(
            tooltip: 'Nouveau cas',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => notifier.reset(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
              children: [
                // Top Progress & Stats
                _buildTopProgress(state),
                const SizedBox(height: 16),

                // Incident Ticket Card (User complaint + Technical symptoms)
                _buildTicketCard(currentCase),
                const SizedBox(height: 18),

                // Feedback Banner
                if (state.feedbackMessage != null) ...[
                  _buildFeedbackBanner(state),
                  const SizedBox(height: 18),
                ],

                // Step 1 : Choose Layer
                if (state.currentStep == EnqueteStep.chooseLayer) ...[
                  _buildSectionTitle('Étape 1/2 : Quelle couche OSI est en cause ?'),
                  const SizedBox(height: 12),
                  _buildLayersGrid(currentCase, state, notifier),
                ],

                // Step 2 : Choose Support Action
                if (state.currentStep == EnqueteStep.chooseAction) ...[
                  _buildSectionTitle('Étape 2/2 : Quelle action corrective appliquer ?'),
                  const SizedBox(height: 12),
                  _buildActionsList(currentCase, state, notifier),
                ],

                // Step 3 : Resolved View & RCA
                if (state.currentStep == EnqueteStep.resolved) ...[
                  _buildResolvedCard(context, currentCase, notifier),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProgress(EnqueteurOsiState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: EskoliaTokens.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Affaire ${state.currentIndex + 1} / ${state.cases.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EskoliaTokens.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.solvedCount} résolues',
              style: const TextStyle(color: EskoliaTokens.success, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(OsiIncidentCase c) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TICKET ${c.ticketNumber}',
                  style: const TextStyle(
                    color: EskoliaTokens.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded, color: Colors.white60, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    c.userRole,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '« ${c.userComplaint} »',
            style: GoogleFonts.outfit(
              color: Colors.amberAccent,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          const Text(
            'SYMPTÔMES TECHNIQUES OBSERVÉS :',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          ...c.technicalSymptoms.map((symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('▸ ', style: TextStyle(color: EskoliaTokens.cyan, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        symptom,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(EnqueteurOsiState state) {
    final isSuccess = state.isActionCorrect == true || (state.isLayerCorrect == true && state.currentStep == EnqueteStep.chooseAction);
    final isError = state.isLayerCorrect == false || state.isActionCorrect == false;

    final color = isSuccess ? Colors.greenAccent : (isError ? EskoliaTokens.error : EskoliaTokens.cyan);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle_rounded : (isError ? Icons.cancel_rounded : Icons.info_rounded),
              color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.feedbackMessage ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLayersGrid(OsiIncidentCase c, EnqueteurOsiState state, EnqueteurOsiNotifier notifier) {
    final layers = OsiLayersData.layers; // 7 to 1

    return Column(
      children: layers.map((layer) {
        final isSelected = state.selectedLayer == layer.number;
        final isWrong = isSelected && state.isLayerCorrect == false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => notifier.validateLayer(layer.number),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isWrong
                    ? EskoliaTokens.error.withValues(alpha: 0.2)
                    : EskoliaTokens.surface1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isWrong ? EskoliaTokens.error : layer.accentColor.withValues(alpha: 0.35),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: layer.accentColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${layer.number}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      layer.fullName,
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsList(OsiIncidentCase c, EnqueteurOsiState state, EnqueteurOsiNotifier notifier) {
    return Column(
      children: c.actions.map((action) {
        final isSelected = state.selectedActionId == action.id;
        final isWrong = isSelected && state.isActionCorrect == false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => notifier.validateAction(action),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isWrong
                    ? EskoliaTokens.error.withValues(alpha: 0.2)
                    : EskoliaTokens.surface1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWrong ? EskoliaTokens.error : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.build_circle_outlined, color: EskoliaTokens.cyan, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      action.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResolvedCard(BuildContext context, OsiIncidentCase c, EnqueteurOsiNotifier notifier) {
    final layer = OsiLayersData.getLayer(c.correctLayerNumber);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 26),
              const SizedBox(width: 10),
              Text(
                'Rapport d\'analyse (Root Cause Analysis)',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Couche résolue : ', style: TextStyle(color: Colors.white60, fontSize: 13)),
              OsiLayerBadge(layerNumber: layer.number),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            c.fullRcaExplanation,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => OsiMementoDialog.show(context, initialLayer: layer.number),
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: Text('Consulter la Couche ${layer.number} (${layer.name}) dans le Mémento'),
              style: TextButton.styleFrom(
                foregroundColor: EskoliaTokens.cyan,
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => notifier.nextCase(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Passer à l\'affaire suivante'),
              style: ElevatedButton.styleFrom(
                backgroundColor: EskoliaTokens.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
