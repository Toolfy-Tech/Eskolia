import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/services/asset_cache_service.dart';
import '../../../../core/services/eskolia_folder_service.dart';
import '../../../admin/data/models/teacher_quiz.dart';
import '../../../quiz/services/quiz_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../flashcards/data/flashcard_deck_repository.dart';
import '../../../flashcards/presentation/flashcard_session_screen.dart';
import '../../../parcours/data/tip_quiz_catalog.dart';

class SoloFlashcardsCardBody extends ConsumerStatefulWidget {
  const SoloFlashcardsCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<SoloFlashcardsCardBody> createState() => _SoloFlashcardsCardBodyState();
}

class _SoloFlashcardsCardBodyState extends ConsumerState<SoloFlashcardsCardBody> {
  final _deckRepo = FlashcardDeckRepository();
  int _dueCount = 0;
  bool _loading = true;
  bool _busy = false;

  final List<Map<String, String>> _themes = const [
    {'id': 'M01', 'title': 'Support Utilisateur'},
    {'id': 'M02', 'title': 'Hardware & Architecture'},
    {'id': 'M03', 'title': 'Système d\'exploitation'},
    {'id': 'M04', 'title': 'Réseaux & Infrastructure'},
    {'id': 'M05', 'title': 'Maintenance & Sauvegarde'},
    {'id': 'M06', 'title': 'Administration Windows'},
    {'id': 'M07', 'title': 'Cybersécurité'},
    {'id': 'M08', 'title': 'Utiliser l\'IA'},
  ];
  List<String> _selectedThemeIds = [];
  bool _showThemesDropdown = false;
  final Set<String> _selectedDifficulties = {'Facile', 'Moyen', 'Difficile'};
  
  int _questionCount = 10;
  Set<String> _selectedPools = {'base'}; // 'base', 'perso', 'teacher'
  List<String> _selectedPersoFiles = [];
  List<String> _selectedTeacherQuizIds = [];
  
  List<String> _persoFiles = [];
  List<TeacherQuiz> _teacherQuizzes = [];

  bool _showPoolDropdown = false;
  bool _showPersoFilesDropdown = false;
  bool _showTeacherQuizzesDropdown = false;
  bool _showCountDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadPools();
  }

  Future<void> _loadStats() async {
    try {
      final due = await _deckRepo.countDue();
      if (mounted) {
        setState(() {
          _dueCount = due;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPools() async {
    try {
      final files = await EskoliaFolderService.instance.listFiles(EskoliaFolder.quiz);
      final jsonFiles = files.where((f) => f.endsWith('.json') && f != 'eskolia_quiz_template.json').toList();
      
      final teacherSnap = await FirebaseFirestore.instance
          .collection('teacher_quizzes')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      final quizzes = teacherSnap.docs.map((d) => TeacherQuiz.fromDoc(d)).toList();

      if (mounted) {
        setState(() {
          _persoFiles = jsonFiles;
          _teacherQuizzes = quizzes;
          _selectedPersoFiles = List.from(_persoFiles);
          _selectedTeacherQuizIds = _teacherQuizzes.map((q) => q.id).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading custom/teacher pools for flashcards: $e');
    }
  }

  Widget _buildThemeCheckboxRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isBold = false,
    Color activeColor = EskoliaTokens.success,
  }) {
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
                activeColor: activeColor,
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

  Widget _buildDifficultyButton({
    required String label,
    required Color dotColor,
    required Color activeColor,
  }) {
    final isSelected = _selectedDifficulties.contains(label);
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              if (_selectedDifficulties.length > 1) {
                _selectedDifficulties.remove(label);
              }
            } else {
              _selectedDifficulties.add(label);
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.08),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSelector({
    required String label,
    required String valueText,
    required IconData icon,
    required Color color,
    required bool isOpen,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
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
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valueText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
        if (isOpen) ...[
          const SizedBox(height: 6),
          child,
        ],
      ],
    );
  }

  Widget _buildDropdownItemRow({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = EskoliaTokens.success,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? activeColor : Colors.white30,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDueSession() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final list = await _deckRepo.dueCards();
      list.shuffle();
      if (!mounted) return;
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune carte due aujourd\'hui !')),
        );
        return;
      }

      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: list.take(20).toList(),
          ephemeral: false,
          timed: false,
          survival: false,
        ),
      ).then((_) => _loadStats());
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

  Future<void> _launchFilteredFlashcards() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final questions = <QuizQuestion>[];

      // 1. Base App
      if (_selectedPools.contains('base')) {
        final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
        final optimusChapters = allChapters.where((c) => c.track == QuizCatalogTrack.optimusOnly).toList();
        
        final filteredChapters = _selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length
            ? optimusChapters
            : optimusChapters.where((c) => _selectedThemeIds.contains(c.sectionId)).toList();

        final selectedPaths = filteredChapters.map((c) => c.quizAssetPath).toList();
        
        final difficultyFilters = <String>{};
        for (final diff in _selectedDifficulties) {
          difficultyFilters.add(diff.toLowerCase());
        }

        for (final path in selectedPaths) {
          try {
            final raw = await AssetCacheService.loadString(path);
            final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: path);
            questions.addAll(qs.where((q) => difficultyFilters.isEmpty || difficultyFilters.contains(q.difficultyBucket)));
          } catch (e) {
            debugPrint('Error loading base asset $path: $e');
          }
        }
      }

      // 2. Personal Quizzes
      if (_selectedPools.contains('perso') && _selectedPersoFiles.isNotEmpty) {
        for (final file in _selectedPersoFiles) {
          try {
            final raw = await EskoliaFolderService.instance.readFile(EskoliaFolder.quiz, file);
            if (raw != null) {
              final parsed = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: file);
              if (parsed.isNotEmpty) {
                questions.addAll(parsed);
              } else {
                final decoded = jsonDecode(raw) as Map<String, dynamic>;
                final rawQ = decoded['questions'] as List<dynamic>? ?? [];
                for (int i = 0; i < rawQ.length; i++) {
                  final q = rawQ[i] as Map<String, dynamic>;
                  questions.add(QuizQuestion(
                    id: 'notebook_${file}_$i',
                    type: q['type'] as String? ?? 'classic',
                    question: q['question'] as String? ?? '',
                    answer: q['answer'] as String? ?? '',
                    difficultyBucket: (q['difficulty'] as String? ?? 'moyen').toLowerCase(),
                    contextLine: 'Notebook · ${decoded['quiz']?['title'] ?? file}',
                  ));
                }
              }
            }
          } catch (e) {
            debugPrint('Error loading personal file $file: $e');
          }
        }
      }

      // 3. Teacher Quizzes
      if (_selectedPools.contains('teacher') && _selectedTeacherQuizIds.isNotEmpty) {
        for (final id in _selectedTeacherQuizIds) {
          try {
            final snap = await FirebaseFirestore.instance.collection('teacher_quizzes').doc(id).get();
            final d = snap.data();
            if (snap.exists && d != null) {
              final title = d['title'] as String? ?? 'Quiz du prof';
              final rawQ = d['questions'] as List<dynamic>? ?? [];
              final authorName = d['authorName'] as String? ?? 'Prof';
              for (int i = 0; i < rawQ.length; i++) {
                final q = rawQ[i] as Map<String, dynamic>;
                questions.add(QuizQuestion(
                  id: 'teacher_${id}_$i',
                  type: q['type'] as String? ?? 'classic',
                  question: q['question'] as String? ?? '',
                  answer: q['answer'] as String? ?? '',
                  difficultyBucket: q['difficulty'] as String? ?? 'moyen',
                  contextLine: q['contextLine'] as String? ?? 'Quiz du prof · $title',
                  authorName: authorName,
                ));
              }
            }
          } catch (e) {
            debugPrint('Error loading teacher quiz $id: $e');
          }
        }
      }

      if (questions.isEmpty) {
        throw Exception('Aucune question ne correspond aux critères sélectionnés !');
      }

      questions.shuffle();
      final limitedQuestions = questions.take(_questionCount).toList();
      final list = _deckRepo.buildEphemeralFromQuizQuestions(limitedQuestions);

      if (!mounted) return;
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune carte ne correspond aux critères sélectionnés !')),
        );
        return;
      }

      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: list,
          ephemeral: true,
          timed: false,
          survival: false,
        ),
      ).then((_) => _loadStats());
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

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:flashcards']?.isCollapsed ?? false);

    const greenColor = EskoliaTokens.success;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: greenColor),
          ),
        ),
      );
    }

    String themeText;
    final isAllThemesSelected = _selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length;
    if (isAllThemesSelected) {
      themeText = 'Tous les thèmes';
    } else if (_selectedThemeIds.length == 1) {
      final t = _themes.firstWhere((theme) => theme['id'] == _selectedThemeIds.first);
      themeText = t['title']!;
    } else {
      themeText = '${_selectedThemeIds.length} thèmes';
    }

    String poolText;
    final isAllPoolsSelected = _selectedPools.length == 3;
    if (isAllPoolsSelected) {
      poolText = 'Tous les pools';
    } else if (_selectedPools.isEmpty) {
      poolText = 'Aucun pool sélectionné';
    } else if (_selectedPools.length == 1) {
      final pool = _selectedPools.first;
      if (pool == 'base') {
        poolText = 'Application de base';
      } else if (pool == 'perso') {
        poolText = 'Pool perso (Créées / IA)';
      } else {
        poolText = 'Pool prof / admin';
      }
    } else {
      poolText = '${_selectedPools.length} pools sélectionnés';
    }

    String persoFilesText;
    final isAllPersoSelected = _selectedPersoFiles.length == _persoFiles.length;
    if (_selectedPersoFiles.isEmpty) {
      persoFilesText = 'Aucun quiz perso';
    } else if (isAllPersoSelected) {
      persoFilesText = 'Tous les quiz persos';
    } else if (_selectedPersoFiles.length == 1) {
      persoFilesText = _selectedPersoFiles.first;
    } else {
      persoFilesText = '${_selectedPersoFiles.length} quiz persos';
    }

    String teacherQuizzesText;
    final isAllTeacherSelected = _selectedTeacherQuizIds.length == _teacherQuizzes.length;
    if (_selectedTeacherQuizIds.isEmpty) {
      teacherQuizzesText = 'Aucun quiz du prof';
    } else if (isAllTeacherSelected) {
      teacherQuizzesText = 'Tous les quiz du prof';
    } else if (_selectedTeacherQuizIds.length == 1) {
      final q = _teacherQuizzes.firstWhere((t) => t.id == _selectedTeacherQuizIds.first, orElse: () => _teacherQuizzes.first);
      teacherQuizzesText = q.title;
    } else {
      teacherQuizzesText = '${_selectedTeacherQuizIds.length} quiz du prof';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [


        // Dropdown Pool Selector Box
        _buildCollapsibleSelector(
          label: 'Pools de questions',
          valueText: poolText,
          icon: Icons.source_rounded,
          color: greenColor,
          isOpen: _showPoolDropdown,
          onTap: () => setState(() {
            _showPoolDropdown = !_showPoolDropdown;
            _showThemesDropdown = false;
            _showPersoFilesDropdown = false;
            _showTeacherQuizzesDropdown = false;
            _showCountDropdown = false;
          }),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.015),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                _buildThemeCheckboxRow(
                  title: 'Tous les pools',
                  value: isAllPoolsSelected,
                  onChanged: (val) {
                    setState(() {
                      if (isAllPoolsSelected) {
                        _selectedPools = {'base'};
                      } else {
                        _selectedPools = {'base', 'perso', 'teacher'};
                      }
                    });
                  },
                  isBold: true,
                  activeColor: greenColor,
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildThemeCheckboxRow(
                  title: 'Application de base',
                  value: _selectedPools.contains('base'),
                  onChanged: (val) {
                    setState(() {
                      if (_selectedPools.contains('base')) {
                        if (_selectedPools.length > 1) {
                          _selectedPools.remove('base');
                        }
                      } else {
                        _selectedPools.add('base');
                      }
                    });
                  },
                  activeColor: greenColor,
                ),
                _buildThemeCheckboxRow(
                  title: 'Pool perso (Créées / IA)',
                  value: _selectedPools.contains('perso'),
                  onChanged: (val) {
                    setState(() {
                      if (_selectedPools.contains('perso')) {
                        if (_selectedPools.length > 1) {
                          _selectedPools.remove('perso');
                        }
                      } else {
                        _selectedPools.add('perso');
                      }
                    });
                  },
                  activeColor: greenColor,
                ),
                _buildThemeCheckboxRow(
                  title: 'Pool prof / admin',
                  value: _selectedPools.contains('teacher'),
                  onChanged: (val) {
                    setState(() {
                      if (_selectedPools.contains('teacher')) {
                        if (_selectedPools.length > 1) {
                          _selectedPools.remove('teacher');
                        }
                      } else {
                        _selectedPools.add('teacher');
                      }
                    });
                  },
                  activeColor: greenColor,
                ),
              ],
            ),
          ),
        ),

        if (_selectedPools.contains('perso')) ...[
          const SizedBox(height: 12),
          _buildCollapsibleSelector(
            label: 'Quiz persos sélectionnés',
            valueText: persoFilesText,
            icon: Icons.folder_open_rounded,
            color: greenColor,
            isOpen: _showPersoFilesDropdown,
            onTap: () => setState(() {
              _showPersoFilesDropdown = !_showPersoFilesDropdown;
              _showPoolDropdown = false;
              _showThemesDropdown = false;
              _showTeacherQuizzesDropdown = false;
              _showCountDropdown = false;
            }),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: _persoFiles.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Aucun quiz perso trouvé dans Eskolia/Quiz/',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
                            ),
                          ),
                        ]
                      : [
                          _buildThemeCheckboxRow(
                            title: 'Tous les quiz persos',
                            value: isAllPersoSelected,
                            onChanged: (val) {
                              setState(() {
                                if (isAllPersoSelected) {
                                  _selectedPersoFiles = _persoFiles.isNotEmpty ? [_persoFiles.first] : [];
                                } else {
                                  _selectedPersoFiles = List.from(_persoFiles);
                                }
                              });
                            },
                            isBold: true,
                            activeColor: greenColor,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          ..._persoFiles.map((f) {
                            final isSel = _selectedPersoFiles.contains(f);
                            return _buildThemeCheckboxRow(
                              title: f,
                              value: isSel,
                              onChanged: (val) {
                                setState(() {
                                  if (isSel) {
                                    if (_selectedPersoFiles.length > 1) {
                                      _selectedPersoFiles.remove(f);
                                    }
                                  } else {
                                    _selectedPersoFiles.add(f);
                                  }
                                });
                              },
                              activeColor: greenColor,
                            );
                          }),
                        ],
                ),
              ),
            ),
          ),
        ],

        if (_selectedPools.contains('teacher')) ...[
          const SizedBox(height: 12),
          _buildCollapsibleSelector(
            label: 'Quiz du prof sélectionnés',
            valueText: teacherQuizzesText,
            icon: Icons.school_rounded,
            color: greenColor,
            isOpen: _showTeacherQuizzesDropdown,
            onTap: () => setState(() {
              _showTeacherQuizzesDropdown = !_showTeacherQuizzesDropdown;
              _showPoolDropdown = false;
              _showThemesDropdown = false;
              _showPersoFilesDropdown = false;
              _showCountDropdown = false;
            }),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: _teacherQuizzes.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Aucun quiz du prof publié pour l\'instant.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
                            ),
                          ),
                        ]
                      : [
                          _buildThemeCheckboxRow(
                            title: 'Tous les quiz du prof',
                            value: isAllTeacherSelected,
                            onChanged: (val) {
                              setState(() {
                                if (isAllTeacherSelected) {
                                  _selectedTeacherQuizIds = _teacherQuizzes.isNotEmpty ? [_teacherQuizzes.first.id] : [];
                                } else {
                                  _selectedTeacherQuizIds = _teacherQuizzes.map((q) => q.id).toList();
                                }
                              });
                            },
                            isBold: true,
                            activeColor: greenColor,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          ..._teacherQuizzes.map((q) {
                            final isSel = _selectedTeacherQuizIds.contains(q.id);
                            return _buildThemeCheckboxRow(
                              title: q.title,
                              value: isSel,
                              onChanged: (val) {
                                setState(() {
                                  if (isSel) {
                                    if (_selectedTeacherQuizIds.length > 1) {
                                      _selectedTeacherQuizIds.remove(q.id);
                                    }
                                  } else {
                                    _selectedTeacherQuizIds.add(q.id);
                                  }
                                });
                              },
                              activeColor: greenColor,
                            );
                          }),
                        ],
                ),
              ),
            ),
          ),
        ],

        if (_selectedPools.contains('base')) ...[
          const SizedBox(height: 12),
          // Dropdown Theme Selector Box
          _buildCollapsibleSelector(
            label: 'Sujet sélectionné',
            valueText: themeText,
            icon: Icons.category_rounded,
            color: greenColor,
            isOpen: _showThemesDropdown,
            onTap: () => setState(() {
              _showThemesDropdown = !_showThemesDropdown;
              _showPoolDropdown = false;
              _showPersoFilesDropdown = false;
              _showTeacherQuizzesDropdown = false;
              _showCountDropdown = false;
            }),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  _buildThemeCheckboxRow(
                    title: 'Tous les thèmes',
                    value: isAllThemesSelected,
                    onChanged: (val) {
                      setState(() {
                        if (isAllThemesSelected) {
                          _selectedThemeIds = [_themes.first['id']!];
                        } else {
                          _selectedThemeIds = _themes.map((t) => t['id']!).toList();
                        }
                      });
                    },
                    isBold: true,
                    activeColor: greenColor,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ..._themes.map((t) {
                    final id = t['id']!;
                    final title = t['title']!;
                    final isSelected = isAllThemesSelected || _selectedThemeIds.contains(id);
                    return _buildThemeCheckboxRow(
                      title: title,
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (isAllThemesSelected) {
                            _selectedThemeIds = _themes.map((theme) => theme['id']!).toList();
                            _selectedThemeIds.remove(id);
                          } else {
                            if (val == true) {
                              _selectedThemeIds.add(id);
                            } else {
                              if (_selectedThemeIds.length > 1) {
                                _selectedThemeIds.remove(id);
                              }
                            }
                          }
                        });
                      },
                      activeColor: greenColor,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],

        // Expanded options: Questions Count dropdown and Difficulty
        if (!isCollapsed) ...[
          const SizedBox(height: 12),
          // Collapsible questions count selector
          _buildCollapsibleSelector(
            label: 'Nombre de questions',
            valueText: '$_questionCount questions',
            icon: Icons.format_list_numbered_rounded,
            color: greenColor,
            isOpen: _showCountDropdown,
            onTap: () => setState(() {
              _showCountDropdown = !_showCountDropdown;
              _showPoolDropdown = false;
              _showThemesDropdown = false;
              _showPersoFilesDropdown = false;
              _showTeacherQuizzesDropdown = false;
            }),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [5, 10, 15, 20].map((n) {
                  return Column(
                    children: [
                      _buildDropdownItemRow(
                        title: '$n questions',
                        isSelected: _questionCount == n,
                        onTap: () => setState(() {
                          _questionCount = n;
                          _showCountDropdown = false;
                        }),
                      ),
                      if (n != 20) const Divider(color: Colors.white10, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          
          if (_selectedPools.contains('base')) ...[
            const SizedBox(height: 12),
            // Difficulty Selector
            const Text('Difficulté :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildDifficultyButton(
                  label: 'Facile',
                  dotColor: const Color(0xFF00E676),
                  activeColor: const Color(0xFF00E676),
                ),
                const SizedBox(width: 6),
                _buildDifficultyButton(
                  label: 'Moyen',
                  dotColor: const Color(0xFFFFA000),
                  activeColor: const Color(0xFFFFA000),
                ),
                const SizedBox(width: 6),
                _buildDifficultyButton(
                  label: 'Difficile',
                  dotColor: const Color(0xFFFF1744),
                  activeColor: const Color(0xFFFF1744),
                ),
              ],
            ),
          ],


        ],

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: (_dueCount == 0 || _busy) ? null : _launchDueSession,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _dueCount > 0 ? greenColor : Colors.white24,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  _dueCount > 0 ? 'Réviser ($_dueCount)' : 'À jour',
                  style: TextStyle(
                    color: _dueCount > 0 ? Colors.white : Colors.white30,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _launchFilteredFlashcards,
                icon: _busy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 14),
                label: const Text('Lancer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
