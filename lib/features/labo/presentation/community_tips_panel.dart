import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../data/community_tip.dart';
import '../data/community_tip_repository.dart';

const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF43E97B);
const Color _redVote = Color(0xFFEF5350);

/// Astuces validées pour le module courant (Firestore `community_tips`).
class CommunityTipsPanel extends StatelessWidget {
  const CommunityTipsPanel({
    super.key,
    required this.moduleId,
    this.onProposeTip,
  });

  final String moduleId;
  final VoidCallback? onProposeTip;

  @override
  Widget build(BuildContext context) {
    if (moduleId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<CommunityTip>>(
      stream: CommunityTipRepository().watchApprovedForModule(moduleId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Astuces communautaires : indisponibles (réseau ou règles Firestore).',
              style: TextStyle(color: _slate.withValues(alpha: 0.65), fontSize: 11),
            ),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
          );
        }
        final tips = snap.data!;
        if (tips.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Astuces de la communauté',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pas encore d’astuce validée pour ce module.',
                  style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12),
                ),
                if (onProposeTip != null) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onProposeTip,
                    icon: const Icon(Icons.lightbulb_outline, color: _green, size: 20),
                    label: const Text(
                      'Proposer la première',
                      style: TextStyle(color: _green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        final sorted = [...tips]..sort((a, b) {
            final byScore = b.score.compareTo(a.score);
            if (byScore != 0) return byScore;
            return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
          });

        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('\u{1F4A1}', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Astuces de la communauté',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Votes : les plus utiles en premier.',
                style: TextStyle(color: _slate.withValues(alpha: 0.75), fontSize: 11),
              ),
              const SizedBox(height: 12),
              ...sorted.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CommunityTipCard(
                    tip: t,
                    uid: uid,
                  ),
                ),
              ),
              if (onProposeTip != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onProposeTip,
                    icon: const Icon(Icons.add, color: _green, size: 18),
                    label: const Text(
                      'Ajouter une astuce',
                      style: TextStyle(color: _green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CommunityTipCard extends StatefulWidget {
  const _CommunityTipCard({
    required this.tip,
    required this.uid,
  });

  final CommunityTip tip;
  final String? uid;

  @override
  State<_CommunityTipCard> createState() => _CommunityTipCardState();
}

class _CommunityTipCardState extends State<_CommunityTipCard> {
  bool _busy = false;

  Future<void> _vote(BuildContext context, int direction) async {
    if (widget.uid == null || widget.uid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour voter.')),
      );
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await CommunityTipRepository().castTipVote(widget.tip.id, direction);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tip;
    final mine = t.voteOf(widget.uid);
    return GradientBorderCard(
      gradientColors: [
        _green.withValues(alpha: 0.35),
        EskoliaVisual.neonViolet.withValues(alpha: 0.25),
      ],
      glowColor: _green,
      borderRadius: 14,
      innerBlurSigma: 8,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t.kind.label,
              style: const TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                tooltip: 'Utile',
                onPressed: _busy ? null : () => _vote(context, 1),
                icon: Icon(
                  mine == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: mine == 1 ? _green : _slate,
                  size: 22,
                ),
              ),
              Text(
                '${t.upCount}',
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Pas utile',
                onPressed: _busy ? null : () => _vote(context, -1),
                icon: Icon(
                  mine == -1 ? Icons.thumb_down : Icons.thumb_down_outlined,
                  color: mine == -1 ? _redVote : _slate,
                  size: 22,
                ),
              ),
              Text(
                '${t.downCount}',
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (t.score != 0)
                Text(
                  'score ${t.score > 0 ? '+' : ''}${t.score}',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
