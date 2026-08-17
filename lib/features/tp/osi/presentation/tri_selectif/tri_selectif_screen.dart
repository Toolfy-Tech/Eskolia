import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eskolia/core/constants/eskolia_tokens.dart';
import 'package:eskolia/core/theme/eskolia_layout.dart';
import 'package:eskolia/shared/widgets/eskolia_ambient_background.dart';
import 'package:eskolia/shared/widgets/eskolia_app_bar.dart';
import 'package:eskolia/shared/widgets/eskolia_card.dart';
import 'package:eskolia/shared/widgets/eskolia_shell_body.dart';
import 'package:eskolia/features/tp/osi/data/osi_layers_data.dart';
import 'package:eskolia/features/tp/osi/models/osi_card_item.dart';
import 'package:eskolia/features/tp/osi/models/osi_card_item.dart';
import 'package:eskolia/features/tp/osi/models/osi_layer_model.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_layer_badge.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_memento_dialog.dart';
import 'tri_selectif_provider.dart';

class TriSelectifScreen extends ConsumerStatefulWidget {
  const TriSelectifScreen({super.key});

  @override
  ConsumerState<TriSelectifScreen> createState() => _TriSelectifScreenState();
}

class _TriSelectifScreenState extends ConsumerState<TriSelectifScreen> {
  int? _hoveredLayerNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(triSelectifProvider.notifier).startNewGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(triSelectifProvider);
    final hPad = EskoliaLayout.screenPaddingH;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Le Tri Sélectif OSI',
        actions: [
          IconButton(
            tooltip: 'Mémento OSI (Aide & Cours)',
            icon: const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan),
            onPressed: () => OsiMementoDialog.show(context),
          ),
          PopupMenuButton<TriGameMode>(
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            tooltip: 'Changer de mode',
            onSelected: (mode) {
              ref.read(triSelectifProvider.notifier).startNewGame(mode: mode);
            },
            itemBuilder: (context) => [
              for (final m in TriGameMode.values)
                PopupMenuItem(
                  value: m,
                  child: Row(
                    children: [
                      Icon(
                        m == state.mode ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: m == state.mode ? EskoliaTokens.cyan : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Recommencer la série',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.read(triSelectifProvider.notifier).startNewGame(),
          ),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: state.isGameOver
                ? _buildGameOverView(state)
                : ListView(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                    children: [
                      // Header Mode & Series Progress (No timer!)
                      _buildHeaderSeriesBar(state),
                      const SizedBox(height: 16),

                      // Card to Drag / Assign
                      if (state.currentCard != null) ...[
                        _buildCurrentCardSection(state.currentCard!, state),
                        const SizedBox(height: 20),
                      ],

                      // Drop Zones (The 7 OSI Layers — clean without answers!)
                      _buildSectionTitle('Glisse ou clique sur la couche OSI correspondante :'),
                      const SizedBox(height: 12),
                      _buildLayersDropGrid(isDesktop),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSeriesBar(TriSelectifState state) {
    final progress = state.targetCount > 0
        ? (state.totalAttempts / state.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Progression de la série
              Row(
                children: [
                  Icon(
                    state.mode == TriGameMode.sansFaute
                        ? Icons.shield_rounded
                        : Icons.layers_rounded,
                    color: EskoliaTokens.cyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.mode == TriGameMode.sansFaute
                        ? 'Défi Survie : ${state.correctCount} réussis'
                        : 'Carte ${state.totalAttempts + 1} / ${state.targetCount}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Score
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${state.score} pts',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Série / Combo sans-faute
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: state.streak >= 3
                      ? Colors.deepOrange.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.streak >= 3
                        ? Colors.deepOrange.withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      state.streak >= 3 ? '🔥' : '⚡',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Série : ${state.streak}',
                      style: TextStyle(
                        color: state.streak >= 3 ? Colors.deepOrangeAccent : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Barre de progression linéaire (si mode à objectif de cartes)
          if (state.targetCount > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  state.mistakes.isEmpty ? EskoliaTokens.cyan : EskoliaTokens.amber,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentCardSection(OsiCardItem card, TriSelectifState state) {
    final isDesktop = kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows;

    final cardContent = Container(
      constraints: const BoxConstraints(maxWidth: 550),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EskoliaTokens.surface2,
            EskoliaTokens.surface1,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EskoliaTokens.cyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: EskoliaTokens.cyan.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(card.type.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      card.type.label.toUpperCase(),
                      style: const TextStyle(
                        color: EskoliaTokens.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: Colors.white54, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Glisser ou Cliquer sur une couche',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            card.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          if (card.hint != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    card.hint!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    Widget draggableCard;
    if (isDesktop) {
      draggableCard = Draggable<OsiCardItem>(
        data: card,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.rotate(
            angle: 0.04,
            child: Transform.scale(
              scale: 1.05,
              child: cardContent,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: cardContent,
        ),
        child: cardContent,
      );
    } else {
      draggableCard = LongPressDraggable<OsiCardItem>(
        data: card,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.04,
            child: cardContent,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: cardContent,
        ),
        child: cardContent,
      );
    }

    return Center(child: draggableCard);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLayersDropGrid(bool isDesktop) {
    final layers = OsiLayersData.layers; // 7 down to 1

    return Column(
      children: layers.map((layer) => _buildLayerDropTarget(layer)).toList(),
    );
  }

  Widget _buildLayerDropTarget(OsiLayerModel layer) {
    return DragTarget<OsiCardItem>(
      onWillAcceptWithDetails: (details) {
        setState(() => _hoveredLayerNumber = layer.number);
        return true;
      },
      onLeave: (_) {
        if (_hoveredLayerNumber == layer.number) {
          setState(() => _hoveredLayerNumber = null);
        }
      },
      onAcceptWithDetails: (details) {
        setState(() => _hoveredLayerNumber = null);
        ref.read(triSelectifProvider.notifier).dropCardOnLayer(layer.number);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty || _hoveredLayerNumber == layer.number;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => ref.read(triSelectifProvider.notifier).dropCardOnLayer(layer.number),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isHovered
                    ? layer.accentColor.withValues(alpha: 0.25)
                    : EskoliaTokens.surface1.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHovered
                      ? layer.accentColor
                      : layer.accentColor.withValues(alpha: 0.3),
                  width: isHovered ? 2.0 : 1.0,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: layer.accentColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Numéro de couche dans un rond coloré
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: layer.accentColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${layer.number}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nom de la couche uniquement (PAS de liste de protocoles ou PDU qui spoilent !)
                  Expanded(
                    child: Text(
                      layer.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Flèche indicatrice d'assignation
                  Icon(
                    Icons.subdirectory_arrow_left_rounded,
                    color: isHovered ? layer.accentColor : Colors.white24,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOverView(TriSelectifState state) {
    final isPerfect = state.mistakes.isEmpty && state.correctCount > 0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          children: [
            // Icon / Trophy
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPerfect
                      ? Colors.amberAccent.withValues(alpha: 0.2)
                      : EskoliaTokens.cyan.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isPerfect ? Colors.amberAccent : EskoliaTokens.cyan,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isPerfect ? '🏆' : (state.accuracy >= 70 ? '🎯' : '💡'),
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Titre de fin
            Center(
              child: Text(
                isPerfect
                    ? 'Série Parfaite ! Sans-Faute ✨'
                    : (state.mode == TriGameMode.sansFaute
                        ? 'Fin du Défi Sans-Faute'
                        : 'Série Terminée !'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Mode : ${state.mode.label}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMiniCard(
                    'Score Final',
                    '${state.score} pts',
                    Icons.stars_rounded,
                    Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryMiniCard(
                    'Réussite',
                    '${state.accuracy.toStringAsFixed(0)}%',
                    Icons.check_circle_rounded,
                    EskoliaTokens.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryMiniCard(
                    'Meilleur Combo',
                    '${state.maxStreak} d\'affilée',
                    Icons.local_fire_department_rounded,
                    Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Mistakes Review Section
            if (state.mistakes.isNotEmpty) ...[
              Text(
                'Erreurs à réviser (${state.mistakes.length}) :',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              for (final m in state.mistakes) _buildMistakeCard(m),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            FilledButton.icon(
              onPressed: () => ref.read(triSelectifProvider.notifier).startNewGame(),
              style: FilledButton.styleFrom(
                backgroundColor: EskoliaTokens.cyan,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.replay_rounded, size: 20),
              label: const Text(
                'Rejouer cette série',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Retour au Hub Modèle OSI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeCard(TriMistake m) {
    final correctLayer = OsiLayersData.getLayer(m.card.targetLayer);
    final wrongLayer = OsiLayersData.getLayer(m.wrongLayer);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EskoliaTokens.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(m.card.type.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Ton choix : ', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
              OsiLayerBadge(layerNumber: wrongLayer.number, compact: true),
              const SizedBox(width: 14),
              const Text('Bonne couche : ', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
              OsiLayerBadge(layerNumber: correctLayer.number, compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Explication pédagogique :',
                  style: GoogleFonts.outfit(
                    color: EskoliaTokens.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.card.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                if (m.card.hint != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Point clé : ${m.card.hint!}',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => OsiMementoDialog.show(context, initialLayer: correctLayer.number),
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: Text('Consulter la Couche ${correctLayer.number} (${correctLayer.name}) dans le Mémento'),
              style: TextButton.styleFrom(
                foregroundColor: EskoliaTokens.cyan,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
