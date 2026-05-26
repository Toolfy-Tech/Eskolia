import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/note_model.dart';
import '../data/notebook_repository.dart';

const Color _bg = Color(0xFF0B1120);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final _repo = NotebookRepository();
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _notesFuture = _repo.loadAll();
    });
  }

  Future<void> _openEditor(NoteModel? note) async {
    await context.push('/notebook/edit', extra: note);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Mon Carnet', showBack: false),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _violet,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add_rounded),
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          FutureBuilder<List<NoteModel>>(
            future: _notesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _violet),
                );
              }
              final notes = snap.data ?? const [];
              if (notes.isEmpty) {
                return _EmptyState(onTap: () => _openEditor(null));
              }
              return RefreshIndicator(
                color: _violet,
                onRefresh: () async => _load(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NoteCard(
                        note: note,
                        onTap: () => _openEditor(note),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Carte de note ─────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final NoteModel note;
  final VoidCallback onTap;

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

  @override
  Widget build(BuildContext context) {
    final title =
        note.title.trim().isEmpty ? 'Sans titre' : note.title.trim();
    final preview = note.content.trim().isEmpty
        ? ''
        : note.content.trim().length > 80
            ? '${note.content.trim().substring(0, 80)}...'
            : note.content.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A2E),
            borderRadius: BorderRadius.circular(14),
            border: const Border(
              left: BorderSide(color: _violet, width: 3),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: _slate.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Etat vide ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _violet.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                color: _violet,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ton carnet est vide',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Prends des notes, genere des mini-cours et des quiz avec l\'IA.',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_rounded, color: _violet),
              label: const Text(
                'Creer ma premiere note',
                style: TextStyle(color: _violet, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
