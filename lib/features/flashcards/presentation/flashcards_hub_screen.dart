import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../data/flashcard_deck_repository.dart';
import 'flashcard_session_screen.dart';

/// Hub flashcards — blueprint v3 § Flashcards + indicateur « à réviser ».
class FlashcardsHubScreen extends StatefulWidget {
  const FlashcardsHubScreen({super.key});

  @override
  State<FlashcardsHubScreen> createState() => _FlashcardsHubScreenState();
}

class _FlashcardsHubScreenState extends State<FlashcardsHubScreen> {
  final _repo = FlashcardDeckRepository();
  int _due = 0;
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final due = await _repo.countDue();
    final all = await _repo.readAll();
    if (mounted) {
      setState(() {
        _due = due;
        _total = all.length;
        _loading = false;
      });
    }
  }

  void _openSession(List<DeckFlashcard> cards, {bool ephemeral = false}) {
    if (cards.isEmpty) return;
    context.push(
      '/flashcards/session',
      extra: FlashcardSessionRouteArgs(
        cards: cards,
        ephemeral: ephemeral,
        timed: false,
        survival: false,
      ),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Flashcards'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: RefreshIndicator(
              color: EskoliaVisual.neonViolet,
              onRefresh: _reload,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                12,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: EskoliaVisual.neonViolet,
                      ),
                    ),
                  )
                else ...[
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'À réviser aujourd\'hui',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_due carte${_due > 1 ? 's' : ''} due${_due != 1 ? 's' : ''} · Paquet : $_total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _due == 0
                              ? null
                              : () async {
                                  final list = await _repo.dueCards();
                                  list.shuffle();
                                  _openSession(
                                    list.take(20).toList(),
                                    ephemeral: false,
                                  );
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: EskoliaVisual.neonViolet,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                            disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Lancer la révision'),
                        ),
                        if (_due == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Toutes les cartes sont à jour — reviens demain 🎉',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Flashcards rapides ⚡',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '10 cartes aléatoires TIP + Optimus — ou compose ta série (thèmes, niveaux). '
                          'Sans enregistrer le SRS.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/solo/flashcards-solo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Démarrer'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EskoliaFlashcardsCard(onSession: _openSession),
                  const SizedBox(height: 16),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Révision lacunes \u{1F4A1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quiz QCM (max 10) sur tes erreurs — parcours, solo et multijoueur.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/quiz/revision-lacunes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Lancer les lacunes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

const Color _cyan = Color(0xFF00BCD4);
const Color _slate = Color(0xFF94A3B8);

class _EskoliaFlashcardsCard extends StatelessWidget {
  const _EskoliaFlashcardsCard({required this.onSession});
  final void Function(List<DeckFlashcard> cards, {bool ephemeral}) onSession;

  Future<void> _pick(BuildContext context) async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.flashcards);
    if (!context.mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun fichier dans Eskolia/Flashcards/. Configure ton dossier dans les parametres.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FlashcardFilePicker(files: files),
    );
    if (picked == null || !context.mounted) return;
    final raw = await fs.readFile(EskoliaFolder.flashcards, picked);
    if (raw == null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce fichier.')));
      return;
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) throw const FormatException('format invalide');
      final questions = decoded['questions'];
      if (questions is! List || questions.isEmpty) throw const FormatException('aucune question');
      final cards = <DeckFlashcard>[];
      for (final q in questions) {
        if (q is! Map) continue;
        final front = q['question'] as String?;
        final back = q['answer'] as String?;
        if (front == null || back == null) continue;
        final hint = q['hint'] as String?;
        cards.add(DeckFlashcard(
          id: 'eskolia_fc_${cards.length}_${front.hashCode}',
          front: front.trim(),
          back: hint != null && hint.isNotEmpty ? '$back\n\n$hint' : back.trim(),
          mastery: 0,
          nextDue: DateTime.now(),
        ));
      }
      if (cards.isEmpty) throw const FormatException('aucune carte valide');
      if (context.mounted) onSession(cards, ephemeral: true);
    } on FormatException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fichier invalide : ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('\u{1F4C2}', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Mes flashcards Eskolia',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Lance une session depuis un fichier .json sauvegarde dans Eskolia/Flashcards/.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => _pick(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _cyan,
              side: BorderSide(color: _cyan.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Choisir un fichier'),
          ),
        ],
      ),
    );
  }
}

class _FlashcardFilePicker extends StatelessWidget {
  const _FlashcardFilePicker({required this.files});
  final List<String> files;

  String _label(String f) => f.replaceAll('flashcards_', '').replaceAll('.json', '').replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Choisir un paquet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.style_rounded, color: _cyan),
              title: Text(_label(files[i]), style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(files[i], style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 11)),
              onTap: () => Navigator.of(context).pop(files[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
