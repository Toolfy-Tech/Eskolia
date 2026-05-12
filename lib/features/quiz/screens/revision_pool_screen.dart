import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);

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

  Future<_PoolUiModel> _futureWithSyncedSelection(Future<_PoolUiModel> inner) {
    return inner.then((model) {
      if (mounted) {
        setState(() {
          _selectedKeys..clear()..addAll(model.entries.map((e) => e.storageKey));
        });
        if (model.entries.isNotEmpty && widget.launchMode != RevisionPoolLaunchMode.browse && !_autoLaunchScheduled) {
          _autoLaunchScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            switch (widget.launchMode) {
              case RevisionPoolLaunchMode.quizAll: _startQuizSelection(model); break;
              case RevisionPoolLaunchMode.flashcardsAll: _startFlashcardsSelection(model); break;
              case RevisionPoolLaunchMode.browse: break;
            }
          });
        }
      }
      return model;
    });
  }

  Future<_PoolUiModel> _load() async {
    final entries = await _pool.readEntries();
    final lines = <String>[];
    for (final e in entries) {
      try {
        final raw = await rootBundle.loadString(e.assetPath);
        final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: e.assetPath);
        final q = e.questionId != null ? qs.firstWhere((x) => x.id == e.questionId) : null;
        final preview = q?.question ?? e.assetPath.split('/').last;
        lines.add(preview.length > 120 ? '${preview.substring(0, 117)}…' : preview);
      } catch (_) { lines.add(e.assetPath.split('/').last); }
    }
    return _PoolUiModel(entries: entries, previews: lines);
  }

  Future<void> _startQuizSelection(_PoolUiModel model) async {
    final selected = model.entries.where((e) => _selectedKeys.contains(e.storageKey)).toList();
    if (selected.isEmpty) return;
    setState(() => _busyQuiz = true);
    try {
      final session = await QuizRepository().buildRevisionPoolSession(entries: selected);
      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } finally { if (mounted) setState(() => _busyQuiz = false); }
  }

  Future<void> _startFlashcardsSelection(_PoolUiModel model) async {
    final selected = model.entries.where((e) => _selectedKeys.contains(e.storageKey)).toList();
    if (selected.isEmpty) return;
    setState(() => _busyFlashcards = true);
    try {
      final qs = await _pool.resolveQuestions(selected, max: selected.length);
      final cards = FlashcardDeckRepository().buildEphemeralFromQuizQuestions(qs);
      if (!mounted) return;
      context.push('/flashcards/session', extra: FlashcardSessionRouteArgs(cards: cards, ephemeral: true));
    } finally { if (mounted) setState(() => _busyFlashcards = false); }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busyQuiz || _busyFlashcards;
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Ma révision'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<_PoolUiModel>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: _cyan));
                final model = snap.data!;
                if (model.entries.isEmpty) return const Center(child: Text('Aucune question épinglée.'));
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

  Widget _buildHeader(_PoolUiModel model, bool busy) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: busy ? null : () => _startQuizSelection(model),
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Quiz'),
              style: FilledButton.styleFrom(backgroundColor: _violet),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _startFlashcardsSelection(model),
              icon: const Icon(Icons.style_outlined),
              label: const Text('Flashcards'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(_PoolUiModel model, bool busy) {
    return ListView.builder(
      itemCount: model.entries.length,
      itemBuilder: (context, i) {
        final e = model.entries[i];
        return ListTile(
          leading: Checkbox(
            value: _selectedKeys.contains(e.storageKey),
            onChanged: busy ? null : (v) => setState(() { if (v!) {
              _selectedKeys.add(e.storageKey);
            } else {
              _selectedKeys.remove(e.storageKey);
            } }),
          ),
          title: Text(model.previews[i], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(e.assetPath, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        );
      },
    );
  }
}

class _PoolUiModel {
  const _PoolUiModel({required this.entries, required this.previews});
  final List<RevisionPoolEntry> entries;
  final List<String> previews;
}
