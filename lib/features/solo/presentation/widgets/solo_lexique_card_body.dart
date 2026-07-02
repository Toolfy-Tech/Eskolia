import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../lexique/data/lexique_data.dart';
import '../../../quiz/services/quiz_repository.dart';

class SoloLexiqueCardBody extends ConsumerStatefulWidget {
  const SoloLexiqueCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<SoloLexiqueCardBody> createState() => _SoloLexiqueCardBodyState();
}

class _SoloLexiqueCardBodyState extends ConsumerState<SoloLexiqueCardBody> {
  String _mode = 'atelier'; // 'atelier' | 'qcm'
  int _questionCount = 15;
  List<String> _selectedCategories = [];
  bool _showCategoriesDropdown = false;
  bool _busy = false;

  Widget _buildThemeCheckboxRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isBold = false,
  }) {
    const orangeColor = EskoliaTokens.orange;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                activeColor: orangeColor,
                checkColor: Colors.black,
                value: value,
                onChanged: onChanged,
                side: const BorderSide(color: Colors.white30, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: value ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isBold || value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch() async {
    final isAllSelected = _selectedCategories.isEmpty || _selectedCategories.length == lexiqueCategories.length;
    final categoryArg = isAllSelected ? 'all' : _selectedCategories.join(',');

    if (_mode == 'atelier') {
      context.push(
        '/lexique',
        extra: {
          'count': _questionCount,
          'category': categoryArg,
        },
      );
    } else {
      setState(() => _busy = true);
      try {
        final sentinels = <String>[];
        if (isAllSelected) {
          sentinels.add('${QuizRepository.lexiqueSentinelPrefix}all');
        } else {
          for (final catKey in _selectedCategories) {
            sentinels.add('${QuizRepository.lexiqueSentinelPrefix}$catKey');
          }
        }
        final session = await QuizRepository().buildSoloComposeSession(
          quizAssetPaths: sentinels,
          maxQuestions: _questionCount,
          timed: false,
        );
        if (!mounted) return;
        context.push('/quiz/run', extra: session);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:lexique']?.isCollapsed ?? false);

    const orangeColor = EskoliaTokens.orange;
    final selectedCats = _selectedCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Selector Toggle Segment
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _mode = 'atelier'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _mode == 'atelier' ? orangeColor.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _mode == 'atelier' ? orangeColor : Colors.white12,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'Atelier Écriture',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _mode == 'atelier' ? Colors.white : Colors.white54,
                      fontSize: 11,
                      fontWeight: _mode == 'atelier' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _mode = 'qcm'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _mode == 'qcm' ? orangeColor.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _mode == 'qcm' ? orangeColor : Colors.white12,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'Quiz QCM Express',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _mode == 'qcm' ? Colors.white : Colors.white54,
                      fontSize: 11,
                      fontWeight: _mode == 'qcm' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!isCollapsed) ...[
          const SizedBox(height: 12),
          // Category selector collapsible checklist
          InkWell(
            onTap: () => setState(() => _showCategoriesDropdown = !_showCategoriesDropdown),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_rounded, color: orangeColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sujet sélectionné',
                          style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (selectedCats.isEmpty || selectedCats.length == lexiqueCategories.length)
                              ? 'Tous les termes du lexique'
                              : (selectedCats.length == 1
                                  ? lexiqueCategories.firstWhere((cat) => cat.key == selectedCats.first).name
                                  : '${selectedCats.length} catégories'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showCategoriesDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),

          if (_showCategoriesDropdown) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  _buildThemeCheckboxRow(
                    title: 'Tous les termes du lexique',
                    value: selectedCats.isEmpty || selectedCats.length == lexiqueCategories.length,
                    onChanged: (val) {
                      setState(() {
                        if (selectedCats.isEmpty || selectedCats.length == lexiqueCategories.length) {
                          _selectedCategories = [lexiqueCategories.first.key];
                        } else {
                          _selectedCategories = lexiqueCategories.map((cat) => cat.key).toList();
                        }
                      });
                    },
                    isBold: true,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ...lexiqueCategories.map((cat) {
                    final isAll = selectedCats.isEmpty || selectedCats.length == lexiqueCategories.length;
                    final isSelected = isAll || selectedCats.contains(cat.key);
                    return _buildThemeCheckboxRow(
                      title: '${cat.emoji} ${cat.name} (${cat.count} termes)',
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (isAll) {
                            _selectedCategories = lexiqueCategories.map((c) => c.key).toList();
                            _selectedCategories.remove(cat.key);
                          } else {
                            if (val == true) {
                              _selectedCategories.add(cat.key);
                            } else {
                              if (_selectedCategories.length > 1) {
                                _selectedCategories.remove(cat.key);
                              }
                            }
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Count Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nombre de termes/questions :',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
              ),
              Row(
                children: [10, 15, 20].map((n) {
                  final active = _questionCount == n;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: InkWell(
                      onTap: () => setState(() => _questionCount = n),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? orangeColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: active ? orangeColor : Colors.white10,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '$n',
                          style: TextStyle(
                            color: active ? Colors.white : Colors.white54,
                            fontSize: 11,
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: _busy ? null : _launch,
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: _busy
              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Lancer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
