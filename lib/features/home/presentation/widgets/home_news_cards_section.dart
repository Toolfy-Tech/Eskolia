import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../providers/home_news_provider.dart';
import 'whats_new_announcement_dialog.dart';

class HomeNewsCardsSection extends ConsumerWidget {
  const HomeNewsCardsSection({
    super.key,
    required this.numColumns,
  });

  final int numColumns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNews = ref.watch(activeAppNewsProvider);

    if (activeNews.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWide = numColumns >= 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(
                'NOUVEAUTÉS',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: EskoliaTokens.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${activeNews.length}',
                  style: const TextStyle(
                    color: EskoliaTokens.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => WhatsNewAnnouncementDialog.show(context),
                icon: const Icon(Icons.auto_stories_rounded, size: 14, color: Colors.white54),
                label: const Text(
                  'Voir le récap',
                  style: TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // News Cards Layout
          if (isWide && activeNews.length > 1) ...[
            _buildGrid(context, ref, activeNews, numColumns),
          ] else ...[
            ...activeNews.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildNewsCard(context, ref, item),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<AppNewsItem> items,
    int columns,
  ) {
    if (columns == 3 && items.length >= 3) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildNewsCard(context, ref, items[0])),
          const SizedBox(width: 12),
          Expanded(child: _buildNewsCard(context, ref, items[1])),
          const SizedBox(width: 12),
          Expanded(child: _buildNewsCard(context, ref, items[2])),
        ],
      );
    }

    // 2 columns
    final left = <Widget>[];
    final right = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        left.add(_buildNewsCard(context, ref, items[i]));
      } else {
        right.add(_buildNewsCard(context, ref, items[i]));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, WidgetRef ref, AppNewsItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.accentColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: -4,
          ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Emoji + Badge + Date + Dismiss Button
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: item.accentColor.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(item.emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: item.accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        item.badge,
                        style: TextStyle(
                          color: item.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.date,
                      style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              // Dismiss Button (❌)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                tooltip: 'Masquer cette nouveauté',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  ref.read(dismissedNewsProvider.notifier).dismissNews(item.id);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nouveauté "${item.title}" masquée.'),
                      duration: const Duration(milliseconds: 2000),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      closeIconColor: Colors.white70,
                      backgroundColor: EskoliaTokens.surface2,
                      action: SnackBarAction(
                        label: 'Annuler',
                        textColor: EskoliaTokens.cyan,
                        onPressed: () {
                          ref.read(dismissedNewsProvider.notifier).restoreAllNews();
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Description
          Text(
            item.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => context.push(item.targetRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: item.accentColor,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(item.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
