import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/teacher_quiz_picker_widget.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../../quiz/presentation/widgets/quiz_catalog_track_selector.dart';
import '../../quiz/presentation/widgets/quiz_scope_picker.dart';
import '../../../data/repositories/user_repository.dart';
import '../data/lobby_repository.dart';
import '../data/models/custom_quiz_data.dart';
import 'widgets/custom_quiz_import_widget.dart';
import '../../ai/data/ai_key_repository.dart';
import '../../notebook/data/note_ai_generator.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF64748B);
const Color _slateLight = Color(0xFF94A3B8);
const Color _surface = Color(0xFF1E293B);
const Color _green = Color(0xFF10B981);
const Color _orange = Color(0xFFFF9800);
const Color _red = Color(0xFFE53935);

class LobbyListScreen extends StatefulWidget {
  const LobbyListScreen({super.key});

  @override
  State<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen>
    with SingleTickerProviderStateMixin {
  final LobbyRepository _repo = LobbyRepository();
  int _retry = 0;
  late AnimationController _pulse;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _cleanupStale();
    _checkStaff();
  }

  Future<void> _checkStaff() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final user = await UserRepository().getUserById(uid);
      if (mounted && user != null) setState(() => _isStaff = user.isStaff);
    } catch (_) {}
  }

  Future<void> _cleanupStale() async {
    try {
      await _repo.cleanupStaleLobbies();
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  List<LobbyModel> _joinableLobbies(List<LobbyModel> all) {
    final open = all
        .where(
          (l) =>
              (l.status == 'waiting' || l.status == 'in_progress') &&
              !l.isFull,
        )
        .toList();
    open.sort((a, b) {
      final wa = a.status == 'waiting' ? 0 : 1;
      final wb = b.status == 'waiting' ? 0 : 1;
      if (wa != wb) return wa.compareTo(wb);
      return b.createdAt.compareTo(a.createdAt);
    });
    return open;
  }

  Future<void> _joinByCode() async {
    final ctrl = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF151B2E).withValues(alpha: 0.94),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            title: const Text(
              'Rejoindre par code',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white, letterSpacing: 2),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Ex. A2K9P4',
                hintStyle: TextStyle(color: _slateLight.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Annuler', style: TextStyle(color: _slateLight)),
              ),
              FilledButton(
                onPressed: () async {
                  final raw = ctrl.text.trim();
                  if (raw.length < 4) return;
                  final found = await _repo.findLobbyIdByJoinCode(raw);
                  if (!ctx.mounted) return;
                  if (found == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Code introuvable ou lobby fermé.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx, found);
                },
                style: FilledButton.styleFrom(backgroundColor: _cyan),
                child: const Text('Rejoindre'),
              ),
            ],
          ),
        );
      },
    );
    ctrl.dispose();
    if (id != null && mounted) {
      context.push('/lobby/$id');
    }
  }

  Widget _buildLobbyVisibilitySegment({
    required bool isPrivate,
    required void Function(bool value) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Visibilité',
          style: TextStyle(color: _slateLight, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment<bool>(
              value: false,
              label: Text('Public'),
              icon: Icon(Icons.public_outlined, size: 18),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text('Privé'),
              icon: Icon(Icons.lock_outline, size: 18),
            ),
          ],
          selected: {isPrivate},
          onSelectionChanged: (s) {
            if (s.isEmpty) return;
            onChanged(s.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          isPrivate
              ? 'Pas dans la liste des lobbies : un code est généré pour que tes coéquipiers rejoignent.'
              : "Visible dans la liste tant qu'il reste des places (jusqu'à $kLobbyMaxPlayers joueurs).",
          style: TextStyle(
            color: _slateLight.withValues(alpha: 0.85),
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectionModeSegment({
    required bool correctionAtEnd,
    required void Function(bool value) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Correction', style: TextStyle(color: _slateLight, fontSize: 12)),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment<bool>(
              value: true,
              label: Text('À la fin'),
              icon: Icon(Icons.playlist_add_check_rounded, size: 18),
            ),
            ButtonSegment<bool>(
              value: false,
              label: Text('Après chaque question'),
              icon: Icon(Icons.manage_search_rounded, size: 18),
            ),
          ],
          selected: {correctionAtEnd},
          onSelectionChanged: (s) {
            if (s.isEmpty) return;
            onChanged(s.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          correctionAtEnd
              ? 'Les réponses sont corrigées toutes ensemble à la fin du quiz.'
              : 'Le créateur corrige les réponses après chaque question avant de passer à la suivante.',
          style: TextStyle(color: _slateLight.withValues(alpha: 0.85), fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Future<void> _openCreateDialog() async {
    var selectedPaths = <String>{};
    var catalogTrack = QuizCatalogTrack.optimusOnly;
    final catalogFuture = TipQuizCatalog.loadChaptersWithQuiz();
    var questionCount = 15;
    var useCustomSource = false;
    var useAiSource = false;
    CustomQuizData? customQuizData;
    final aiThemeCtrl = TextEditingController();
    var aiDifficulty = 'mixte';
    var aiGenerating = false;
    String? aiError;
    final aiKeyRepo = AiKeyRepository();
    final aiGenerator = NoteAiGenerator();
    final difficulties = <String>{
      'facile',
      'moyen',
      'difficile',
    };
    var isPrivateLobby = false;
    var correctionAtEnd = true;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    // Priorité : username Firestore > displayName Firebase Auth > préfixe email
    String name = FirebaseAuth.instance.currentUser?.displayName ??
        FirebaseAuth.instance.currentUser?.email?.split('@').first ??
        'Hôte';
    if (uid != 'guest') {
      try {
        final userDoc = await UserRepository().getUserById(uid);
        if (userDoc != null && userDoc.username.isNotEmpty) {
          name = userDoc.username;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    final created = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF151B2E).withValues(alpha: 0.94),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            title: const Text(
              'Nouveau lobby',
              style: TextStyle(color: Colors.white),
            ),
            content: StatefulBuilder(
              builder: (context, setD) {
                return SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Titre automatique : Quiz multi de $name · '
                        '$kLobbyMaxPlayers places max.',
                        style: TextStyle(
                          color: _slateLight.withValues(alpha: 0.9),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quiz multijoueur : +10 pts par bonne réponse, mêmes manches pour tout le monde.',
                        style: TextStyle(
                          color: _slateLight.withValues(alpha: 0.88),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildLobbyVisibilitySegment(
                        isPrivate: isPrivateLobby,
                        onChanged: (v) => setD(() => isPrivateLobby = v),
                      ),
                      const SizedBox(height: 12),
                      _buildCorrectionModeSegment(
                        correctionAtEnd: correctionAtEnd,
                        onChanged: (v) => setD(() => correctionAtEnd = v),
                      ),
                      const SizedBox(height: 14),
                      const SizedBox(height: 8),
                      Text(
                        'Difficulté des questions',
                        style: TextStyle(color: _slateLight, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Facile'),
                            selected: difficulties.contains('facile'),
                            onSelected: (v) => setD(() {
                              if (v) {
                                difficulties.add('facile');
                              } else {
                                difficulties.remove('facile');
                              }
                            }),
                          ),
                          FilterChip(
                            label: const Text('Moyen'),
                            selected: difficulties.contains('moyen'),
                            onSelected: (v) => setD(() {
                              if (v) {
                                difficulties.add('moyen');
                              } else {
                                difficulties.remove('moyen');
                              }
                            }),
                          ),
                          FilterChip(
                            label: const Text('Difficile'),
                            selected: difficulties.contains('difficile'),
                            onSelected: (v) => setD(() {
                              if (v) {
                                difficulties.add('difficile');
                              } else {
                                difficulties.remove('difficile');
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sans niveau clair dans le JSON → traité comme « moyen » si tu coches Moyen.',
                        style: TextStyle(
                          color: _slateLight.withValues(alpha: 0.75),
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nombre de questions : $questionCount',
                        style: TextStyle(color: _slateLight, fontSize: 12),
                      ),
                      Slider(
                        value: questionCount.toDouble(),
                        min: kLobbyMinQuestionCount.toDouble(),
                        max: kLobbyMaxQuestionCount.toDouble(),
                        divisions:
                            kLobbyMaxQuestionCount - kLobbyMinQuestionCount,
                        label: '$questionCount',
                        activeColor: _violet,
                        onChanged: (v) => setD(
                          () => questionCount = v.round().clamp(
                            kLobbyMinQuestionCount,
                            kLobbyMaxQuestionCount,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── Source des questions ────────────────────────
                      Text('Sources des questions',
                          style: TextStyle(color: _slateLight, fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Chapitres'),
                            selected: !useCustomSource && !useAiSource,
                            onSelected: (_) => setD(() {
                              useCustomSource = false;
                              useAiSource = false;
                              customQuizData = null;
                              aiError = null;
                            }),
                            selectedColor: _cyan.withValues(alpha: 0.2),
                            checkmarkColor: _cyan,
                            labelStyle: TextStyle(
                              color: (!useCustomSource && !useAiSource) ? _cyan : _slateLight,
                              fontSize: 12,
                            ),
                          ),
                          FilterChip(
                            label: const Text('Mon quiz .json'),
                            selected: useCustomSource,
                            onSelected: (v) => setD(() {
                              useCustomSource = v;
                              if (v) useAiSource = false;
                              if (!v) customQuizData = null;
                            }),
                            selectedColor: _violet.withValues(alpha: 0.25),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: useCustomSource ? Colors.white : _slateLight,
                              fontSize: 12,
                            ),
                          ),
                          FilterChip(
                            label: const Text('IA'),
                            selected: useAiSource,
                            onSelected: (v) => setD(() {
                              useAiSource = v;
                              if (v) useCustomSource = false;
                              customQuizData = null;
                              aiError = null;
                            }),
                            selectedColor: const Color(0xFFFFC107).withValues(alpha: 0.25),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: useAiSource ? Colors.white : _slateLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (useCustomSource) ...[
                        CustomQuizImportWidget(
                          importedData: customQuizData,
                          onImported: (d) => setD(() => customQuizData = d),
                        ),
                      ] else if (useAiSource) ...[
                        _buildAiQuizGenerator(
                          setD: setD,
                          themeCtrl: aiThemeCtrl,
                          difficulty: aiDifficulty,
                          onDifficultyChanged: (v) => setD(() => aiDifficulty = v),
                          questionCount: questionCount,
                          generating: aiGenerating,
                          generatedData: customQuizData,
                          error: aiError,
                          onGenerate: () async {
                            final theme = aiThemeCtrl.text.trim();
                            if (theme.isEmpty) {
                              setD(() => aiError = 'Saisis un theme avant de generer.');
                              return;
                            }
                            setD(() { aiGenerating = true; aiError = null; customQuizData = null; });
                            try {
                              final aiState = await aiKeyRepo.watch().first;
                              if (!aiState.isConnected) {
                                setD(() { aiError = 'Connecte ton IA dans Profil > IA.'; aiGenerating = false; });
                                return;
                              }
                              final buffer = StringBuffer();
                              await for (final token in aiGenerator.streamQuizFromTheme(
                                apiKey: aiState.apiKey!,
                                provider: aiState.provider,
                                theme: theme,
                                questionCount: questionCount,
                                difficulty: aiDifficulty,
                              )) {
                                buffer.write(token);
                              }
                              final raw = NoteAiGenerator.extractJson(buffer.toString());
                              final data = CustomQuizData.fromJsonString(raw);
                              setD(() { customQuizData = data; aiGenerating = false; });
                            } on FormatException catch (e) {
                              setD(() { aiError = 'Format invalide : ${e.message}'; aiGenerating = false; });
                            } catch (e) {
                              setD(() { aiError = e.toString(); aiGenerating = false; });
                            }
                          },
                          onReset: () => setD(() { customQuizData = null; aiError = null; }),
                        ),
                      ] else ...[
                        Text(
                          selectedPaths.isEmpty
                              ? 'Aucun chapitre sélectionné'
                              : '${selectedPaths.length} chapitre(s) sélectionné(s)',
                          style: TextStyle(
                            color: selectedPaths.isEmpty ? _slateLight.withValues(alpha: 0.6) : _cyan,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        QuizCatalogTrackSelector(
                          value: catalogTrack,
                          dense: true,
                          onChanged: (t) {
                            catalogFuture.then((all) {
                              if (!ctx.mounted) return;
                              final allowed = TipQuizCatalog.filterByTrack(all, t)
                                  .map((e) => e.quizAssetPath)
                                  .toSet();
                              setD(() {
                                catalogTrack = t;
                                selectedPaths.removeWhere(
                                    (p) => !allowed.contains(p));
                              });
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 260,
                          child: catalogTrack == QuizCatalogTrack.teacher
                              ? TeacherQuizPickerWidget(
                                  selectedPath: selectedPaths.firstOrNull,
                                  onSelected: (path) =>
                                      setD(() => selectedPaths = {path}),
                                )
                              : FutureBuilder<List<TipQuizChapterRef>>(
                                  future: catalogFuture,
                                  builder: (context, snap) {
                                    if (snap.connectionState != ConnectionState.done) {
                                      return const Center(
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: _cyan),
                                        ),
                                      );
                                    }
                                    if (snap.hasError) {
                                      return Center(
                                        child: Text(
                                          'Erreur catalogue.\n${snap.error}',
                                          style: TextStyle(
                                              color: Colors.red.shade200,
                                              fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    final all = snap.data ?? [];
                                    final entries = TipQuizCatalog.filterByTrack(all, catalogTrack);
                                    return QuizScopePicker(
                                      entries: entries,
                                      selectedPaths: selectedPaths,
                                      onSelectionChanged: (s) =>
                                          setD(() => selectedPaths = Set<String>.from(s)),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Annuler', style: TextStyle(color: _slateLight)),
              ),
              FilledButton(
                onPressed: () async {
                  // Validation selon la source active
                  if (useCustomSource || useAiSource) {
                    if (customQuizData == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(useAiSource
                            ? 'Genere un quiz avec l\'IA avant de creer le lobby.'
                            : 'Importe un fichier .json avant de creer le lobby.')),
                      );
                      return;
                    }
                  } else {
                    if (selectedPaths.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Choisis au moins une section ou un chapitre.')),
                      );
                      return;
                    }
                    if (difficulties.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Coche au moins un niveau de difficulté.')),
                      );
                      return;
                    }
                  }

                  try {
                    String lobbyId;
                    if ((useCustomSource || useAiSource) && customQuizData != null) {
                      final data = customQuizData!;
                      // Convertir les questions au format tipJson
                      final qs = data.questions.asMap().entries.map((e) => {
                        'id': 'cq_${e.key}',
                        'question': e.value.question,
                        'answer': e.value.answer,
                        'difficultyBucket': e.value.difficulty,
                        'type': e.value.type,
                        if (e.value.hint.isNotEmpty) 'explanation': e.value.hint,
                        if (e.value.contextLine != null && e.value.contextLine!.isNotEmpty)
                          'contextLine': e.value.contextLine,
                        if (e.value.indices.isNotEmpty) 'indices': e.value.indices,
                        // sequence : items = answerSequence ET options (pour le drag & drop)
                        if (e.value.items.isNotEmpty) 'answerSequence': e.value.items,
                        if (e.value.items.isNotEmpty) 'options': e.value.items,
                      }).toList();
                      lobbyId = await _repo.createLobby(LobbyModel(
                        id: '',
                        title: '"${data.title}" par $name',
                        subject: 'Quiz personnalisé · ${data.questions.length} questions',
                        hostName: name,
                        hostAvatar: '\u{1F4C2}',
                        currentPlayers: 1,
                        maxPlayers: kLobbyMaxPlayers,
                        status: 'waiting',
                        difficulty: 'mixte',
                        quizId: 'custom',
                        createdAt: DateTime.now(),
                        hostId: uid,
                        questionAssetPaths: const [],
                        customQuestionsJson: jsonEncode(qs),
                        isPrivate: isPrivateLobby,
                        correctionMode: correctionAtEnd ? 'at_end' : 'after_each',
                        gameMode: kLobbyGameModeQuiz,
                        timed: false,
                        questionCount: data.questions.length.clamp(kLobbyMinQuestionCount, kLobbyMaxQuestionCount),
                        difficultyFilters: const ['facile', 'moyen', 'difficile'],
                        playerMeta: [PlayerMeta(userId: uid, displayName: name, avatar: '\u{1F4C2}')],
                      ));
                    } else {
                      final diffLabel = difficulties.length >= 3 ? 'mixte' : difficulties.join('+');
                      lobbyId = await _repo.createLobby(LobbyModel(
                        id: '',
                        title: 'Quiz multi de $name',
                        subject: '${TipQuizCatalog.subjectLabelForPaths(selectedPaths.toList())} · '
                            '${selectedPaths.length} source(s) Maîtrise',
                        hostName: name,
                        hostAvatar: '\u{2694}\u{FE0F}',
                        currentPlayers: 1,
                        maxPlayers: kLobbyMaxPlayers,
                        status: 'waiting',
                        difficulty: diffLabel,
                        quizId: TipQuizCatalog.quizIdForPaths(selectedPaths.toList()),
                        createdAt: DateTime.now(),
                        hostId: uid,
                        questionAssetPaths: selectedPaths.toList(),
                        isPrivate: isPrivateLobby,
                        correctionMode: correctionAtEnd ? 'at_end' : 'after_each',
                        gameMode: kLobbyGameModeQuiz,
                        timed: false,
                        questionCount: questionCount,
                        difficultyFilters: difficulties.toList(),
                        playerMeta: [PlayerMeta(userId: uid, displayName: name, avatar: '\u{2694}\u{FE0F}')],
                      ));
                    }
                    if (ctx.mounted) Navigator.pop(ctx, lobbyId);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Création impossible : $e')),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: _violet),
                child: const Text('Créer le lobby'),
              ),
            ],
          ),
        );
      },
    );

    aiThemeCtrl.dispose();
    if (created != null && mounted) {
      context.push('/lobby/$created');
    }
  }


  Widget _buildAiQuizGenerator({
    required StateSetter setD,
    required TextEditingController themeCtrl,
    required String difficulty,
    required ValueChanged<String> onDifficultyChanged,
    required int questionCount,
    required bool generating,
    required CustomQuizData? generatedData,
    required String? error,
    required VoidCallback onGenerate,
    required VoidCallback onReset,
  }) {
    const amber = Color(0xFFFFC107);
    if (generatedData != null) {
      final preview = generatedData.questions.take(3).toList();
      final remaining = generatedData.questions.length - preview.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"${generatedData.title}" — ${generatedData.questions.length} questions',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < preview.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${i + 1} ', style: TextStyle(color: _violet, fontSize: 10, fontWeight: FontWeight.w700)),
                        Expanded(
                          child: Text(
                            preview[i].question,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _slateLight.withValues(alpha: 0.9), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (remaining > 0)
                  Text('+ $remaining autre${remaining > 1 ? 's' : ''} question${remaining > 1 ? 's' : ''}',
                      style: TextStyle(color: _slateLight, fontSize: 11)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onReset,
            style: TextButton.styleFrom(foregroundColor: _slateLight),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Regenerer'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: themeCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ex: Active Directory, VLAN, Securite reseau...',
            hintStyle: TextStyle(color: _slateLight.withValues(alpha: 0.6), fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        Text('Niveau', style: TextStyle(color: _slateLight, fontSize: 11)),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(value: 'facile', label: Text('Facile')),
            ButtonSegment(value: 'moyen', label: Text('Moyen')),
            ButtonSegment(value: 'difficile', label: Text('Difficile')),
            ButtonSegment(value: 'mixte', label: Text('Mix')),
          ],
          selected: {difficulty},
          onSelectionChanged: (s) { if (s.isNotEmpty) onDifficultyChanged(s.first); },
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.red.shade300, fontSize: 11)),
        ],
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: generating ? null : onGenerate,
          style: FilledButton.styleFrom(
            backgroundColor: amber,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: generating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
              : const Icon(Icons.auto_awesome_rounded, size: 18),
          label: Text(generating ? 'Generation en cours...' : 'Generer le quiz ($questionCount questions)'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Multijoueur',
        actions: [
          TextButton(
            onPressed: _joinByCode,
            child: Text(
              'Code',
              style: TextStyle(
                color: _cyan,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: StreamBuilder<List<LobbyModel>>(
              key: ValueKey(_retry),
              stream: _repo.watchLobbies(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return _error(snap.error.toString());
                }
                final waitingConnection =
                    snap.connectionState == ConnectionState.waiting &&
                        !snap.hasData;
                final all = snap.data ?? [];
                final joinable = _joinableLobbies(all);
                final waitingCount =
                    joinable.where((l) => l.status == 'waiting').length;
                final liveCount = joinable
                    .where((l) => l.status == 'in_progress')
                    .length;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    4,
                    hPad,
                    kEskoliaBottomNavReserve,
                  ),
                  children: [
                    Text(
                      'Lance une partie ou rejoins un lobby avec de la place.',
                      style: TextStyle(
                        color: _slateLight.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LobbyModeCard(
                      emoji: '\u{1F3AF}',
                      title: 'Quiz multi',
                      subtitle:
                          'Lobby classique : manches communes, +10 pts par bonne réponse, '
                          'choix des chapitres et du nombre de questions.',
                      onTap: _openCreateDialog,
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Lobbies à rejoindre',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (!waitingConnection && joinable.isNotEmpty)
                          _LobbyQueueBadges(
                            waitingCount: waitingCount,
                            liveCount: liveCount,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Salles en attente ou en cours — uniquement si des places sont libres.',
                      style: TextStyle(
                        color: _slateLight.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (waitingConnection) ..._skeletonSectionChildren(),
                    if (!waitingConnection && joinable.isEmpty)
                      _emptyLobbyQueueCard(),
                    if (!waitingConnection && joinable.isNotEmpty)
                      ...joinable.asMap().entries.map((e) {
                        final i = e.key;
                        final lobby = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LobbyCard(
                            lobby: lobby,
                            index: i,
                            showJoinCta: true,
                            onTap: () => context.push('/lobby/${lobby.id}'),
                            onDelete: (_isStaff ||
                                    lobby.hostId ==
                                        FirebaseAuth
                                            .instance.currentUser?.uid)
                                ? () => _repo.deleteLobby(lobby.id)
                                : null,
                            isAdminDelete: _isStaff &&
                                lobby.hostId !=
                                    FirebaseAuth.instance.currentUser?.uid,
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _skeletonSectionChildren() {
    return List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final c = Color.lerp(_surface, const Color(0xFF2D3748), _pulse.value)!;
            return Container(
              height: 132,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyLobbyQueueCard() {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Sois le premier à lancer une salle ⚡',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucune partie ouverte pour l'instant. "
            "Cree un lobby, invite tes coequipiers par code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _slateLight.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openCreateDialog,
            style: FilledButton.styleFrom(
              backgroundColor: _violet,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Créer un lobby'),
          ),
        ],
      ),
    );
  }

  Widget _error(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(msg, style: TextStyle(color: _slateLight)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => _retry++),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _LobbyModeCard extends StatelessWidget {
  const _LobbyModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _slateLight.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}

class _LobbyQueueBadges extends StatelessWidget {
  const _LobbyQueueBadges({
    required this.waitingCount,
    required this.liveCount,
  });

  final int waitingCount;
  final int liveCount;

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    if (waitingCount > 0) {
      parts.add(
        _BadgePill(
          label: '$waitingCount attente',
          fg: _green,
          bg: _green.withValues(alpha: 0.2),
        ),
      );
    }
    if (liveCount > 0) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 6));
      parts.add(
        _BadgePill(
          label: '$liveCount en jeu',
          fg: _orange,
          bg: _orange.withValues(alpha: 0.2),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: parts);
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LobbyCard extends StatelessWidget {
  const LobbyCard({
    super.key,
    required this.lobby,
    required this.index,
    required this.onTap,
    this.showJoinCta = false,
    this.onDelete,
    this.isAdminDelete = false,
  });

  final LobbyModel lobby;
  final int index;
  final VoidCallback onTap;
  final bool showJoinCta;
  /// Non-null si l'utilisateur peut supprimer ce lobby (owner ou admin).
  final Future<void> Function()? onDelete;
  /// true → suppression admin (orange), false → suppression owner (rouge).
  final bool isAdminDelete;

  (Color bg, Color fg, String label) _status() {
    switch (lobby.status) {
      case 'in_progress':
        return (
          _orange.withValues(alpha: 0.2),
          _orange,
          'En cours',
        );
      case 'finished':
        return (
          _slate.withValues(alpha: 0.2),
          _slate,
          'Terminé',
        );
      default:
        return (
          _green.withValues(alpha: 0.2),
          _green,
          'Ouvert',
        );
    }
  }

  (Color, Color) _diff() {
    final d = lobby.difficulty.toLowerCase();
    if (d == 'progressive') {
      return (_red.withValues(alpha: 0.2), const Color(0xFFFF6B6B));
    }
    if (d == 'mixte' || d.contains('+')) {
      return (_orange.withValues(alpha: 0.2), _orange);
    }
    switch (d) {
      case 'facile':
        return (_green.withValues(alpha: 0.2), _green);
      case 'difficile':
        return (Colors.red.withValues(alpha: 0.2), Colors.redAccent);
      default:
        return (_orange.withValues(alpha: 0.2), _orange);
    }
  }

  (Color bg, Color fg) _modeStyle() {
    if (lobby.isSurvival) {
      return (
        _red.withValues(alpha: 0.22),
        const Color(0xFFFF6B6B),
      );
    }
    return (
      _violet.withValues(alpha: 0.22),
      _violet,
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final dialogColor = isAdminDelete ? _orange : _red;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isAdminDelete ? 'Supprimer ce lobby (admin) ?' : 'Supprimer ce lobby ?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isAdminDelete
              ? 'Suppression en tant qu\'admin — action irréversible.'
              : 'Cette action est irréversible.',
          style: const TextStyle(color: _slateLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: dialogColor),
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
    final st = _status();
    final df = _diff();
    final ms = _modeStyle();
    final ratio = lobby.maxPlayers > 0
        ? lobby.currentPlayers / lobby.maxPlayers
        : 0.0;
    final modeEmoji = lobby.isSurvival ? '\u{1F6E1}' : '\u{1F3AF}';
    final accent = ms.$2;
    final progressColor = lobby.isSurvival ? const Color(0xFFFF6B6B) : _cyan;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: _violet.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(accent, Colors.white, 0.55)!
                  .withValues(alpha: lobby.isSurvival ? 0.42 : 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.45),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ms.$1,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      modeEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lobby.gameModeLabelShort,
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  lobby.hostAvatar,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            lobby.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (onDelete != null)
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isAdminDelete
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.delete_outline_rounded,
                                color: isAdminDelete
                                    ? _orange.withValues(alpha: 0.85)
                                    : _red.withValues(alpha: 0.75),
                                size: 18,
                              ),
                              tooltip: isAdminDelete
                                  ? 'Supprimer (admin)'
                                  : 'Supprimer le lobby',
                              onPressed: () => _confirmAndDelete(context),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hôte : ${lobby.hostName} · ${lobby.subject}',
                      style: TextStyle(
                        color: _slateLight.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0, 1),
                              minHeight: 4,
                              backgroundColor: _surface,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\u{1F465} ${lobby.currentPlayers}/${lobby.maxPlayers}',
                          style: TextStyle(
                            color: _slateLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: st.$1,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            st.$3,
                            style: TextStyle(
                              color: st.$2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: df.$1,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lobby.difficulty,
                            style: TextStyle(
                              color: df.$2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showJoinCta) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Rejoindre'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: (index * 80).ms)
        .slideX(begin: 0.04, duration: 280.ms, delay: (index * 80).ms);
  }
}
