import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../features/ai/data/ai_key_repository.dart';
import '../../../features/ai/data/ai_provider.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';
import '../../notebook/data/note_ai_generator.dart';


class BilanRecapScreen extends StatefulWidget {
  const BilanRecapScreen({super.key});

  @override
  State<BilanRecapScreen> createState() => _BilanRecapScreenState();
}

class _BilanRecapScreenState extends State<BilanRecapScreen> {
  final _fs = EskoliaFolderService.instance;
  final _aiKeyRepo = AiKeyRepository();
  final _generator = NoteAiGenerator();

  List<String> _files = [];
  final Set<String> _selected = {};
  bool _loading = true;
  bool _analyzing = false;
  String _analysisBuffer = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    final files = await _fs.listFiles(EskoliaFolder.bilans);
    files.sort((a, b) => b.compareTo(a));
    if (!mounted) return;
    setState(() {
      _files = files;
      _loading = false;
    });
  }

  Future<void> _reviserErreurs() async {
    final cards = <DeckFlashcard>[];
    for (final filename in _selected) {
      final raw = await _fs.readFile(EskoliaFolder.bilans, filename);
      if (raw == null) continue;
      try {
        final decoded = json.decode(raw);
        if (decoded is! Map) continue;
        final questions = decoded['questions'];
        if (questions is! List) continue;
        for (final q in questions) {
          if (q is! Map) continue;
          final result = q['result'] as String?;
          if (result != 'wrong' && result != 'partial') continue;
          final front = q['question'] as String?;
          final back = q['answer'] as String?;
          if (front == null || back == null) continue;
          final explanation = q['explanation'] as String?;
          cards.add(DeckFlashcard(
            id: 'revision_${cards.length}_${front.hashCode}',
            front: front.trim(),
            back: explanation != null && explanation.isNotEmpty
                ? '$back\n\n$explanation'
                : back.trim(),
            mastery: 0,
            nextDue: DateTime.now(),
          ));
        }
      } catch (e) {
        debugPrint('[BilanRecapScreen._reviserErreurs] $e');
      }
    }

    if (!mounted) return;
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune erreur trouvee dans les bilans selectionnes.')),
      );
      return;
    }
    cards.shuffle();
    context.push(
      '/flashcards/session',
      extra: FlashcardSessionRouteArgs(
        cards: cards,
        ephemeral: true,
        timed: false,
        survival: false,
      ),
    );
  }

  Future<void> _analyze() async {
    if (_selected.isEmpty) return;

    final aiState = await _aiKeyRepo.watch().first;
    if (!aiState.isConnected || aiState.apiKey == null) {
      setState(() => _errorMessage = 'Configure une cle IA dans les parametres.');
      return;
    }

    final List<Map<String, dynamic>> bilans = [];
    for (final filename in _selected) {
      final raw = await _fs.readFile(EskoliaFolder.bilans, filename);
      if (raw != null) {
        try {
          final decoded = json.decode(raw);
          if (decoded is Map) {
            bilans.add(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          debugPrint('[BilanRecapScreen._analyze] $e');
        }
      }
    }

    if (bilans.isEmpty) {
      setState(() => _errorMessage = 'Impossible de lire les fichiers selectionnes.');
      return;
    }

    setState(() {
      _analyzing = true;
      _analysisBuffer = '';
      _errorMessage = null;
    });

    final bilansJson = jsonEncode(bilans);

    try {
      await for (final chunk in _generator.streamBilanRecap(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        bilansJson: bilansJson,
      )) {
        if (!mounted) break;
        setState(() => _analysisBuffer += chunk);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Erreur IA : $e');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Recap IA de mes quiz'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                12,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                _ExplanationCard(),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: CircularProgressIndicator(color: EskoliaTokens.cyan))
                else if (_files.isEmpty)
                  _EmptyState(onRefresh: _loadFiles)
                else ...[
                  _FileSelector(
                    files: _files,
                    selected: _selected,
                    onToggle: (f) => setState(() {
                      if (_selected.contains(f)) {
                        _selected.remove(f);
                      } else {
                        _selected.add(f);
                      }
                    }),
                    onSelectAll: () => setState(() {
                      if (_selected.length == _files.length) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(_files);
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: (_selected.isEmpty || _analyzing) ? null : _analyze,
                    style: FilledButton.styleFrom(
                      backgroundColor: EskoliaTokens.violetSoft,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _analyzing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_analyzing ? 'Analyse en cours...' : 'Analyser mes lacunes'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: (_selected.isEmpty || _analyzing) ? null : _reviserErreurs,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EskoliaTokens.cyan,
                      side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.4)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.style_rounded, size: 18),
                    label: const Text('Reviser mes erreurs (flashcards)'),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],
                  if (_analysisBuffer.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: EskoliaTokens.violetSoft.withValues(alpha: 0.3)),
                      ),
                      child: MarkdownBody(
                        data: _analysisBuffer,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          h2: const TextStyle(color: EskoliaTokens.cyan, fontSize: 16, fontWeight: FontWeight.w600),
                          h3: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          p: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                          listBullet: const TextStyle(color: EskoliaTokens.textSecondary),
                          strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          blockquote: const TextStyle(color: EskoliaTokens.amber, fontStyle: FontStyle.italic),
                          blockquoteDecoration: BoxDecoration(
                            color: EskoliaTokens.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border(left: BorderSide(color: EskoliaTokens.amber.withValues(alpha: 0.5), width: 3)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EskoliaTokens.cyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: EskoliaTokens.cyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'Comment ça marche ?',
                style: GoogleFonts.outfit(color: EskoliaTokens.cyan, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Apres chaque quiz, sauvegarde ton bilan via le bouton "Sauvegarder mon bilan".\n'
            '2. Configure ton dossier Eskolia dans les parametres pour que les fichiers s\'y enregistrent.\n'
            '3. Reviens ici, selectionne les bilans a analyser, et l\'IA identifie tes lacunes recurrentes.',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, color: EskoliaTokens.textSecondary.withValues(alpha: 0.5), size: 52),
            const SizedBox(height: 12),
            Text(
              'Aucun bilan trouve dans Eskolia/Bilans/',
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Configure ton dossier Eskolia dans les parametres\npuis sauvegarde tes bilans apres chaque quiz.',
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: EskoliaTokens.cyan,
                side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.4)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileSelector extends StatelessWidget {
  const _FileSelector({
    required this.files,
    required this.selected,
    required this.onToggle,
    required this.onSelectAll,
  });

  final List<String> files;
  final Set<String> selected;
  final void Function(String) onToggle;
  final VoidCallback onSelectAll;

  String _label(String filename) {
    return filename
        .replaceAll('bilan_', '')
        .replaceAll('.json', '')
        .replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = selected.length == files.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${files.length} bilan(s) disponible(s)',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
            TextButton(
              onPressed: onSelectAll,
              style: TextButton.styleFrom(foregroundColor: EskoliaTokens.cyan, padding: EdgeInsets.zero),
              child: Text(allSelected ? 'Tout deselectionner' : 'Tout selectionner', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: files.map((f) {
              final isSelected = selected.contains(f);
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                dense: true,
                value: isSelected,
                activeColor: EskoliaTokens.violetSoft,
                checkColor: Colors.white,
                title: Text(
                  _label(f),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  f,
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 11),
                ),
                onChanged: (_) => onToggle(f),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
