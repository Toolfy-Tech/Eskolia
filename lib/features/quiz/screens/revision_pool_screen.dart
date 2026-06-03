import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/services/asset_cache_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';
import '../services/quiz_repository.dart';
import '../services/revision_pool_repository.dart';
import '../models/revision_pool_launch_mode.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = EskoliaTokens.cyan;
const Color _violet = EskoliaTokens.violetSoft;
const Color _orange = EskoliaTokens.orange;
const Color _slate = EskoliaTokens.textSecondary;
const Color _surface = EskoliaTokens.surface2;
const Color _red = EskoliaTokens.error;

class RevisionPoolScreen extends StatefulWidget {
  const RevisionPoolScreen({
    super.key,
    this.launchMode = RevisionPoolLaunchMode.browse,
  });

  final RevisionPoolLaunchMode launchMode;

  @override
  State<RevisionPoolScreen> createState() => _RevisionPoolScreenState();
}

class _RevisionPoolScreenState extends State<RevisionPoolScreen> {
  final RevisionPoolRepository _pool = RevisionPoolRepository();
  late Future<_PoolUiModel> _future;
  final Set<String> _selectedKeys = {};
  bool _busyQuiz = false;
  bool _busyFlashcards = false;
  bool _autoLaunchScheduled = false;

  @override
  void initState() {
    super.initState();
    _future = _futureWithSyncedSelection(_load());
  }

  void _reload() {
    setState(() {
      _future = _futureWithSyncedSelection(_load());
    });
  }

  Future<_PoolUiModel> _futureWithSyncedSelection(Future<_PoolUiModel> inner) {
    return inner.then((model) {
      if (mounted) {
        setState(() {
          _selectedKeys..clear()..addAll(model.entries.map((e) => e.storageKey));
        });
        if (model.entries.isNotEmpty &&
            widget.launchMode != RevisionPoolLaunchMode.browse &&
            !_autoLaunchScheduled) {
          _autoLaunchScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            switch (widget.launchMode) {
              case RevisionPoolLaunchMode.quizAll:
                _startQuizSelection(model);
                break;
              case RevisionPoolLaunchMode.flashcardsAll:
                _startFlashcardsSelection(model);
                break;
              case RevisionPoolLaunchMode.browse:
                break;
            }
          });
        }
      }
      return model;
    });
  }

  Future<_PoolUiModel> _load() async {
    final entries = await _pool.readEntries();
    final previews = <String>[];
    for (final e in entries) {
      try {
        final raw = await AssetCacheService.loadString(e.assetPath);
        final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: e.assetPath);
        final q = e.questionId != null ? qs.firstWhere((x) => x.id == e.questionId) : null;
        final preview = q?.question ?? e.assetPath.split('/').last;
        previews.add(preview.length > 120 ? '${preview.substring(0, 117)}…' : preview);
      } catch (_) {
        previews.add(e.assetPath.split('/').last);
      }
    }
    return _PoolUiModel(entries: entries, previews: previews);
  }

  Future<void> _startQuizSelection(_PoolUiModel model) async {
    final selected = model.entries.where((e) => _selectedKeys.contains(e.storageKey)).toList();
    if (selected.isEmpty) return;
    setState(() => _busyQuiz = true);
    try {
      await _pool.markReviewed(selected.map((e) => e.storageKey).toList());
      final session = await QuizRepository().buildRevisionPoolSession(entries: selected);
      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } finally {
      if (mounted) setState(() => _busyQuiz = false);
    }
  }

  Future<void> _startFlashcardsSelection(_PoolUiModel model) async {
    final selected = model.entries.where((e) => _selectedKeys.contains(e.storageKey)).toList();
    if (selected.isEmpty) return;
    setState(() => _busyFlashcards = true);
    try {
      await _pool.markReviewed(selected.map((e) => e.storageKey).toList());
      final qs = await _pool.resolveQuestions(selected, max: selected.length);
      final cards = FlashcardDeckRepository().buildEphemeralFromQuizQuestions(qs);
      if (!mounted) return;
      context.push('/flashcards/session', extra: FlashcardSessionRouteArgs(cards: cards, ephemeral: true));
    } finally {
      if (mounted) setState(() => _busyFlashcards = false);
    }
  }

  Future<void> _removeEntry(RevisionPoolEntry entry) async {
    await _pool.remove(entry);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busyQuiz || _busyFlashcards;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Ma révision'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<_PoolUiModel>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: _cyan));
                }
                final model = snap.data!;
                if (model.entries.isEmpty) return _buildEmpty();
                return Column(
                  children: [
                    _buildHeader(model, busy),
                    Expanded(child: _buildList(model, busy)),
                  ],
                );
              },
            ),
          ),
          if (busy) ModalBarrier(color: Colors.black.withValues(alpha: 0.35), dismissible: false),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1F4CC}', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            const Text(
              'Pool vide',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Épingle des questions depuis les résultats de quiz\nou après chaque mauvaise réponse.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(_PoolUiModel model, bool busy) {
    final dueCount = model.entries.where((e) => e.isDue).length;
    final selectedCount = _selectedKeys.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _violet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _violet.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${model.entries.length} question${model.entries.length > 1 ? "s" : ""}',
                  style: const TextStyle(color: _violet, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              if (dueCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _orange.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$dueCount à revoir',
                    style: const TextStyle(color: _orange, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy || selectedCount == 0 ? null : () => _startQuizSelection(model),
                  icon: _busyQuiz
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.quiz_outlined, size: 18),
                  label: Text('Quiz ($selectedCount)'),
                  style: FilledButton.styleFrom(backgroundColor: _violet),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy || selectedCount == 0 ? null : () => _startFlashcardsSelection(model),
                  icon: _busyFlashcards
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.style_outlined, size: 18),
                  label: const Text('Flashcards'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Glisse vers la gauche pour supprimer une question.',
            style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildList(_PoolUiModel model, bool busy) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        4,
        EskoliaLayout.screenPaddingH,
        EskoliaLayout.screenPaddingBottom,
      ),
      itemCount: model.entries.length,
      itemBuilder: (context, i) {
        final e = model.entries[i];
        return Dismissible(
          key: ValueKey(e.storageKey),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: _red),
          ),
          onDismissed: (_) => _removeEntry(e),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PoolEntryCard(
              entry: e,
              preview: model.previews[i],
              selected: _selectedKeys.contains(e.storageKey),
              onToggle: busy
                  ? null
                  : (v) => setState(() {
                        if (v) {
                          _selectedKeys.add(e.storageKey);
                        } else {
                          _selectedKeys.remove(e.storageKey);
                        }
                      }),
            ),
          ),
        );
      },
    );
  }
}

class _PoolEntryCard extends StatelessWidget {
  const _PoolEntryCard({
    required this.entry,
    required this.preview,
    required this.selected,
    required this.onToggle,
  });

  final RevisionPoolEntry entry;
  final String preview;
  final bool selected;
  final ValueChanged<bool>? onToggle;

  String _formatLastSeen() {
    final r = entry.lastReviewedAt;
    if (r == null) return 'Jamais révisée';
    final diff = DateTime.now().difference(r);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final due = entry.isDue;
    return GestureDetector(
      onTap: onToggle != null ? () => onToggle!(!selected) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? _violet.withValues(alpha: 0.1)
              : _surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _violet.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              onChanged: onToggle != null ? (v) => onToggle!(v ?? false) : null,
              activeColor: _violet,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (due)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _orange.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            '\u{1F525} À revoir',
                            style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      Text(
                        _formatLastSeen(),
                        style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoolUiModel {
  const _PoolUiModel({required this.entries, required this.previews});
  final List<RevisionPoolEntry> entries;
  final List<String> previews;
}
