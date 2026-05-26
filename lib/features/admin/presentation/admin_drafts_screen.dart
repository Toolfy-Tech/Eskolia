import 'package:flutter/material.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../labo/data/labo_question_draft.dart';
import '../../labo/data/labo_question_draft_repository.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _red = Color(0xFFE53935);

String _draftStatusFr(String s) {
  switch (s) {
    case 'pending':
      return 'En attente';
    case 'approved':
      return 'Validé';
    case 'rejected':
      return 'Refusé';
    default:
      return s;
  }
}

class AdminDraftsScreen extends StatelessWidget {
  const AdminDraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LaboQuestionDraftRepository();

    return StaffGateScaffold(
            title: 'Brouillons',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _bg,
        appBar: EskoliaAppBar.standard(context, title: 'Brouillons questions'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: StreamBuilder<List<LaboQuestionDraft>>(
                stream: repo.watchRecentDrafts(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '${snap.error}',
                          style: const TextStyle(color: _slate),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: _violet),
                    );
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun brouillon.',
                        style: TextStyle(color: _slate.withValues(alpha: 0.9)),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      EskoliaLayout.screenPaddingH,
                      8,
                      EskoliaLayout.screenPaddingH,
                      EskoliaLayout.screenPaddingBottom,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final d = list[i];
                      return _DraftTile(
                        draft: d,
                        onStatus: (status) => repo.setDraftStatus(d.id, status),
                        onDelete: () => repo.deleteDraft(d.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.draft,
    required this.onStatus,
    this.onDelete,
  });

  final LaboQuestionDraft draft;
  final Future<void> Function(String status) onStatus;
  final Future<void> Function()? onDelete;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Supprimer définitivement ?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Cette action est irréversible.',
            style: TextStyle(color: _slate)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await onDelete!();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = draft.createdAt;
    final dateStr = date == null
        ? '—'
        : '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.sectionHint.isEmpty ? '(Sans section)' : draft.sectionHint,
                  style: const TextStyle(
                    color: Color(0xFF43E97B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _draftStatusFr(draft.status),
                  style: const TextStyle(color: _slate, fontSize: 10),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF1A1F2E),
                onSelected: (st) async {
                  try {
                    await onStatus(st);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Statut : ${_draftStatusFr(st)}')),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mise à jour impossible')),
                      );
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'pending', child: Text('En attente')),
                  const PopupMenuItem(value: 'approved', child: Text('Validé')),
                  const PopupMenuItem(value: 'rejected', child: Text('Refusé')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft.statement,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(draft.options.length, (j) {
            final mark = j == draft.correctIndex ? '✓ ' : '   ';
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$mark${String.fromCharCode(65 + j)}. ${draft.options[j]}',
                style: TextStyle(
                  color: j == draft.correctIndex
                      ? const Color(0xFF43E97B)
                      : _slate.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            );
          }),
          if (draft.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              draft.explanation,
              style: TextStyle(
                color: _slate.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '$dateStr · ${draft.difficulty} · auteur ${draft.authorId.length <= 10 ? draft.authorId : '${draft.authorId.substring(0, 8)}…'}',
            style: TextStyle(color: _slate.withValues(alpha: 0.45), fontSize: 10),
          ),
          if (draft.status == 'rejected' && onDelete != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmAndDelete(context),
                icon: const Icon(Icons.delete_forever_rounded,
                    size: 16, color: _red),
                label: const Text('Supprimer définitivement',
                    style: TextStyle(color: _red, fontSize: 12)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
