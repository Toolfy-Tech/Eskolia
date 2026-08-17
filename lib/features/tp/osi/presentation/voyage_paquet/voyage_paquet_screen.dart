import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eskolia/core/constants/eskolia_tokens.dart';
import 'package:eskolia/core/theme/eskolia_layout.dart';
import 'package:eskolia/shared/widgets/eskolia_ambient_background.dart';
import 'package:eskolia/shared/widgets/eskolia_app_bar.dart';
import 'package:eskolia/shared/widgets/eskolia_shell_body.dart';
import 'package:eskolia/features/tp/osi/models/osi_packet_step_model.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_layer_badge.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_memento_dialog.dart';
import 'voyage_paquet_provider.dart';

class VoyagePaquetScreen extends ConsumerWidget {
  const VoyagePaquetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voyagePaquetProvider);
    final notifier = ref.read(voyagePaquetProvider.notifier);
    final hPad = EskoliaLayout.screenPaddingH;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Le Voyage du Paquet',
        actions: [
          IconButton(
            tooltip: 'Mémento OSI (Aide & Cours)',
            icon: const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan),
            onPressed: () => OsiMementoDialog.show(context),
          ),
          IconButton(
            tooltip: 'Réinitialiser l\'assemblage',
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
                // Direction Toggle (Encapsulation 7->1 vs Décapsulation 1->7)
                _buildModeSelector(state, notifier),
                const SizedBox(height: 14),

                // Feedback Banner
                _buildFeedbackBanner(state),
                const SizedBox(height: 16),

                // Assembly Zone (Progressive Packet Structure - No 7 empty holes!)
                _buildAssemblyZone(state, notifier),
                const SizedBox(height: 16),

                // Action Validate Button (visible when 7 steps are placed)
                if (!state.isSuccess && state.isFullySlotted) ...[
                  _buildValidateButton(state, notifier),
                  const SizedBox(height: 20),
                ],

                // Available Pieces Pool (shuffled without spoiler layer numbers)
                if (!state.isSuccess && state.availableSteps.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choisis la prochaine étape (${state.availableSteps.length} restante${state.availableSteps.length > 1 ? "s" : ""}) :',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      const Text(
                        'Clique pour empiler',
                        style: TextStyle(color: Colors.white54, fontSize: 11.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildAvailablePiecesGrid(state, notifier, isDesktop),
                ] else if (state.isSuccess) ...[
                  _buildSuccessCard(state, notifier),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(VoyagePaquetState state, VoyagePaquetNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: 'Émission (7 ➔ 1)',
              subtitle: 'Encapsulation',
              isSelected: state.mode == PacketDirection.encapsulation,
              onTap: () => notifier.switchMode(PacketDirection.encapsulation),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildModeTab(
              title: 'Réception (1 ➔ 7)',
              subtitle: 'Décapsulation',
              isSelected: state.mode == PacketDirection.decapsulation,
              onTap: () => notifier.switchMode(PacketDirection.decapsulation),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? EskoliaTokens.cyan.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? EskoliaTokens.cyan : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? EskoliaTokens.cyan : Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(VoyagePaquetState state) {
    final isError = state.hasValidated && !state.isSuccess;

    final bgColor = state.isSuccess
        ? EskoliaTokens.success.withValues(alpha: 0.15)
        : (isError
            ? EskoliaTokens.error.withValues(alpha: 0.15)
            : EskoliaTokens.cyan.withValues(alpha: 0.12));

    final borderColor = state.isSuccess
        ? EskoliaTokens.success
        : (isError ? EskoliaTokens.error : EskoliaTokens.cyan.withValues(alpha: 0.3));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            state.isSuccess
                ? Icons.check_circle_rounded
                : (isError ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
            color: borderColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.lastFeedbackMessage ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssemblyZone(VoyagePaquetState state, VoyagePaquetNotifier notifier) {
    final isEncapsulation = state.mode == PacketDirection.encapsulation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Progression Steps Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAQUET EN COURS (${state.slottedSteps.length} / 7)',
                style: GoogleFonts.outfit(
                  color: EskoliaTokens.cyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  letterSpacing: 1.1,
                ),
              ),
              if (state.hasValidated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: state.isSuccess
                        ? EskoliaTokens.success.withValues(alpha: 0.2)
                        : EskoliaTokens.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${state.correctSlotsCount} / 7 corrects',
                    style: TextStyle(
                      color: state.isSuccess ? EskoliaTokens.success : Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 7 Mini Step Dots Indicator
          Row(
            children: List.generate(7, (index) {
              final isPlaced = index < state.slottedSteps.length;
              final isAssessed = state.hasValidated && isPlaced && index < state.validationResults.length;
              final isCorrect = isAssessed ? state.validationResults[index] : null;

              Color dotColor = Colors.white.withValues(alpha: 0.1);
              Widget dotContent = Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );

              if (isAssessed) {
                if (isCorrect == true) {
                  dotColor = EskoliaTokens.success;
                  dotContent = const Icon(Icons.check_rounded, color: Colors.black, size: 12);
                } else {
                  dotColor = EskoliaTokens.error;
                  dotContent = const Icon(Icons.close_rounded, color: Colors.white, size: 12);
                }
              } else if (isPlaced) {
                dotColor = EskoliaTokens.cyan;
                dotContent = Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                );
              } else if (index == state.slottedSteps.length) {
                dotColor = EskoliaTokens.cyan.withValues(alpha: 0.35);
              }

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                  height: 22,
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(6),
                    border: index == state.slottedSteps.length
                        ? Border.all(color: EskoliaTokens.cyan, width: 1.2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: dotContent,
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Placed Steps List (Rendered dynamically one by one!)
          if (state.slottedSteps.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 8),
                  Text(
                    isEncapsulation
                        ? 'Le paquet est vide. Choisis la 1ère étape (Couche 7) ci-dessous.'
                        : 'Le signal est vide. Choisis la 1ère étape (Couche 1) ci-dessous.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Render only the steps currently placed
            for (int i = 0; i < state.slottedSteps.length; i++)
              _buildSlottedCard(i, state.slottedSteps[i], state, notifier),

            // Subtle indicator for the next step if not complete
            if (!state.isFullySlotted) ...[
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.25), style: BorderStyle.solid),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${state.slottedSteps.length + 1}',
                        style: const TextStyle(color: EskoliaTokens.cyan, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Étape ${state.slottedSteps.length + 1} : Choisis une pièce disponible ci-dessous...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSlottedCard(
    int index,
    OsiPacketStep step,
    VoyagePaquetState state,
    VoyagePaquetNotifier notifier,
  ) {
    final isAssessed = state.hasValidated && index < state.validationResults.length;
    final isCorrect = isAssessed ? state.validationResults[index] : null;

    Color borderColor = Colors.white.withValues(alpha: 0.12);
    Color bgColor = EskoliaTokens.surface2;

    if (isAssessed) {
      if (isCorrect == true) {
        borderColor = EskoliaTokens.success;
        bgColor = EskoliaTokens.success.withValues(alpha: 0.12);
      } else {
        borderColor = EskoliaTokens.error;
        bgColor = EskoliaTokens.error.withValues(alpha: 0.12);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isAssessed ? 1.4 : 1.0),
      ),
      child: Row(
        children: [
          // Step Index Badge or Result Icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAssessed
                  ? (isCorrect == true ? EskoliaTokens.success : EskoliaTokens.error)
                  : EskoliaTokens.cyan.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: isAssessed
                ? Icon(
                    isCorrect == true ? Icons.check_rounded : Icons.close_rounded,
                    color: isCorrect == true ? Colors.black : Colors.white,
                    size: 16,
                  )
                : Text(
                    '${index + 1}',
                    style: const TextStyle(color: EskoliaTokens.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
          ),
          const SizedBox(width: 10),

          // Official OSI layer badge revealed ONLY if correct after validation!
          if (isAssessed && isCorrect == true) ...[
            OsiLayerBadge(layerNumber: step.layerNumber, compact: true),
            const SizedBox(width: 8),
          ],

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.headerTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: (isAssessed && isCorrect == false) ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isAssessed && isCorrect == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.dataPayloadPreview,
                    style: TextStyle(
                      color: step.accentColor,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '💡 ${step.detailedTechnicalNote}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (isAssessed && isCorrect == false) ...[
                  const SizedBox(height: 3),
                  Text(
                    '⚠️ Mauvais emplacement pour cette étape. Vérifie l\'ordre de transmission.',
                    style: TextStyle(
                      color: EskoliaTokens.error.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quick Remove Button
          if (!state.isSuccess)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
              tooltip: 'Retirer',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
              onPressed: () => notifier.removePiece(index),
            ),
        ],
      ),
    );
  }

  Widget _buildValidateButton(VoyagePaquetState state, VoyagePaquetNotifier notifier) {
    return FilledButton.icon(
      onPressed: () => notifier.validateSequence(),
      style: FilledButton.styleFrom(
        backgroundColor: EskoliaTokens.cyan,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
      label: const Text(
        'Valider l\'assemblage du paquet (7 / 7)',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildAvailablePiecesGrid(
    VoyagePaquetState state,
    VoyagePaquetNotifier notifier,
    bool isDesktop,
  ) {
    return Column(
      children: state.availableSteps.map((step) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => notifier.selectPiece(step),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: EskoliaTokens.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('📦', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.headerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.actionDescription,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline_rounded, color: EskoliaTokens.cyan, size: 22),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccessCard(VoyagePaquetState state, VoyagePaquetNotifier notifier) {
    final isEncapsulation = state.mode == PacketDirection.encapsulation;
    final nextMode = isEncapsulation ? PacketDirection.decapsulation : PacketDirection.encapsulation;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EskoliaTokens.success, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: EskoliaTokens.success, size: 50),
          const SizedBox(height: 12),
          Text(
            isEncapsulation ? 'Encapsulation Complète Réussie !' : 'Décapsulation Complète Réussie !',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isEncapsulation
                ? 'Le paquet est parfaitement formé avec tous ses en-têtes et le signal binaire est prêt à partir.'
                : 'La donnée originale a été décortiquée et délivrée intacte à la couche applicative.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => notifier.switchMode(nextMode),
            style: FilledButton.styleFrom(
              backgroundColor: EskoliaTokens.cyan,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: Text(
              isEncapsulation ? 'Passer à la Réception (Décapsulation 1 ➔ 7)' : 'Passer à l\'Émission (Encapsulation 7 ➔ 1)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
