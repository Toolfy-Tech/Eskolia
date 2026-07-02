import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/services/asset_cache_service.dart';
import '../../../../core/services/eskolia_folder_service.dart';
import '../../../admin/data/models/teacher_quiz.dart';
import '../../../quiz/models/quiz_models.dart';
import '../../../quiz/services/quiz_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/lobby_repository.dart';
import '../../../parcours/data/tip_quiz_catalog.dart';

class LobbyCreateCardBody extends ConsumerStatefulWidget {
  const LobbyCreateCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<LobbyCreateCardBody> createState() => _LobbyCreateCardBodyState();
}

class _LobbyCreateCardBodyState extends ConsumerState<LobbyCreateCardBody> {
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
  bool _isPrivate = false;
  bool _correctionAtEnd = true;
  int _questionCount = 10;
  final Set<String> _selectedDifficulties = {'Facile', 'Moyen', 'Difficile'};
  final bool _isSurvival = false;
  bool _loading = false;

  // Dropdown visibility states
  bool _showPoolDropdown = false;
  bool _showThemesDropdown = false;
  bool _showPersoFilesDropdown = false;
  bool _showTeacherQuizzesDropdown = false;
  bool _showCountDropdown = false;

  // Pools state variables
  Set<String> _selectedPools = {'base'};
  List<String> _selectedPersoFiles = [];
  List<String> _selectedTeacherQuizIds = [];
  List<String> _persoFiles = [];
  List<TeacherQuiz> _teacherQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadPools();
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
      debugPrint('Error loading custom/teacher pools: $e');
    }
  }



  Future<void> _createLobby() async {
    if (_selectedDifficulties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez au moins une difficulté')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final questions = <QuizQuestion>[];
      final difficultyFilters = _selectedDifficulties.map((d) => d.toLowerCase()).toSet();

      // 1. Base App
      final selectedPaths = <String>[];
      if (_selectedPools.contains('base')) {
        final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
        final optimusChapters = allChapters.where((c) => c.track == QuizCatalogTrack.optimusOnly).toList();
        
        final filteredChapters = _selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length
            ? optimusChapters
            : optimusChapters.where((c) => _selectedThemeIds.contains(c.sectionId)).toList();

        selectedPaths.addAll(filteredChapters.map((c) => c.quizAssetPath));
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
                questions.addAll(parsed.where((q) => difficultyFilters.isEmpty || difficultyFilters.contains(q.difficultyBucket)));
              } else {
                final decoded = jsonDecode(raw) as Map<String, dynamic>;
                final rawQ = decoded['questions'] as List<dynamic>? ?? [];
                for (int i = 0; i < rawQ.length; i++) {
                  final q = rawQ[i] as Map<String, dynamic>;
                  final db = (q['difficulty'] as String? ?? 'moyen').toLowerCase();
                  if (difficultyFilters.isEmpty || difficultyFilters.contains(db)) {
                    questions.add(QuizQuestion(
                      id: 'notebook_${file}_$i',
                      type: q['type'] as String? ?? 'classic',
                      question: q['question'] as String? ?? '',
                      answer: q['answer'] as String? ?? '',
                      difficultyBucket: db,
                      contextLine: 'Notebook · ${decoded['quiz']?['title'] ?? file}',
                    ));
                  }
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
                final db = (q['difficulty'] as String? ?? 'moyen').toLowerCase();
                if (difficultyFilters.isEmpty || difficultyFilters.contains(db)) {
                  questions.add(QuizQuestion(
                    id: 'teacher_${id}_$i',
                    type: q['type'] as String? ?? 'classic',
                    question: q['question'] as String? ?? '',
                    answer: q['answer'] as String? ?? '',
                    difficultyBucket: db,
                    contextLine: q['contextLine'] as String? ?? 'Quiz du prof · $title',
                    authorName: authorName,
                  ));
                }
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

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      String name = 'Hôte';
      if (uid != 'guest') {
        final userDoc = await UserRepository().getUserById(uid);
        if (userDoc != null && userDoc.username.isNotEmpty) {
          name = userDoc.username;
        }
      }

      final diffLabel = _selectedDifficulties.length >= 3
          ? 'mixte'
          : _selectedDifficulties.map((d) => d.toLowerCase()).join('+');

      final customQs = limitedQuestions.map((q) => {
        'id': q.id,
        'type': q.type,
        'question': q.question,
        'answer': q.answerSequence ?? q.answer,
        'explanation': q.explanation,
        'options': q.options,
        'checklist': q.checklist,
        'indices': q.indices,
        'contextLine': q.contextLine,
        'difficulty': q.difficultyBucket,
      }).toList();

      String subjectLabel = '';
      if (_selectedPools.length > 1) {
        subjectLabel = 'Quiz Mixte · ${_selectedPools.length} pools';
      } else if (_selectedPools.contains('perso')) {
        subjectLabel = 'Quiz Perso · ${_selectedPersoFiles.length} fichier(s)';
      } else if (_selectedPools.contains('teacher')) {
        subjectLabel = 'Quiz Prof · ${_selectedTeacherQuizIds.length} fichier(s)';
      } else {
        subjectLabel = '${TipQuizCatalog.subjectLabelForPaths(selectedPaths)} · ${selectedPaths.length} thème(s)';
      }

      final lobbyId = await LobbyRepository().createLobby(LobbyModel(
        id: '',
        title: 'Salon de $name',
        subject: subjectLabel,
        hostName: name,
        hostAvatar: '\u{1F4AC}',
        currentPlayers: 1,
        maxPlayers: kLobbyMaxPlayers,
        status: 'waiting',
        difficulty: diffLabel,
        quizId: 'custom',
        createdAt: DateTime.now(),
        hostId: uid,
        questionAssetPaths: const [],
        customQuestionsJson: jsonEncode(customQs),
        isPrivate: _isPrivate,
        correctionMode: _correctionAtEnd ? 'at_end' : 'after_each',
        gameMode: _isSurvival ? kLobbyGameModeSurvival : kLobbyGameModeQuiz,
        timed: false,
        questionCount: limitedQuestions.length,
        difficultyFilters: _selectedDifficulties.map((d) => d.toLowerCase()).toList(),
        playerMeta: [PlayerMeta(userId: uid, displayName: name, avatar: '\u{1F4AC}')],
      ));

      if (!mounted) return;
      context.push('/lobby/$lobbyId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildBlockToggle({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.swap_horiz_rounded, color: color.withValues(alpha: 0.7), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required String label,
    required Color dotColor,
    required Color activeColor,
    required Color accentColor,
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
    Color activeColor = Colors.pinkAccent,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: activeColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCheckboxRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isBold = false,
    Color activeColor = Colors.pinkAccent,
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

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:lobbys_create']?.isCollapsed ?? false);

    String poolText = '';
    final isAllPoolsSelected = _selectedPools.length == 3;
    if (isAllPoolsSelected) {
      poolText = 'Tous les pools';
    } else {
      final List<String> parts = [];
      if (_selectedPools.contains('base')) parts.add('Base');
      if (_selectedPools.contains('perso')) parts.add('Perso');
      if (_selectedPools.contains('teacher')) parts.add('Prof');
      poolText = parts.join(' + ');
    }

    String persoFilesText = '';
    final isAllPersoSelected = _selectedPersoFiles.length == _persoFiles.length;
    if (_selectedPersoFiles.isEmpty) {
      persoFilesText = 'Aucun fichier';
    } else if (isAllPersoSelected) {
      persoFilesText = 'Tous les quiz (${_persoFiles.length})';
    } else if (_selectedPersoFiles.length == 1) {
      persoFilesText = _selectedPersoFiles.first;
    } else {
      persoFilesText = '${_selectedPersoFiles.length} quiz';
    }

    String teacherQuizzesText = '';
    final isAllTeacherSelected = _selectedTeacherQuizIds.length == _teacherQuizzes.length;
    if (_selectedTeacherQuizIds.isEmpty) {
      teacherQuizzesText = 'Aucun quiz';
    } else if (isAllTeacherSelected) {
      teacherQuizzesText = 'Tous les quiz (${_teacherQuizzes.length})';
    } else if (_selectedTeacherQuizIds.length == 1) {
      final q = _teacherQuizzes.firstWhere((t) => t.id == _selectedTeacherQuizIds.first);
      teacherQuizzesText = q.title;
    } else {
      teacherQuizzesText = '${_selectedTeacherQuizIds.length} quiz';
    }

    String themeText;
    if (_selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length) {
      themeText = 'Tous les thèmes';
    } else if (_selectedThemeIds.length == 1) {
      final t = _themes.firstWhere((theme) => theme['id'] == _selectedThemeIds.first);
      themeText = t['title']!;
    } else {
      themeText = '${_selectedThemeIds.length} thèmes';
    }

    const accentColor = Colors.pinkAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pools selector dropdown
        _buildCollapsibleSelector(
          label: 'Pools de questions',
          valueText: poolText,
          icon: Icons.layers_rounded,
          color: accentColor,
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
                  activeColor: accentColor,
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
                  activeColor: accentColor,
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
                  activeColor: accentColor,
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
                  activeColor: accentColor,
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
            color: accentColor,
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
                            title: 'Tous les quiz quiz persos',
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
                            activeColor: accentColor,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          ..._persoFiles.map((file) {
                            final isSelected = _selectedPersoFiles.contains(file);
                            return _buildThemeCheckboxRow(
                              title: file.replaceAll('.json', ''),
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedPersoFiles.add(file);
                                  } else {
                                    if (_selectedPersoFiles.length > 1) {
                                      _selectedPersoFiles.remove(file);
                                    }
                                  }
                                });
                              },
                              activeColor: accentColor,
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
            label: 'Quiz profs sélectionnés',
            valueText: teacherQuizzesText,
            icon: Icons.school_rounded,
            color: accentColor,
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
                              'Aucun quiz de professeur publié.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
                            ),
                          ),
                        ]
                      : [
                          _buildThemeCheckboxRow(
                            title: 'Tous les quiz profs',
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
                            activeColor: accentColor,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          ..._teacherQuizzes.map((quiz) {
                            final isSelected = _selectedTeacherQuizIds.contains(quiz.id);
                            return _buildThemeCheckboxRow(
                              title: '${quiz.title} (par ${quiz.authorName})',
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedTeacherQuizIds.add(quiz.id);
                                  } else {
                                    if (_selectedTeacherQuizIds.length > 1) {
                                      _selectedTeacherQuizIds.remove(quiz.id);
                                    }
                                  }
                                });
                              },
                              activeColor: accentColor,
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
          // Collapsible Theme Selector
          _buildCollapsibleSelector(
            label: 'Thèmes de questions',
            valueText: themeText,
            icon: Icons.meeting_room_rounded,
            color: accentColor,
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
                    value: _selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length,
                    onChanged: (val) {
                      setState(() {
                        if (_selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length) {
                          _selectedThemeIds = [_themes.first['id']!];
                        } else {
                          _selectedThemeIds.clear();
                        }
                      });
                    },
                    isBold: true,
                    activeColor: accentColor,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ..._themes.map((t) {
                    final id = t['id']!;
                    final title = t['title']!;
                    final isAllSelected = _selectedThemeIds.isEmpty || _selectedThemeIds.length == _themes.length;
                    final isSelected = isAllSelected || _selectedThemeIds.contains(id);
                    return _buildThemeCheckboxRow(
                      title: title,
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (isAllSelected) {
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
                      activeColor: accentColor,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],

        // Expanded fields
        if (!isCollapsed) ...[
          const SizedBox(height: 12),
          // Collapsible questions count selector
          _buildCollapsibleSelector(
            label: 'Nombre de questions',
            valueText: '$_questionCount questions',
            icon: Icons.format_list_numbered_rounded,
            color: accentColor,
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
                children: [5, 10, 15, 20, 25, 30].map((n) {
                  return Column(
                    children: [
                      _buildDropdownItemRow(
                        title: '$n questions',
                        isSelected: _questionCount == n,
                        onTap: () => setState(() {
                          _questionCount = n;
                          _showCountDropdown = false;
                        }),
                        activeColor: accentColor,
                      ),
                      if (n != 30) const Divider(color: Colors.white10, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Visibility Block Toggle
          _buildBlockToggle(
            label: 'Visibilité du salon',
            value: _isPrivate ? 'Privé (sur Code)' : 'Public',
            icon: _isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded,
            color: accentColor,
            onTap: () => setState(() => _isPrivate = !_isPrivate),
          ),
          const SizedBox(height: 10),
          // Correction Block Toggle
          _buildBlockToggle(
            label: 'Correction',
            value: _correctionAtEnd ? 'À la fin du quiz' : 'Après chaque question',
            icon: _correctionAtEnd ? Icons.playlist_add_check_rounded : Icons.question_answer_rounded,
            color: accentColor,
            onTap: () => setState(() => _correctionAtEnd = !_correctionAtEnd),
          ),

          const SizedBox(height: 12),
          // Difficulties
          const Text('Difficultés :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildDifficultyButton(
                label: 'Facile',
                dotColor: const Color(0xFF00E676),
                activeColor: const Color(0xFF00E676),
                accentColor: accentColor,
              ),
              const SizedBox(width: 6),
              _buildDifficultyButton(
                label: 'Moyen',
                dotColor: const Color(0xFFFFA000),
                activeColor: const Color(0xFFFFA000),
                accentColor: accentColor,
              ),
              const SizedBox(width: 6),
              _buildDifficultyButton(
                label: 'Difficile',
                dotColor: const Color(0xFFFF1744),
                activeColor: const Color(0xFFFF1744),
                accentColor: accentColor,
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _loading ? null : _createLobby,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: _loading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Icon(Icons.add_rounded, size: 16),
          label: const Text('Créer le salon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
