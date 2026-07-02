import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../data/podcast_model.dart';
import 'podcast_player_card.dart';
import '../../../core/constants/eskolia_tokens.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  late final Future<List<Podcast>> _future = PodcastCatalog.load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: FutureBuilder<List<Podcast>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: EskoliaTokens.cyan),
                  );
                }
                if (snap.hasError) {
                  return _message('Impossible de charger les podcasts.');
                }
                final items = snap.data ?? const <Podcast>[];
                if (items.isEmpty) {
                  return _message('Aucun podcast disponible.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    12,
                    EskoliaLayout.screenPaddingH,
                    EskoliaLayout.screenPaddingBottom + 80,
                  ),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) return const _Header();
                    final p = items[index - 1];
                    return PodcastPlayerCard(podcast: p);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 14),
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🎙️',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                'Podcasts',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Une analyse audio par module. A ecouter avant de lire le cours pour preparer le terrain.',
            style: TextStyle(
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
