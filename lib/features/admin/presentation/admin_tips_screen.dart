import 'package:flutter/material.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../labo/data/community_tip.dart';
import '../../labo/data/community_tip_repository.dart';
import 'staff_gate_scaffold.dart';

String _statusFr(String s) {
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

class AdminTipsScreen extends StatelessWidget {
  const AdminTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CommunityTipRepository();

    return StaffGateScaffold(
            title: 'Tips',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(context, title: 'Tips communauté'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: StreamBuilder<List<CommunityTip>>(
                stream: repo.watchAllTips(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '${snap.error}',
                          style: const TextStyle(color: EskoliaTokens.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: EskoliaTokens.violetSoft),
                    );
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun tip.',
                        style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9)),
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
                      final t = list[i];
                      return _TipAdminTile(
                        tip: t,
                        onStatus: (st) => repo.setTipStatus(t.id, st),
                        onDelete: () => repo.deleteTip(t.id),
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

class _TipAdminTile extends StatelessWidget {
  const _TipAdminTile({
    required this.tip,
    required this.onStatus,
    this.onDelete,
  });

  final CommunityTip tip;
  final Future<void> Function(String status) onStatus;
  final Future<void> Function()? onDelete;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Supprimer définitivement ?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Cette action est irréversible.',
            style: TextStyle(color: EskoliaTokens.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: EskoliaTokens.error),
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
    final date = tip.createdAt;
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
                  tip.kind.label,
                  style: const TextStyle(
                    color: EskoliaTokens.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: EskoliaTokens.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusFr(tip.status),
                  style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: EskoliaTokens.surface1,
                onSelected: (st) async {
                  try {
                    await onStatus(st);
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
                  const PopupMenuItem(value: 'approved', child: Text('Validé')),
                  const PopupMenuItem(value: 'rejected', child: Text('Refusé')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'module: ${tip.moduleId}',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.75), fontSize: 11),
          ),
          if (tip.moduleTitle.isNotEmpty)
            Text(
              tip.moduleTitle,
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 10),
            ),
          const SizedBox(height: 8),
          Text(
            tip.body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\u{1F44D} ${tip.upCount} · \u{1F44E} ${tip.downCount}',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.7), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateStr · auteur ${tip.authorId.length <= 10 ? tip.authorId : '${tip.authorId.substring(0, 8)}…'}',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.45), fontSize: 10),
          ),
          if (tip.status == 'rejected' && onDelete != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmAndDelete(context),
                icon: const Icon(Icons.delete_forever_rounded,
                    size: 16, color: EskoliaTokens.error),
                label: const Text('Supprimer définitivement',
                    style: TextStyle(color: EskoliaTokens.error, fontSize: 12)),
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
