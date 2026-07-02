import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/utils/eskolia_icons.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/presentation/widgets/home_card_settings_dialog.dart';
import '../../data/note_model.dart';
import '../../data/notebook_repository.dart';
import '../../../../shared/widgets/eskolia_card.dart';

import '../../../../core/utils/eskolia_snackbar.dart';
import '../../../../core/services/eskolia_folder_service.dart';
import '../../../ai/data/ai_key_repository.dart';
import '../../data/note_ai_generator.dart';
import '../../data/saved_quiz_repository.dart';
import '../../../quiz/services/quiz_repository.dart';
import '../../../flashcards/data/flashcard_deck_repository.dart';
import '../../../flashcards/presentation/flashcard_session_screen.dart';
import 'notebook_shared_models.dart';

class HomeNoteCard extends ConsumerStatefulWidget {
  const HomeNoteCard({super.key, required this.noteId});
  final String noteId;

  @override
  ConsumerState<HomeNoteCard> createState() => _HomeNoteCardState();
}

class _HomeNoteCardState extends ConsumerState<HomeNoteCard> {
  final _repo = NotebookRepository();
  NoteModel? _note;
  bool _loading = true;

  // Options de génération par défaut
  bool _wantCours = true;
  bool _wantQuiz = true;
  bool _wantFlashcards = false;

  late TextEditingController _contentController;
  Timer? _debounceTimer;

  // AI Generation State
  bool _generating = false;
  String _generationPhase = '';
  List<NotebookSubjectResult> _results = [];
  String? _errorMessage;
  String? _flashcardJson;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _loadNote();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      final list = await _repo.loadAll();
      final matched = list.firstWhere((n) => n.id == widget.noteId);
      if (matched.title != _note?.title ||
          matched.content != _note?.content ||
          matched.aiResultsJson != _note?.aiResultsJson ||
          matched.aiFlashcardsJson != _note?.aiFlashcardsJson) {
        if (mounted) {
          List<NotebookSubjectResult> resList = [];
          if (matched.aiResultsJson != null) {
            try {
              final list = jsonDecode(matched.aiResultsJson!) as List;
              resList = list.map((e) {
                final m = e as Map<String, dynamic>;
                return NotebookSubjectResult(
                  subject: m['subject'] ?? '',
                  course: m['course'] ?? '',
                  quizJson: m['quizJson'] ?? '',
                );
              }).toList();
            } catch (_) {}
          }
          setState(() {
            _note = matched;
            _results = resList;
            _flashcardJson = matched.aiFlashcardsJson;
            _loading = false;
          });
          if (_contentController.text != matched.content) {
            _contentController.text = matched.content;
          }
        }
      } else {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onContentChanged(String val) {
    if (_note == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final updated = _note!.copyWith(content: val);
      await _repo.save(updated);
      _note = updated;
    });
  }

  Future<void> _generate() async {
    if (_generating || _note == null) return;
    final aiState = await AiKeyRepository().load();
    if (aiState.apiKey == null || aiState.apiKey!.isEmpty) {
      showEskoliaSnackBar(context, 'Configure d\'abord une clé API Gemini dans les réglages.');
      return;
    }

    final prompt = _contentController.text.trim();
    if (prompt.isEmpty) {
      showEskoliaSnackBar(context, 'Écris au moins une note avant de générer.');
      return;
    }

    setState(() {
      _generating = true;
      _generationPhase = 'Analyse de la note...';
      _results = [];
      _flashcardJson = null;
      _errorMessage = null;
    });

    final aiGenerator = NoteAiGenerator();

    try {
      if (_wantCours || _wantQuiz) {
        final label = (_wantCours && _wantQuiz)
            ? 'Génération des cours et quiz...'
            : _wantCours
                ? 'Génération des cours...'
                : 'Génération des quiz...';
        setState(() => _generationPhase = label);

        final buf = StringBuffer();

        if (_wantCours && _wantQuiz) {
          await for (final t in aiGenerator.streamCombined(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            final subject = (m['subject'] as String?)?.trim() ?? 'Sujet';
            final rawQ    = (m['quiz'] as List?) ?? [];
            return NotebookSubjectResult(
              subject:  subject,
              course:   (m['course'] as String?)?.trim() ?? '',
              quizJson: jsonEncode({'quiz': {'title': subject, 'description': '', 'author': 'IA Notebook'}, 'questions': rawQ}),
            );
          }).toList();
        } else if (_wantCours) {
          await for (final t in aiGenerator.streamMultiCourse(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            return NotebookSubjectResult(
              subject:  (m['subject'] as String?)?.trim() ?? 'Sujet',
              course:   (m['course'] as String?)?.trim() ?? '',
              quizJson: '{}',
            );
          }).toList();
        } else {
          await for (final t in aiGenerator.streamMultiQuiz(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            final subject = (m['subject'] as String?)?.trim() ?? 'Sujet';
            final rawQ    = (m['questions'] as List?) ?? [];
            return NotebookSubjectResult(
              subject:  subject,
              course:   '',
              quizJson: jsonEncode({'quiz': {'title': subject, 'description': '', 'author': 'IA Notebook'}, 'questions': rawQ}),
            );
          }).toList();
        }
        setState(() => _errorMessage = null);
      }

      if (_wantFlashcards && mounted) {
        setState(() => _generationPhase = 'Génération des flashcards...');
        final buf = StringBuffer();
        await for (final t in aiGenerator.streamFlashcards(
          apiKey: aiState.apiKey!, provider: aiState.provider,
          noteContent: prompt, noteTitle: _note!.title.isEmpty ? 'Notes' : _note!.title,
        )) {
          if (!mounted) return;
          buf.write(t);
        }
        if (!mounted) return;
        setState(() => _flashcardJson = NoteAiGenerator.extractJson(buf.toString()));
      }

      // Sauvegarde des résultats IA dans la note en base de données
      final updatedNote = _note!.copyWith(
        aiResultsJson: _results.isNotEmpty
            ? jsonEncode(_results.map((r) => {
                'subject': r.subject,
                'course': r.course,
                'quizJson': r.quizJson,
              }).toList())
            : null,
        aiFlashcardsJson: _flashcardJson,
      );
      await _repo.save(updatedNote);
      _note = updatedNote;
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  final _fs = EskoliaFolderService.instance;

  String _safeName(String subject) =>
      subject.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();

  Future<void> _downloadCourse(NotebookSubjectResult item) => _fs.saveFile(
        EskoliaFolder.cours,
        'cours_${_safeName(item.subject)}.md',
        item.course,
        mimeType: 'text/markdown',
      );

  Future<void> _downloadQuiz(NotebookSubjectResult item) => _fs.saveFile(
        EskoliaFolder.quiz,
        'quiz_${_safeName(item.subject)}.json',
        item.quizJson,
        mimeType: 'application/json',
      );

  Future<void> _downloadFlashcards() => _fs.saveFile(
        EskoliaFolder.flashcards,
        'flashcards_${_safeName(_note!.title.isEmpty ? 'note' : _note!.title)}.json',
        _flashcardJson ?? '',
        mimeType: 'application/json',
      );

  Future<void> _playFlashcards() async {
    if (_flashcardJson == null) return;
    try {
      final data = jsonDecode(_flashcardJson!) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>? ?? [];
      final cards = <DeckFlashcard>[];
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        cards.add(DeckFlashcard(
          id: 'fc_$i',
          front: q['question'] ?? '',
          back: q['answer'] ?? '',
          mastery: 0,
          nextDue: DateTime.now(),
        ));
      }
      if (mounted) {
        context.push('/flashcards/session', extra: FlashcardSessionRouteArgs(cards: cards, ephemeral: true));
      }
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors du décodage des flashcards.');
    }
  }

  Future<void> _playQuiz(NotebookSubjectResult item) async {
    try {
      final session = await QuizRepository().buildFromNotebookQuizJson(
        item.quizJson,
        item.subject,
      );
      if (mounted) context.push('/quiz/run', extra: session);
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur inattendue — régénère le quiz.');
    }
  }

  Future<void> _saveQuiz(NotebookSubjectResult item) async {
    try {
      await QuizRepository().buildFromNotebookQuizJson(item.quizJson, 'check');
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
      return;
    }
    await SavedQuizRepository().save(SavedNotebookQuiz.create(
      title:   item.subject,
      rawJson: item.quizJson,
    ));
    if (mounted) showEskoliaSnackBar(context, 'Quiz sauvegardé dans Mes quiz IA.');
  }

  Future<void> _saveAndDownloadQuiz(NotebookSubjectResult item) async {
    await _saveQuiz(item);
    await _downloadQuiz(item);
  }

  void _openCourseSheet(NotebookSubjectResult item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotebookCourseSheet(
        result:          item,
        onPlayQuiz:      () { Navigator.of(context).pop(); _playQuiz(item); },
        onDownloadQuiz:  () => _downloadQuiz(item),
        onDownloadCourse: () => _downloadCourse(item),
      ),
    );
  }

  Future<void> _deleteNote() async {
    if (_note == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Supprimer la note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Es-tu sûr de vouloir supprimer cette note ?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: EskoliaTokens.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: EskoliaTokens.error),
            child: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _repo.delete(_note!.id);
      ref.read(homeCardsOrderProvider.notifier).removeCard('note:${_note!.id}');
    }
  }

  Widget _buildSelectionChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: selected ? color : Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: selected ? color : Colors.white38,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.violetSoft),
          ),
        ),
      );
    }

    if (_note == null) {
      return EskoliaCardContent(
        accentBorderColor: EskoliaTokens.violetSoft,
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Note supprimée ou introuvable',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60, size: 18),
              onPressed: () => ref.read(homeCardsOrderProvider.notifier).removeCard('note:${widget.noteId}'),
            ),
          ],
        ),
      );
    }

    final title = _note!.title.trim().isEmpty ? 'Sans titre' : _note!.title;

    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['note:${widget.noteId}'];
    final isCollapsed = settings?.isCollapsed ?? false;
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '📝';
    final accentColor = settings != null ? Color(settings.colorHex) : EskoliaTokens.violetSoft;

    final isPinnedLocally = ref.watch(notebookPinnedNotesProvider).contains(_note!.id);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('note:${_note!.id}');

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(homeCardSettingsProvider.notifier).toggleCollapse('note:${widget.noteId}');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EskoliaCardSectionBadge(
                  sectionName: 'NOTE',
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Icon(
                  getIconDataForEmoji(displayEmoji),
                  color: accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white60, size: 20),
                  onPressed: () => showHomeCardSettingsDialog(
                    context,
                    ref,
                    'note:${widget.noteId}',
                    defaultTitleOverride: title,
                    defaultColorOverride: EskoliaTokens.violetSoft,
                  ),
                  tooltip: 'Personnaliser',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: isCollapsed ? Colors.white60 : accentColor,
                    size: 18,
                  ),
                  onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse('note:${widget.noteId}'),
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isPinnedLocally ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: isPinnedLocally ? accentColor : Colors.white30,
                    size: 18,
                  ),
                  onPressed: () {
                    ref.read(notebookPinnedNotesProvider.notifier).togglePin(_note!.id);
                  },
                  tooltip: isPinnedLocally ? 'Désépingler' : 'Épingler',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isAddedToHome ? EskoliaTokens.cyan : Colors.white30,
                    size: 18,
                  ),
                  onPressed: () {
                    if (isAddedToHome) {
                      ref.read(homeCardsOrderProvider.notifier).removeCard('note:${_note!.id}');
                    } else {
                      ref.read(homeCardsOrderProvider.notifier).addCard('note:${_note!.id}');
                    }
                  },
                  tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 18),
                  onPressed: _deleteNote,
                  tooltip: 'Supprimer la note',
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      hintText: 'Écris ton mémo ici...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _onContentChanged,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        _buildSelectionChip(
                          label: 'Cours',
                          icon: Icons.menu_book_rounded,
                          selected: _wantCours,
                          color: EskoliaTokens.violetSoft,
                          onTap: () => setState(() => _wantCours = !_wantCours),
                        ),
                        _buildSelectionChip(
                          label: 'Quiz',
                          icon: Icons.extension_rounded,
                          selected: _wantQuiz,
                          color: EskoliaTokens.cyan,
                          onTap: () => setState(() => _wantQuiz = !_wantQuiz),
                        ),
                        _buildSelectionChip(
                          label: 'Flashcards',
                          icon: Icons.style_rounded,
                          selected: _wantFlashcards,
                          color: Colors.amber,
                          onTap: () => setState(() => _wantFlashcards = !_wantFlashcards),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: (_generating || (!_wantCours && !_wantQuiz && !_wantFlashcards))
                          ? null
                          : _generate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white10,
                        disabledForegroundColor: Colors.white30,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            _generating ? 'Génération...' : 'Générer',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ── AI generation status / results ────────────────────────────
                if (_generating) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.violetSoft),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _generationPhase,
                          style: const TextStyle(color: Colors.white60, fontSize: 11.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EskoliaTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: EskoliaTokens.error.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: EskoliaTokens.error, fontSize: 11.5),
                    ),
                  ),
                ],
                if (_results.isNotEmpty || _flashcardJson != null) ...[
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'CONTENUS GÉNÉRÉS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _results.isNotEmpty ? _results.first.subject : 'Flashcards',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_results.isNotEmpty && _results.first.hasCourse) ...[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _openCourseSheet(_results.first),
                                      icon: const Icon(Icons.menu_book_rounded, size: 11, color: Colors.black),
                                      label: const Text('Lire cours', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: EskoliaTokens.violetSoft,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 34),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await _downloadCourse(_results.first);
                                        if (mounted) showEskoliaSnackBar(context, 'Cours sauvegardé.');
                                      },
                                      icon: const Icon(Icons.download_rounded, size: 11, color: EskoliaTokens.violetSoft),
                                      label: const Text('Sauver cours', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_results.isNotEmpty && _results.first.hasCourse && _results.first.hasQuiz) const SizedBox(width: 8),
                            if (_results.isNotEmpty && _results.first.hasQuiz) ...[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _playQuiz(_results.first),
                                      icon: const Icon(Icons.sports_esports_rounded, size: 11, color: Colors.black),
                                      label: const Text('Lancer Quiz', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: EskoliaTokens.cyan,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 34),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton.icon(
                                      onPressed: () => _saveAndDownloadQuiz(_results.first),
                                      icon: const Icon(Icons.download_rounded, size: 11, color: EskoliaTokens.cyan),
                                      label: const Text('Sauver quiz', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_results.isNotEmpty && (_results.first.hasCourse || _results.first.hasQuiz) && _flashcardJson != null) const SizedBox(width: 8),
                            if (_flashcardJson != null) ...[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _playFlashcards,
                                      icon: const Icon(Icons.style_rounded, size: 11, color: Colors.black),
                                      label: const Text('Lancer Flashcard', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 34),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await _downloadFlashcards();
                                        if (mounted) showEskoliaSnackBar(context, 'Flashcards sauvegardées.');
                                      },
                                      icon: const Icon(Icons.download_rounded, size: 11, color: Colors.amber),
                                      label: const Text('Sauver flashcard', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            crossFadeState: !isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
