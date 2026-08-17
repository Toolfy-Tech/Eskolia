import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../notebook/data/note_ai_generator.dart';
import '../../../notebook/data/notebook_repository.dart';
import '../../../notebook/data/note_model.dart';
import '../../../ai/data/ai_key_repository.dart';
import '../../../ai/data/ai_provider.dart';
import '../../../ai/data/ai_quiz_generator_service.dart';
import '../../../quiz/services/quiz_repository.dart';
import '../../../../core/widgets/bottom_nav.dart';

class SoloQuizAiCardBody extends ConsumerStatefulWidget {
  const SoloQuizAiCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<SoloQuizAiCardBody> createState() => _SoloQuizAiCardBodyState();
}

class _SoloQuizAiCardBodyState extends ConsumerState<SoloQuizAiCardBody> {
  late final TextEditingController _aiPromptController;
  int _questionCount = 10;
  final Set<String> _selectedDifficulties = {'Facile', 'Moyen', 'Difficile'};
  bool _loading = false;
  String _loadingText = 'Initialisation...';

  List<NoteModel> _notes = [];
  NoteModel? _selectedNote;
  String _sourceType = 'theme'; // 'theme' ou 'note'

  bool _showSourceDropdown = false;
  bool _showNotesDropdown = false;
  bool _showCountDropdown = false;

  @override
  void initState() {
    super.initState();
    _aiPromptController = TextEditingController();
    _loadNotes();
  }

  @override
  void dispose() {
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final list = await NotebookRepository().loadAll();
      if (mounted) {
        setState(() {
          _notes = list;
          if (_notes.isNotEmpty) {
            _selectedNote = _notes.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading notes for AI card: $e');
    }
  }

  Future<void> _generateQuiz() async {
    final prompt = _aiPromptController.text.trim();
    if (_sourceType == 'theme' && prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un sujet ou un thème pour l\'IA')),
      );
      return;
    }
    if (_sourceType == 'note' && _selectedNote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une note de votre carnet')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _loadingText = 'Vérification de la connexion IA...';
    });

    try {
      final aiState = await AiKeyRepository().load();
      if (!aiState.isConnected || (aiState.apiKey == null && !aiState.provider.isLocal)) {
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

      final geminiModel = await AiKeyRepository().loadGeminiModel();

      setState(() => _loadingText = 'L\'IA formule vos questions...');
      
      final String difficultyLabel;
      if (_selectedDifficulties.length == 3 || _selectedDifficulties.isEmpty) {
        difficultyLabel = 'mixte';
      } else {
        difficultyLabel = _selectedDifficulties.map((d) => d.toLowerCase()).join(' et ');
      }

      final title = _sourceType == 'note' ? _selectedNote!.title : prompt;
      final noteText = _sourceType == 'note' ? _selectedNote!.content : null;

      final session = await AiQuizGeneratorService().generateQuizSession(
        apiKey: aiState.apiKey ?? '',
        provider: aiState.provider,
        topic: title,
        count: _questionCount,
        difficulty: difficultyLabel,
        noteContent: noteText,
        geminiModel: aiState.provider == AiProvider.gemini ? geminiModel : null,
      );

      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur IA : $e'),
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
    Color activeColor = EskoliaTokens.violet,
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

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:solo_quiz_ai']?.isCollapsed ?? false);

    final aiState = ref.watch(aiConnectionStateProvider);
    final isAiActive = aiState.value?.isConnected ?? false;

    const violetColor = EskoliaTokens.violet;

    if (!isAiActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EskoliaTokens.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EskoliaTokens.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: EskoliaTokens.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assistant IA déconnecté',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pour générer des quiz personnalisés avec l\'IA, vous devez configurer une clé API.',
                        style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.85), fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/ai/setup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EskoliaTokens.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text('Configurer l\'Assistant IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }

    if (_loading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(violetColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _loadingText,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'L\'IA génère vos questions sur-mesure...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    final sourceText = _sourceType == 'theme' ? 'Thème / Sujet libre' : 'Depuis mes notes';
    final selectedNoteText = _selectedNote == null ? 'Aucune note' : _selectedNote!.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Source selection dropdown
        _buildCollapsibleSelector(
          label: 'Source de génération',
          valueText: sourceText,
          icon: Icons.source_rounded,
          color: violetColor,
          isOpen: _showSourceDropdown,
          onTap: () => setState(() {
            _showSourceDropdown = !_showSourceDropdown;
            _showNotesDropdown = false;
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
                _buildDropdownItemRow(
                  title: 'Thème / Sujet libre',
                  isSelected: _sourceType == 'theme',
                  onTap: () => setState(() {
                    _sourceType = 'theme';
                    _showSourceDropdown = false;
                  }),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildDropdownItemRow(
                  title: 'Depuis mes notes',
                  isSelected: _sourceType == 'note',
                  onTap: () => setState(() {
                    _sourceType = 'note';
                    _showSourceDropdown = false;
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Prompt input (if theme selected)
        if (_sourceType == 'theme') ...[
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
                borderSide: const BorderSide(color: violetColor),
              ),
            ),
          ),
        ],

        // Notes selection list (if note selected)
        if (_sourceType == 'note') ...[
          _buildCollapsibleSelector(
            label: 'Notes de cours sélectionnée',
            valueText: selectedNoteText,
            icon: Icons.note_alt_rounded,
            color: violetColor,
            isOpen: _showNotesDropdown,
            onTap: () => setState(() {
              _showNotesDropdown = !_showNotesDropdown;
              _showSourceDropdown = false;
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
                  children: _notes.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Aucune note trouvée dans votre carnet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
                            ),
                          ),
                        ]
                      : _notes.map((n) {
                          return _buildDropdownItemRow(
                            title: n.title,
                            isSelected: _selectedNote?.id == n.id,
                            onTap: () => setState(() {
                              _selectedNote = n;
                              _showNotesDropdown = false;
                            }),
                          );
                        }).toList(),
                ),
              ),
            ),
          ),
        ],

        if (!isCollapsed) ...[
          const SizedBox(height: 12),
          // Collapsible questions count selector
          _buildCollapsibleSelector(
            label: 'Nombre de questions',
            valueText: '$_questionCount questions',
            icon: Icons.format_list_numbered_rounded,
            color: violetColor,
            isOpen: _showCountDropdown,
            onTap: () => setState(() {
              _showCountDropdown = !_showCountDropdown;
              _showSourceDropdown = false;
              _showNotesDropdown = false;
            }),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [5, 10, 15, 20, 25].map((n) {
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
                      if (n != 25) const Divider(color: Colors.white10, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

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

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _loading ? null : _generateQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: violetColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.auto_awesome_rounded, size: 14),
          label: const Text('Lancer la génération IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
