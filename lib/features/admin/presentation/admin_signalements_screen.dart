import 'package:flutter/material.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../labo/data/question_report_entry.dart';
import '../data/admin_signalements_repository.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _red = Color(0xFFE53935);

String _shortUid(String uid) {
  if (uid.isEmpty) return '—';
  return uid.length <= 12 ? uid : '${uid.substring(0, 10)}…';
}

String _statusFr(String s) {
  switch (s) {
    case 'pending':
      return 'En attente';
    case 'in_progress':
      return 'En cours';
    case 'resolved':
      return 'Résolu';
    case 'rejected':
      return 'Refusé';
    default:
      return s;
  }
}

class AdminSignalementsScreen extends StatelessWidget {
  const AdminSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AdminSignalementsRepository();

    return StaffGateScaffold(
            title: 'Signalements',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: _bg,
        appBar: EskoliaAppBar.standard(context, title: 'Signalements'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: StreamBuilder<List<QuestionReportEntry>>(
                stream: repo.watchRecent(),
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
                        'Aucun signalement.',
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
                      return _AdminReportTile(
                        entry: list[i],
                        onSetStatus: (st) => repo.updateStatus(list[i].id, st),
                        onDelete: () => repo.deleteSignalement(list[i].id),
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

class _AdminReportTile extends StatelessWidget {
  const _AdminReportTile({
    required this.entry,
    required this.onSetStatus,
    this.onDelete,
  });

  final QuestionReportEntry entry;
  final Future<void> Function(String status) onSetStatus;
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
    final date = entry.createdAt;
    final dateStr = date == null
        ? '—'
        : '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')} '
            '${date.hour.toString().padLeft(2, '0')}:'
            '${date.minute.toString().padLeft(2, '0')}';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.kind.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusFr(entry.status),
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF1A1F2E),
                onSelected: (st) async {
                  try {
                    await onSetStatus(st);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Statut : ${_statusFr(st)}')),
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
                  const PopupMenuItem(value: 'in_progress', child: Text('En cours')),
                  const PopupMenuItem(value: 'resolved', child: Text('Résolu')),
                  const PopupMenuItem(value: 'rejected', child: Text('Refusé')),
                ],
              ),
            ],
          ),
          if (entry.questionPreview != null &&
              entry.questionPreview!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '« ${entry.questionPreview!} »',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.95),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ],
          if (entry.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '$dateStr · user ${_shortUid(entry.reporterId)}',
            style: TextStyle(color: _slate.withValues(alpha: 0.5), fontSize: 10),
          ),
          Text(
            entry.assetPath.isEmpty ? '' : entry.assetPath,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _slate.withValues(alpha: 0.45), fontSize: 10),
          ),
          if (entry.status == 'rejected' && onDelete != null) ...[
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
