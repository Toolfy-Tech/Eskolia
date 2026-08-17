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
import 'package:eskolia/features/tp/osi/data/osi_progress_repository.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_layer_badge.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_memento_dialog.dart';

class OsiHubScreen extends ConsumerWidget {
  const OsiHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(osiStatsProvider);
    final stats = statsAsync.value ?? const OsiStats();
    final hPad = EskoliaLayout.screenPaddingH;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Modèle OSI',
        actions: [
          IconButton(
            tooltip: 'Mémento OSI (Aide & Cours)',
            icon: const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan),
            onPressed: () => OsiMementoDialog.show(context),
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
                // Banner Intro & Global Mastery Jauge
                _buildMasteryBanner(stats),
                const SizedBox(height: 20),

                // Game Mode 1 : Le Tri Sélectif
                _buildGameCard(
                  context: context,
                  emoji: '⚡',
                  title: '1. Le Tri Sélectif',
                  tag: 'TRI & CLASSIFICATION',
                  tagColor: EskoliaTokens.cyan,
                  description: 'Associe les cartes (protocoles, équipements, PDU) à la bonne couche OSI avec des séries de défis sans-faute.',
                  statText: stats.triHighScore > 0 ? 'Record : ${stats.triHighScore} pts (Max combo x${stats.triMaxStreak})' : 'Pas encore joué',
                  accentColor: EskoliaTokens.cyan,
                  route: '/tp/osi/tri',
                ),
                const SizedBox(height: 16),

                // Game Mode 2 : Le Voyage du Paquet
                _buildGameCard(
                  context: context,
                  emoji: '📦',
                  title: '2. Le Voyage du Paquet',
                  tag: 'PUZZLE SÉQUENTIEL',
                  tagColor: EskoliaTokens.violet,
                  description: 'Reconstitue l\'encapsulation (Émission 7 ➔ 1) et la décapsulation (Réception 1 ➔ 7) étape par étape.',
                  statText: (stats.voyageEncapCompleted && stats.voyageDecapCompleted)
                      ? '✓ Émission & Réception maîtrisées !'
                      : (stats.voyageEncapCompleted ? '✓ Émission réussie' : 'À découvrir'),
                  accentColor: EskoliaTokens.violet,
                  route: '/tp/osi/paquet',
                ),
                const SizedBox(height: 16),

                // Game Mode 3 : L'Enquêteur OSI
                _buildGameCard(
                  context: context,
                  emoji: '🔍',
                  title: '3. L\'Enquêteur OSI',
                  tag: 'DIAGNOSTIC DE PANNES',
                  tagColor: Colors.amberAccent,
                  description: 'Analyse des tickets d\'incident et logs techniques réels pour désigner la couche en panne et la solution.',
                  statText: stats.enqueteurCasesSolved > 0 ? '${stats.enqueteurCasesSolved} affaires résolues' : 'Débutant',
                  accentColor: Colors.amberAccent,
                  route: '/tp/osi/enqueteur',
                ),
                const SizedBox(height: 28),

                // Mémento / Les 7 Couches en un coup d'œil
                _buildLayersMemento(context, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryBanner(OsiStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EskoliaTokens.cyan.withValues(alpha: 0.15),
            EskoliaTokens.violet.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: EskoliaTokens.cyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: Text('🌐', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maîtrise du Modèle OSI',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: stats.globalMasteryPercent / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(EskoliaTokens.cyan),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${stats.globalMasteryPercent}% de maîtrise globale',
                  style: const TextStyle(
                    color: EskoliaTokens.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String tag,
    required Color tagColor,
    required String description,
    required String statText,
    required Color accentColor,
    required String route,
  }) {
    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: accentColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    statText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Lancer',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: accentColor, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayersMemento(BuildContext context, bool isDesktop) {
    final layers = OsiLayersData.layers;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan, size: 20),
              const SizedBox(width: 10),
              Text(
                'Mémento des 7 Couches OSI',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...layers.map((layer) {
            return InkWell(
              onTap: () => OsiMementoDialog.show(context, initialLayer: layer.number),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: layer.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: layer.accentColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OsiLayerBadge(layerNumber: layer.number, compact: true),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: layer.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: layer.accentColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'PDU : ${layer.pdu}',
                                style: TextStyle(
                                  color: layer.accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 18),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${layer.name} (${layer.englishName})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      layer.keyProtocols.join(', '),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => OsiMementoDialog.show(context),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Ouvrir le Mémento Complet & Analogies'),
              style: OutlinedButton.styleFrom(
                foregroundColor: EskoliaTokens.cyan,
                side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
