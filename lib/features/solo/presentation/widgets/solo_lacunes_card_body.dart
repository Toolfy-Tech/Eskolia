import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/services/asset_cache_service.dart';
import '../../../quiz/services/lacunes_repository.dart';
import '../../../quiz/services/quiz_repository.dart';
import '../../../quiz/services/revision_pool_repository.dart';
import '../../../parcours/data/tip_quiz_catalog.dart';
import '../../../flashcards/data/flashcard_deck_repository.dart';
import '../../../flashcards/presentation/flashcard_session_screen.dart';

class SoloLacunesCardBody extends StatefulWidget {
  const SoloLacunesCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  State<SoloLacunesCardBody> createState() => _SoloLacunesCardBodyState();
}

class _SoloLacunesCardBodyState extends State<SoloLacunesCardBody> {
  int _lacunesCount = 0;
  Map<String, int> _breakdown = {};
  bool _loading = true;
  bool _busy = false;

  // Manage Inline List State
  bool _showManage = false;
  List<RevisionPoolEntry> _entries = [];
  List<String> _previews = [];
  final Set<String> _selectedKeys = {};
  final Set<String> _pinnedKeys = {};
  bool _loadingManage = false;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final entries = await LacunesRepository().readEntries();
      
      // Save count in SharedPreferences for other components
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('eskolia_lacunes_count', entries.length);

      // Compute dynamic breakdown
      final Map<String, int> breakdown = {};
      final chaptersMap = await TipQuizCatalog.pathToChapterRefMap();
      for (final e in entries) {
        final ref = chaptersMap[e.assetPath];
        final title = ref != null 
            ? ref.chapterTitle 
            : (TipQuizCatalog.fallbackContextLineForAssetPath(e.assetPath) ?? 'Autres');
        breakdown[title] = (breakdown[title] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _lacunesCount = entries.length;
          _breakdown = breakdown;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading lacunes count/breakdown: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadManageData() async {
    setState(() => _loadingManage = true);
    try {
      final entries = await LacunesRepository().readEntries();
      final pinned = await RevisionPoolRepository().readKeySet();
      
      final previews = <String>[];
      for (final e in entries) {
        try {
          final raw = await AssetCacheService.loadString(e.assetPath);
          final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: e.assetPath);
          final q = e.questionId != null ? qs.firstWhere((x) => x.id == e.questionId) : null;
          final preview = q?.question ?? e.assetPath.split('/').last;
          previews.add(preview.length > 80 ? '${preview.substring(0, 77)}…' : preview);
        } catch (_) {
          previews.add(e.assetPath.split('/').last);
        }
      }

      if (mounted) {
        setState(() {
          _entries = entries;
          _previews = previews;
          _pinnedKeys.clear();
          _pinnedKeys.addAll(pinned);
          
          // Auto-select all by default if selectedKeys is empty
          if (_selectedKeys.isEmpty) {
            _selectedKeys.addAll(entries.map((e) => e.storageKey));
          } else {
            final currentKeys = entries.map((e) => e.storageKey).toSet();
            _selectedKeys.retainAll(currentKeys);
          }
          _loadingManage = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading manage data: $e');
      if (mounted) {
        setState(() => _loadingManage = false);
      }
    }
  }

  Future<void> _deleteEntry(RevisionPoolEntry entry) async {
    await LacunesRepository().remove(entry);
    await _loadCount();
    if (_showManage) {
      await _loadManageData();
    }
  }

  Future<void> _togglePin(RevisionPoolEntry entry) async {
    final k = entry.storageKey;
    if (_pinnedKeys.contains(k)) {
      await RevisionPoolRepository().removeByKey(k);
      setState(() => _pinnedKeys.remove(k));
    } else {
      await RevisionPoolRepository().addByKey(k);
      setState(() => _pinnedKeys.add(k));
    }
  }

  Future<void> _batchPin() async {
    if (_selectedKeys.isEmpty) return;
    for (final k in _selectedKeys) {
      await RevisionPoolRepository().addByKey(k);
    }
    final pinned = await RevisionPoolRepository().readKeySet();
    if (mounted) {
      setState(() {
        _pinnedKeys.addAll(pinned);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélection épinglée à À revoir 📌'), duration: Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _batchDelete() async {
    if (_selectedKeys.isEmpty) return;
    for (final k in _selectedKeys) {
      await LacunesRepository().removeByKey(k);
    }
    await _loadCount();
    if (_showManage) {
      await _loadManageData();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélection supprimée des fautes ❌'), duration: Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _launchLacunesFlashcards() async {
    setState(() => _busy = true);
    try {
      final entries = await LacunesRepository().readEntries();
      if (entries.isEmpty) {
        throw Exception('Aucune lacune à réviser.');
      }
      final questions = await LacunesRepository().resolveQuestions(entries, max: 20);
      if (questions.isEmpty) {
        throw Exception('Impossible de résoudre les questions de lacunes.');
      }
      final deckRepo = FlashcardDeckRepository();
      final list = deckRepo.buildEphemeralFromQuizQuestions(questions);
      if (!mounted) return;
      if (list.isEmpty) {
        throw Exception('Aucune flashcard générée.');
      }
      
      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: list,
          ephemeral: true,
          timed: false,
          survival: false,
        ),
      ).then((_) {
        _loadCount();
        if (_showManage) {
          _loadManageData();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.isExpandedOverride ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fautes enregistrées',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
              ),
              _loading
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: EskoliaTokens.cyan))
                  : Text(
                      _lacunesCount > 0 ? '$_lacunesCount fautes ❌' : '0 faute 🎉',
                      style: TextStyle(
                        color: _lacunesCount > 0 ? EskoliaTokens.error : EskoliaTokens.success,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
        if (isExpanded && !_showManage) ...[
          const SizedBox(height: 10),
          // Breakdown of lacunes
          if (_lacunesCount > 0) ...[
            const Text(
              'Répartition estimée :',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ..._breakdown.entries.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${item.key}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.value} faute${item.value > 1 ? "s" : ""}',
                      style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            const Text(
              'Parfait ! Aucune faute en cours. Toutes vos tentatives incorrectes ont été corrigées ou résolues avec succès.',
              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, height: 1.3),
            ),
          ],
        ],

        // Inline Management list
        if (isExpanded && _showManage) ...[
          const SizedBox(height: 10),
          if (_loadingManage)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.error),
                ),
              ),
            )
          else if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune faute en attente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 11),
              ),
            )
          else ...[
            // Batch Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedKeys.isNotEmpty && _selectedKeys.length == _entries.length,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedKeys.addAll(_entries.map((e) => e.storageKey));
                        } else {
                          _selectedKeys.clear();
                        }
                      });
                    },
                    activeColor: EskoliaTokens.error,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    'Sélection (${_selectedKeys.length})',
                    style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.8), fontSize: 10.5),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.push_pin_outlined, color: EskoliaTokens.cyan, size: 16),
                    onPressed: _selectedKeys.isEmpty ? null : _batchPin,
                    tooltip: 'Épingler la sélection',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 16),
                    onPressed: _selectedKeys.isEmpty ? null : _batchDelete,
                    tooltip: 'Supprimer la sélection',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ],
              ),
            ),
            // Scrollable List constrained to ~20 lines height max (approx 260px)
            Container(
              constraints: const BoxConstraints(maxHeight: 260),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.005),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                border: const Border(
                  left: BorderSide(color: Colors.white10),
                  right: BorderSide(color: Colors.white10),
                  bottom: BorderSide(color: Colors.white10),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _entries.length,
                  itemBuilder: (context, i) {
                    final e = _entries[i];
                    final preview = _previews[i];
                    final isSelected = _selectedKeys.contains(e.storageKey);
                    final isPinned = _pinnedKeys.contains(e.storageKey);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedKeys.add(e.storageKey);
                                } else {
                                  _selectedKeys.remove(e.storageKey);
                                }
                              });
                            },
                            activeColor: EskoliaTokens.error,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            visualDensity: VisualDensity.compact,
                          ),
                          Expanded(
                            child: Text(
                              preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                              color: isPinned ? EskoliaTokens.cyan : Colors.white24,
                              size: 15,
                            ),
                            onPressed: () => _togglePin(e),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            tooltip: isPinned ? 'Retirer de À revoir' : 'Ajouter à À revoir',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: EskoliaTokens.error,
                              size: 15,
                            ),
                            onPressed: () => _deleteEntry(e),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            tooltip: 'Supprimer définitivement',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showManage = !_showManage;
                    if (_showManage) {
                      _loadManageData();
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _showManage ? EskoliaTokens.error : Colors.white24,
                  ),
                  backgroundColor: _showManage ? EskoliaTokens.error.withValues(alpha: 0.15) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Gérer',
                  style: TextStyle(
                    color: _showManage ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: _lacunesCount == 0 
                    ? null 
                    : () => context.push('/quiz/revision-lacunes').then((_) {
                          _loadCount();
                          if (_showManage) {
                            _loadManageData();
                          }
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lacunesCount == 0 ? Colors.white.withValues(alpha: 0.05) : EskoliaTokens.error,
                  foregroundColor: _lacunesCount == 0 ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Quiz', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: OutlinedButton(
                onPressed: (_lacunesCount == 0 || _busy) ? null : _launchLacunesFlashcards,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _lacunesCount > 0 ? EskoliaTokens.error : Colors.white10,
                  ),
                  backgroundColor: (_lacunesCount > 0 && !_busy) ? EskoliaTokens.error.withValues(alpha: 0.05) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.error),
                      )
                    : Text(
                        'Flashcards',
                        style: TextStyle(
                          color: _lacunesCount > 0 ? Colors.white : Colors.white30,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
