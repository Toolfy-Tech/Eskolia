import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../data/practical_catalog_repository.dart';
import '../data/practical_track_models.dart';

const Color _slate = Color(0xFF94A3B8);

class _ComingSoonEntry {
  const _ComingSoonEntry({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;
}

const List<_ComingSoonEntry> _kComingSoonTracks = [
  _ComingSoonEntry(
    emoji: '\u{1F310}',
    title: 'Simulation réseau (Filius / Packet Tracer)',
    description:
        'Topologies, adressage et configuration en environnement simulé — contenu en préparation.',
  ),
  _ComingSoonEntry(
    emoji: '\u{1F9E0}',
    title: 'Binaire & adressage réseau',
    description:
        'Calcul de masques, sous-réseaux et plages d’adresses à partir du binaire — contenu en préparation.',
  ),
  _ComingSoonEntry(
    emoji: '\u{1F4CB}',
    title: 'ITIL — gestion des tickets',
    description:
        'Création, priorisation, catégorisation et suivi des demandes — bonnes pratiques service desk — contenu en préparation.',
  ),
];

class _ComingSoonTpCard extends StatelessWidget {
  const _ComingSoonTpCard({required this.entry});

  final _ComingSoonEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: EskoliaVisual.neonViolet.withValues(alpha: 0.2),
                        border: Border.all(
                          color:
                              EskoliaVisual.neonViolet.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        'Bientôt',
                        style: TextStyle(
                          color: EskoliaVisual.neonViolet.withValues(alpha: 0.95),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.88),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu TP (barre de nav) : thèmes disponibles + fiches « bientôt ».
class PracticalExercisesHubScreen extends StatefulWidget {
  const PracticalExercisesHubScreen({super.key});

  @override
  State<PracticalExercisesHubScreen> createState() =>
      _PracticalExercisesHubScreenState();
}

class _PracticalExercisesHubScreenState
    extends State<PracticalExercisesHubScreen> {
  List<PracticalTrackSummary>? _tracks;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await PracticalCatalogRepository.loadTrackSummaries();
      if (!mounted) return;
      setState(() {
        _tracks = t;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EskoliaAppBar.standard(context, title: 'TP & tutoriels'),
                Expanded(
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(hPad),
                            child: Text(
                              '$_error',
                              style: TextStyle(color: Colors.red.shade200),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _tracks == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: EskoliaVisual.neonCyan,
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                hPad,
                                8,
                                hPad,
                                kEskoliaBottomNavReserve,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Travaux pratiques guidés : tutoriels, preuves / captures, QCM par thème. '
                                    'D’autres parcours (réseau simulé, binaire, ITIL…) arrivent progressivement.',
                                    style: TextStyle(
                                      color: _slate.withValues(alpha: 0.92),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  for (final t in _tracks!)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => context.push(
                                            '/tp/${t.id}',
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: EskoliaVisual.neonCyan
                                                    .withValues(alpha: 0.4),
                                              ),
                                              color: EskoliaVisual.neonCyan
                                                  .withValues(alpha: 0.07),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  t.emoji,
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        t.title,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        t.description,
                                                        style: TextStyle(
                                                          color: _slate
                                                              .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                          fontSize: 12,
                                                          height: 1.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bientôt',
                                    style: TextStyle(
                                      color: _slate.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  for (final c in _kComingSoonTracks)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _ComingSoonTpCard(entry: c),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
