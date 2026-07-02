import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/services/asset_cache_service.dart';
import '../../../quiz/models/revision_pool_launch_mode.dart';
import '../../../quiz/services/revision_pool_repository.dart';
import '../../../quiz/services/quiz_repository.dart';

class SoloPoolCardBody extends StatefulWidget {
  const SoloPoolCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  State<SoloPoolCardBody> createState() => _SoloPoolCardBodyState();
}

class _SoloPoolCardBodyState extends State<SoloPoolCardBody> {
  int _poolCount = 0;
  bool _loading = true;

  // Manage Inline List State
  bool _showManage = false;
  List<RevisionPoolEntry> _entries = [];
  List<String> _previews = [];
  final Set<String> _selectedKeys = {};
  bool _loadingManage = false;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final entries = await RevisionPoolRepository().readEntries();
      if (mounted) {
        setState(() {
          _poolCount = entries.length;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading revision pool count: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadManageData() async {
    setState(() => _loadingManage = true);
    try {
      final entries = await RevisionPoolRepository().readEntries();
      
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
    await RevisionPoolRepository().remove(entry);
    await _loadCount();
    if (_showManage) {
      await _loadManageData();
    }
  }

  Future<void> _batchDelete() async {
    if (_selectedKeys.isEmpty) return;
    for (final k in _selectedKeys) {
      await RevisionPoolRepository().removeByKey(k);
    }
    await _loadCount();
    if (_showManage) {
      await _loadManageData();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélection retirée de À revoir 📌'), duration: Duration(milliseconds: 800)),
      );
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
                'Questions à revoir',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
              ),
              _loading
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: EskoliaTokens.cyan))
                  : Text(
                      _poolCount > 0 ? '$_poolCount question${_poolCount > 1 ? "s" : ""} 📌' : 'Vide 📌',
                      style: const TextStyle(color: EskoliaTokens.cyan, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
        if (isExpanded && !_showManage) ...[
          const SizedBox(height: 10),
          const Text(
            'Retrouvez ici toutes les questions que vous avez décidé d\'épingler pour les réviser ultérieurement.',
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, height: 1.3),
          ),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
                ),
              ),
            )
          else if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune question à revoir.',
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
                    activeColor: EskoliaTokens.cyan,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    'Sélection (${_selectedKeys.length})',
                    style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.8), fontSize: 10.5),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: EskoliaTokens.error, size: 16),
                    onPressed: _selectedKeys.isEmpty ? null : _batchDelete,
                    tooltip: 'Retirer la sélection',
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
                            activeColor: EskoliaTokens.cyan,
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
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: EskoliaTokens.error,
                              size: 15,
                            ),
                            onPressed: () => _deleteEntry(e),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            tooltip: 'Retirer des questions à revoir',
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
                    color: _showManage ? EskoliaTokens.cyan : Colors.white24,
                  ),
                  backgroundColor: _showManage ? EskoliaTokens.cyan.withValues(alpha: 0.15) : Colors.transparent,
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
                onPressed: _poolCount == 0 
                    ? null 
                    : () => context.push('/revision-pool', extra: RevisionPoolLaunchMode.quizAll).then((_) {
                          _loadCount();
                          if (_showManage) {
                            _loadManageData();
                          }
                        }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _poolCount == 0 ? Colors.white.withValues(alpha: 0.05) : EskoliaTokens.cyan,
                  foregroundColor: _poolCount == 0 ? Colors.white.withValues(alpha: 0.2) : Colors.black,
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
                onPressed: _poolCount == 0 
                    ? null 
                    : () => context.push('/revision-pool', extra: RevisionPoolLaunchMode.flashcardsAll).then((_) {
                          _loadCount();
                          if (_showManage) {
                            _loadManageData();
                          }
                        }),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _poolCount > 0 ? EskoliaTokens.cyan : Colors.white10,
                  ),
                  backgroundColor: _poolCount > 0 ? EskoliaTokens.cyan.withValues(alpha: 0.05) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Flashcards',
                  style: TextStyle(
                    color: _poolCount > 0 ? Colors.white : Colors.white30,
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
