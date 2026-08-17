import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import '../data/note_model.dart';
import '../data/notebook_repository.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/utils/eskolia_icons.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../ai/data/ai_key_repository.dart';
import '../data/note_ai_generator.dart';
import '../data/saved_quiz_repository.dart';
import '../../quiz/services/quiz_repository.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';
import 'widgets/notebook_shared_models.dart';

const Color _bg = EskoliaTokens.bgBase;
const Color _violet = EskoliaTokens.violetSoft;
const Color _slate = EskoliaTokens.textSecondary;

const List<int> _accentColorsList = [
  0xFF7C4DFF, // Violet Soft
  0xFF00E5FF, // Cyan
  0xFFFFC107, // Amber
  0xFF00E676, // Success Green
  0xFFFF5722, // Orange
  0xFFFF2A6D, // Rose/Neon pink
  0xFF9C27B0, // Purple
  0xFF3F51B5, // Indigo
];

class NotebookScreen extends ConsumerStatefulWidget {
  const NotebookScreen({super.key});

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  final _repo = NotebookRepository();
  late Future<List<NoteModel>> _notesFuture;

  final Map<String, GlobalKey> _cardKeys = {};
  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  GlobalKey _getOrCreateKey(String cardKey) {
    return _cardKeys.putIfAbsent(cardKey, () => GlobalKey(debugLabel: cardKey));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dragDebounceTimer?.cancel();
    super.dispose();
  }

  void _load() {
    setState(() {
      _notesFuture = _repo.loadAll();
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: Colors.white12,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(String key, Widget child, double width) {
    final isWebOrDesktop = kIsWeb || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux;

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.015,
        child: Transform.scale(
          scale: 1.02,
          child: Opacity(
            opacity: 0.85,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    return DragTarget<String>(
      key: _getOrCreateKey(key),
      onWillAcceptWithDetails: (details) {
        final dragKey = details.data;
        if (dragKey != key) {
          if (_hoveredDragKey != key) {
            _hoveredDragKey = key;
            _dragDebounceTimer?.cancel();
            _dragDebounceTimer = Timer(const Duration(milliseconds: 60), () {
              if (mounted && _hoveredDragKey == key) {
                final pinned = ref.read(notebookPinnedNotesProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(notebookPinnedNotesProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(notebookNotesOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(notebookNotesOrderProvider.notifier).reorder(oldIdx, newIdx);
                }
              }
            });
          }
        }
        return true;
      },
      onLeave: (data) {
        if (_hoveredDragKey == key) {
          _dragDebounceTimer?.cancel();
          _hoveredDragKey = null;
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        final cardWidget = SizedBox(
          width: width,
          child: child,
        );

        final mainChild = LongPressDraggable<String>(
          key: ValueKey('${key}_drag'),
          data: key,
          delay: const Duration(milliseconds: 700),
          feedback: feedbackWidget,
          childWhenDragging: Opacity(
            opacity: 0.15,
            child: cardWidget,
          ),
          child: cardWidget,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? EskoliaTokens.cyan.withValues(alpha: 0.8) : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: mainChild,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    final width = MediaQuery.sizeOf(context).width;

    final isLargeScreen = width >= 700;
    final sidebarWidth = isLargeScreen ? (ref.watch(sidebarCollapsedProvider) ? 78.0 : 250.0) : 0.0;
    final availableWidth = (width - sidebarWidth - 32).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('notebook'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final order = ref.watch(notebookNotesOrderProvider);
    final pinned = ref.watch(notebookPinnedNotesProvider);

    List<Widget> addSpacing(List<Widget> list) {
      if (list.isEmpty) return [];
      final res = <Widget>[];
      for (var i = 0; i < list.length; i++) {
        res.add(list[i]);
        if (i < list.length - 1) {
          res.add(const SizedBox(height: 16));
        }
      }
      return res;
    }

    Widget buildGrid(List<NoteModel> list, {required bool includeAddCard}) {
      final cards = <Widget>[];

      if (includeAddCard) {
        cards.add(
          _AddNoteGridCard(onNoteCreated: _load),
        );
      }

      cards.addAll(
        list.map((note) {
          return _buildDraggableCard(
            note.id,
            _NoteCard(
              key: ValueKey(note.id),
              note: note,
              onDeleted: _load,
            ),
            cardWidth,
          );
        }).toList()
      );

      final columns = distributeMasonryColumns<Widget>(
        items: cards,
        numColumns: numColumns,
        estimateHeight: (card) {
          if (card is _AddNoteGridCard) return 100.0;
          return 200.0;
        },
      );

      return buildMasonryColumnsRow(columns: columns);
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: FutureBuilder<List<NoteModel>>(
              future: _notesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _violet),
                  );
                }
                final notes = snap.data ?? const [];

                // Mettre à jour et synchroniser l'ordre de tri
                final allIds = notes.map((n) => n.id).toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ref.read(notebookNotesOrderProvider.notifier).updateOrder(allIds);
                  }
                });

                // Trier les notes
                final sortedNotes = List<NoteModel>.from(notes);
                sortedNotes.sort((a, b) {
                  final idxA = order.indexOf(a.id);
                  final idxB = order.indexOf(b.id);
                  if (idxA == -1 && idxB == -1) return 0;
                  if (idxA == -1) return 1;
                  if (idxB == -1) return -1;
                  return idxA.compareTo(idxB);
                });

                final pinnedNotes = sortedNotes.where((note) => pinned.contains(note.id)).toList();
                final otherNotes = sortedNotes.where((note) => !pinned.contains(note.id)).toList();

                Widget gridContent;
                if (notes.isEmpty) {
                  gridContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Mes Notes'),
                      buildGrid([], includeAddCard: true),
                    ],
                  );
                } else if (pinnedNotes.isEmpty) {
                  gridContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Mes Notes'),
                      buildGrid(notes, includeAddCard: true),
                    ],
                  );
                } else {
                  gridContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Épinglées'),
                      buildGrid(pinnedNotes, includeAddCard: true),
                      if (otherNotes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('Autres'),
                        buildGrid(otherNotes, includeAddCard: false),
                      ],
                    ],
                  );
                }

                final noteCardOptions = notes.map((n) {
                  final t = n.title.trim().isEmpty ? 'Sans titre' : n.title.trim();
                  return EskoliaCardOption(key: 'note:${n.id}', title: t, emoji: '📝');
                }).toList();

                final noteKeys = notes.map((n) => 'note:${n.id}').toList();

                final listContent = ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    EskoliaPageHeaderToolbar(
                      title: 'Mon Carnet',
                      screenKey: 'notebook',
                      onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(noteKeys),
                      onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(noteKeys),
                      availableCards: noteCardOptions,
                      maxColumns: 4,
                    ),
                    const SizedBox(height: 12),
                    gridContent,
                  ],
                );

                return RefreshIndicator(
                  color: _violet,
                  onRefresh: () async => _load(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width > 800
                            ? double.infinity
                            : EskoliaLayout.shellContentMaxWidth,
                      ),
                      child: listContent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte de note ─────────────────────────────────────────────────────────────

class _NoteCard extends ConsumerStatefulWidget {
  const _NoteCard({super.key, required this.note, this.onDeleted});

  final NoteModel note;
  final VoidCallback? onDeleted;

  @override
  ConsumerState<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<_NoteCard> {
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
    _contentController = TextEditingController(text: widget.note.content);
    if (widget.note.aiResultsJson != null) {
      try {
        final list = jsonDecode(widget.note.aiResultsJson!) as List;
        _results = list.map((e) {
          final m = e as Map<String, dynamic>;
          return NotebookSubjectResult(
            subject: m['subject'] ?? '',
            course: m['course'] ?? '',
            quizJson: m['quizJson'] ?? '',
          );
        }).toList();
      } catch (_) {}
    }
    if (widget.note.aiFlashcardsJson != null) {
      _flashcardJson = widget.note.aiFlashcardsJson;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final updated = widget.note.copyWith(content: val);
      await NotebookRepository().save(updated);
    });
  }

  Future<void> _generate() async {
    if (_generating) return;
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
          noteContent: prompt, noteTitle: widget.note.title.isEmpty ? 'Notes' : widget.note.title,
        )) {
          if (!mounted) return;
          buf.write(t);
        }
        if (!mounted) return;
        setState(() => _flashcardJson = NoteAiGenerator.extractJson(buf.toString()));
      }

      // Sauvegarde des résultats IA dans la note en base de données
      final updatedNote = widget.note.copyWith(
        aiResultsJson: _results.isNotEmpty
            ? jsonEncode(_results.map((r) => {
                'subject': r.subject,
                'course': r.course,
                'quizJson': r.quizJson,
              }).toList())
            : null,
        aiFlashcardsJson: _flashcardJson,
      );
      await NotebookRepository().save(updatedNote);

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
        'flashcards_${_safeName(widget.note.title.isEmpty ? 'note' : widget.note.title)}.json',
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'il y a quelques secondes';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'hier';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} jours';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Future<void> _deleteNote() async {
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
      await NotebookRepository().delete(widget.note.id);
      ref.read(homeCardsOrderProvider.notifier).removeCard('note:${widget.note.id}');
      widget.onDeleted?.call();
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
    final title = widget.note.title.trim().isEmpty ? 'Sans titre' : widget.note.title.trim();

    final isPinnedLocally = ref.watch(notebookPinnedNotesProvider).contains(widget.note.id);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('note:${widget.note.id}');

    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['note:${widget.note.id}'];
    final isCollapsed = settings?.isCollapsed ?? false;
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final displayEmoji = settings?.emoji.isNotEmpty == true ? settings!.emoji : '📝';
    final accentColor = settings != null ? Color(settings.colorHex) : (isPinnedLocally ? _violet : Colors.white24);

    return EskoliaCardContent(
      accentBorderColor: settings != null ? accentColor : (isPinnedLocally ? _violet : null),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ref.read(homeCardSettingsProvider.notifier).toggleCollapse('note:${widget.note.id}');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EskoliaCardSectionBadge(
                  sectionName: 'NOTE',
                  color: accentColor,
                ),
                const SizedBox(width: 10),
                Icon(
                  getIconDataForEmoji(displayEmoji),
                  color: accentColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayTitle,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white60, size: 20),
                  onPressed: () => showHomeCardSettingsDialog(
                    context,
                    ref,
                    'note:${widget.note.id}',
                    defaultTitleOverride: title,
                    defaultColorOverride: EskoliaTokens.violetSoft,
                  ),
                  tooltip: 'Personnaliser',
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: isCollapsed ? Colors.white60 : accentColor,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(homeCardSettingsProvider.notifier).toggleCollapse('note:${widget.note.id}');
                  },
                  tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isPinnedLocally ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: isPinnedLocally ? _violet : Colors.white30,
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(notebookPinnedNotesProvider.notifier).togglePin(widget.note.id);
                  },
                  tooltip: isPinnedLocally ? 'Désépingler' : 'Épingler',
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isAddedToHome ? EskoliaTokens.cyan : Colors.white30,
                    size: 20,
                  ),
                  onPressed: () {
                    if (isAddedToHome) {
                      ref.read(homeCardsOrderProvider.notifier).removeCard('note:${widget.note.id}');
                    } else {
                      ref.read(homeCardsOrderProvider.notifier).addCard('note:${widget.note.id}');
                    }
                  },
                  tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 20),
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 14),
                Text(
                  _formatDate(widget.note.updatedAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                const SizedBox(height: 12),
                Text(
                  'OPTIONS DE GÉNÉRATION IA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
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
                        backgroundColor: accentColor == Colors.white24 ? _violet : accentColor,
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

// ── Carte d'ajout de note ─────────────────────────────────────────────────────

class _AddNoteGridCard extends ConsumerStatefulWidget {
  const _AddNoteGridCard({required this.onNoteCreated});
  final VoidCallback onNoteCreated;

  @override
  ConsumerState<_AddNoteGridCard> createState() => _AddNoteGridCardState();
}

class _AddNoteGridCardState extends ConsumerState<_AddNoteGridCard> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final note = NoteModel.create(
        title: title.isEmpty ? 'Sans titre' : title,
        content: content,
      );
      await NotebookRepository().save(note);

      // Assigner une couleur de cadre aléatoire directement sur la note à la création
      final randomColor = (List<int>.from(_accentColorsList)..shuffle()).first;
      await ref.read(homeCardSettingsProvider.notifier).updateSettings(
        'note:${note.id}',
        HomeCardSettings(
          title: title.isEmpty ? 'Sans titre' : title,
          emoji: '📝',
          colorHex: randomColor,
          isCollapsed: false,
        ),
      );
      
      _titleController.clear();
      _contentController.clear();
      widget.onNoteCreated();
      if (mounted) {
        setState(() => _isSaving = false);
        showEskoliaSnackBar(context, 'Note créée !');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        showEskoliaSnackBar(context, 'Erreur de sauvegarde');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      accentBorderColor: EskoliaTokens.violetSoft.withValues(alpha: 0.6),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              EskoliaCardSectionBadge(
                sectionName: 'NOUVEAU',
                color: EskoliaTokens.violetSoft,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AJOUTER UNE NOTE',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              hintText: 'Titre... (facultatif)',
              hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: 4,
            minLines: 2,
            keyboardType: TextInputType.multiline,
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
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _contentController.text.trim().isEmpty || _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.black),
                      )
                    : const Icon(Icons.add_rounded, size: 14, color: Colors.black),
                label: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.violetSoft,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
