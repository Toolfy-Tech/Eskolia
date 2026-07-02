import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/note_model.dart';
import '../../data/notebook_repository.dart';

class NotebookCardBody extends ConsumerStatefulWidget {
  const NotebookCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<NotebookCardBody> createState() => _NotebookCardBodyState();
}

class _NotebookCardBodyState extends ConsumerState<NotebookCardBody> {
  final _repo = NotebookRepository();
  List<NoteModel> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final list = await _repo.loadAll();
      if (mounted) {
        setState(() {
          _notes = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createNewNote() async {
    final note = NoteModel.create(title: '', content: '');
    await context.push('/notebook/edit', extra: note);
    _loadNotes();
  }

  Future<void> _editNote(NoteModel note) async {
    await context.push('/notebook/edit', extra: note);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:notebook']?.isCollapsed ?? false);

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.success),
          ),
        ),
      );
    }

    if (isCollapsed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.note_alt_rounded, color: EskoliaTokens.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _notes.isEmpty
                        ? 'Aucune note dans le carnet'
                        : _notes.length == 1
                            ? '1 note enregistrée'
                            : '${_notes.length} notes enregistrées',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/notebook'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Ouvrir Carnet', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createNewNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EskoliaTokens.success,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Créer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Extended Mode (Keep style list of notes)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_notes.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: const Column(
              children: [
                Text(
                  'Carnet vide',
                  style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Cliquez sur Créer pour rédiger votre première note.',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.35,
            ),
            itemCount: _notes.take(4).length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              final title = note.title.trim().isEmpty ? 'Sans titre' : note.title;
              final preview = note.content.trim().isEmpty
                  ? 'Pas de contenu'
                  : note.content.trim().length > 35
                      ? '${note.content.trim().substring(0, 35)}...'
                      : note.content.trim();

              final isPinned = ref.watch(homeCardsOrderProvider).contains('note:${note.id}');

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _editNote(note),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (isPinned) {
                                    ref.read(homeCardsOrderProvider.notifier).removeCard('note:${note.id}');
                                  } else {
                                    ref.read(homeCardsOrderProvider.notifier).addCard('note:${note.id}');
                                  }
                                },
                                child: Icon(
                                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                                  color: isPinned ? EskoliaTokens.success : Colors.white24,
                                  size: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              preview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 9.5,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/notebook'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Voir toutes les notes',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _createNewNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.success,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Créer une note', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
