import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/lobby_repository.dart';
import '../../data/models/custom_quiz_data.dart';
import '../../../notebook/data/note_ai_generator.dart';
import '../../../ai/data/ai_key_repository.dart';

class LobbyCreateAiCardBody extends ConsumerStatefulWidget {
  const LobbyCreateAiCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<LobbyCreateAiCardBody> createState() => _LobbyCreateAiCardBodyState();
}

class _LobbyCreateAiCardBodyState extends ConsumerState<LobbyCreateAiCardBody> {
  final List<String> _suggestions = const [
    'Modèle OSI & TCP/IP',
    'Sécurité Active Directory',
    'Linux Bash & Commandes',
    'Virtualisation & Hyperviseurs',
    'Adressage IP & CIDR',
    'Cybersécurité & Phishing',
    'Cloud Computing & AWS',
  ];

  late final TextEditingController _aiPromptController;
  bool _isPrivate = false;
  bool _correctionAtEnd = true;
  int _questionCount = 10;
  final Set<String> _selectedDifficulties = {'Facile', 'Moyen', 'Difficile'};
  final bool _isSurvival = false;
  bool _loading = false;
  String _loadingText = 'Initialisation...';

  // Dropdown visibility state
  bool _showCountDropdown = false;

  @override
  void initState() {
    super.initState();
    _aiPromptController = TextEditingController();
  }

  @override
  void dispose() {
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _createLobby() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un sujet ou un thème pour l\'IA')),
      );
      return;
    }

    if (_selectedDifficulties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez au moins une difficulté')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _loadingText = 'Vérification de la clé IA...';
    });

    try {
      final aiState = await AiKeyRepository().watch().first;
      if (!aiState.isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez connecter votre IA dans Profil > Paramètres IA.'),
              backgroundColor: EskoliaTokens.error,
            ),
          );
        }
        setState(() => _loading = false);
        return;
      }

      setState(() => _loadingText = 'L\'IA formule les questions...');
      final buffer = StringBuffer();
      final difficultyLabel = _selectedDifficulties.length >= 3
          ? 'mixte'
          : _selectedDifficulties.map((d) => d.toLowerCase()).join('+');

      await for (final token in NoteAiGenerator().streamQuizFromTheme(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        theme: prompt,
        questionCount: _questionCount,
        difficulty: difficultyLabel,
      )) {
        buffer.write(token);
      }

      setState(() => _loadingText = 'Analyse du quiz généré...');
      final raw = NoteAiGenerator.extractJson(buffer.toString());
      final data = CustomQuizData.fromJsonString(raw);

      // Convert generated questions to tipJson format
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
        if (e.value.items.isNotEmpty) 'answerSequence': e.value.items,
        if (e.value.items.isNotEmpty) 'options': e.value.items,
      }).toList();

      setState(() => _loadingText = 'Création du salon sur Firestore...');
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      String name = 'Hôte';
      if (uid != 'guest') {
        final userDoc = await UserRepository().getUserById(uid);
        if (userDoc != null && userDoc.username.isNotEmpty) {
          name = userDoc.username;
        }
      }

      final lobbyId = await LobbyRepository().createLobby(LobbyModel(
        id: '',
        title: '"${data.title}" par $name',
        subject: 'Quiz IA · ${data.questions.length} questions',
        hostName: name,
        hostAvatar: '🧠',
        currentPlayers: 1,
        maxPlayers: kLobbyMaxPlayers,
        status: 'waiting',
        difficulty: 'mixte',
        quizId: 'custom',
        createdAt: DateTime.now(),
        hostId: uid,
        questionAssetPaths: const [],
        customQuestionsJson: jsonEncode(qs),
        isPrivate: _isPrivate,
        correctionMode: _correctionAtEnd ? 'at_end' : 'after_each',
        gameMode: _isSurvival ? kLobbyGameModeSurvival : kLobbyGameModeQuiz,
        timed: false,
        questionCount: data.questions.length.clamp(kLobbyMinQuestionCount, kLobbyMaxQuestionCount),
        difficultyFilters: const ['facile', 'moyen', 'difficile'],
        playerMeta: [PlayerMeta(userId: uid, displayName: name, avatar: '🧠')],
      ));

      if (!mounted) return;
      context.push('/lobby/$lobbyId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération par l\'IA : $e'),
            backgroundColor: EskoliaTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
    Color activeColor = EskoliaTokens.amber,
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

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:lobbys_create_ai']?.isCollapsed ?? false);

    const goldColor = EskoliaTokens.amber;

    if (_loading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(goldColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _loadingText,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cela peut prendre entre 5 et 15 secondes...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sujet ou thème du Quiz IA :',
          style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _aiPromptController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ex: "Active Directory", "Modèle OSI"...',
            hintStyle: TextStyle(
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: goldColor),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Expanded fields
        if (!isCollapsed) ...[
          const SizedBox(height: 12),
          // Collapsible questions count selector
          _buildCollapsibleSelector(
            label: 'Nombre de questions',
            valueText: '$_questionCount questions',
            icon: Icons.format_list_numbered_rounded,
            color: goldColor,
            isOpen: _showCountDropdown,
            onTap: () => setState(() {
              _showCountDropdown = !_showCountDropdown;
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
                        activeColor: goldColor,
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
            color: goldColor,
            onTap: () => setState(() => _isPrivate = !_isPrivate),
          ),
          const SizedBox(height: 10),
          // Correction Block Toggle
          _buildBlockToggle(
            label: 'Correction',
            value: _correctionAtEnd ? 'À la fin du quiz' : 'Après chaque question',
            icon: _correctionAtEnd ? Icons.playlist_add_check_rounded : Icons.question_answer_rounded,
            color: goldColor,
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
                accentColor: goldColor,
              ),
              const SizedBox(width: 6),
              _buildDifficultyButton(
                label: 'Moyen',
                dotColor: const Color(0xFFFFA000),
                activeColor: const Color(0xFFFFA000),
                accentColor: goldColor,
              ),
              const SizedBox(width: 6),
              _buildDifficultyButton(
                label: 'Difficile',
                dotColor: const Color(0xFFFF1744),
                activeColor: const Color(0xFFFF1744),
                accentColor: goldColor,
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _loading ? null : _createLobby,
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
          label: const Text('Créer le salon IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
