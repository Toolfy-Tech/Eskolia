import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/theme/eskolia_layout.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../../../admin/data/staff_capability.dart';
import '../data/tp_exam_repository.dart';
import '../models/tp_exam_model.dart';
import 'providers/tp_exam_providers.dart';

class TpExamCorrectionScreen extends ConsumerStatefulWidget {
  const TpExamCorrectionScreen({super.key, required this.examId});
  final String examId;

  @override
  ConsumerState<TpExamCorrectionScreen> createState() => _TpExamCorrectionScreenState();
}

class _TpExamCorrectionScreenState extends ConsumerState<TpExamCorrectionScreen> {
  final Map<String, double> _taskScores = {};
  final Map<String, double> _rubricScores = {};
  bool _initializedScores = false;
  int _activeTab = 0; // 0 = Corrigé Détaillé, 1 = Auto-Évaluation sur 20, 2 = Modèle Tutoriel
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _checkStaff();
  }

  Future<void> _checkStaff() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final user = await UserRepository().getUserById(uid);
      if (mounted) {
        setState(() {
          _isStaff = userHasStaffAccess(user, auth.currentUser?.email);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFB300);
    final asyncEnabled = ref.watch(tpExamEnabledStreamProvider);
    final isEnabled = asyncEnabled.value ?? false;

    if (!isEnabled && !_isStaff) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(
          context,
          title: 'Corrigé & Auto-Évaluation',
        ),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: EskoliaTokens.surface1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_clock_rounded, size: 56, color: Colors.amberAccent),
                      const SizedBox(height: 16),
                      Text(
                        'Correction Non Disponible',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Les épreuves pratiques et leurs corrigés sont actuellement verrouillés par votre formateur. Revenez dès que la session aura été ouverte !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/exams'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Retour aux examens blancs'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final asyncScenario = ref.watch(tpExamScenarioProvider(widget.examId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Corrigé & Auto-Évaluation',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          asyncScenario.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Erreur : $err',
                style: const TextStyle(color: EskoliaTokens.error),
              ),
            ),
            data: (scenario) {
              if (scenario == null) {
                return const Center(child: Text('Épreuve introuvable.', style: TextStyle(color: Colors.white70)));
              }

              // Initialisation des notes par défaut
              if (!_initializedScores) {
                for (final t in scenario.tasks) {
                  final wasChecked = scenario.checkedTaskIds.contains(t.id);
                  _taskScores[t.id] = wasChecked ? t.points : 0.0;
                }
                for (final r in scenario.tutorialGuide.evaluationRubric) {
                  _rubricScores[r.criterion] = r.maxPoints * 0.8; // Note par défaut convenable
                }
                _initializedScores = true;
              }

              final totalScoreOn20 = _calculateTotalScore();
              final hPad = EskoliaLayout.lessonHorizontalPadding(context);
              final maxW = EskoliaLayout.lessonContentMaxWidth(context);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  MediaQuery.paddingOf(context).top + 60,
                  hPad,
                  EskoliaLayout.screenPaddingBottom + 60,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // En-tête Corrigé
                        _buildCorrectionHeader(scenario, totalScoreOn20, goldColor),
                        const SizedBox(height: 16),

                        // Sélecteur d'onglets
                        _buildSegmentedTabSelector(goldColor),
                        const SizedBox(height: 16),

                        if (_activeTab == 0) ...[
                          // ONGLET 1 : Corrigé Pas-à-Pas (GUI Windows 11 US & PowerShell)
                          _buildTasksCorrectionList(scenario.tasks, goldColor),
                        ] else if (_activeTab == 1) ...[
                          // ONGLET 2 : Grille d'Auto-Évaluation
                          _buildSelfEvaluationView(scenario, totalScoreOn20, goldColor),
                        ] else ...[
                          // ONGLET 3 : Modèle du Tutoriel Livrable
                          _buildTutorialSolutionView(scenario.tutorialGuide, goldColor),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _calculateTotalScore() {
    double sumTasks = _taskScores.values.fold(0.0, (sum, v) => sum + v);
    double sumRubric = _rubricScores.values.fold(0.0, (sum, v) => sum + v);
    return (sumTasks + sumRubric).clamp(0.0, 20.0);
  }

  Widget _buildCorrectionHeader(TpExamScenario scenario, double totalScore, Color goldColor) {
    final isValidated = totalScore >= 10.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: EskoliaTokens.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: EskoliaTokens.success, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'CORRIGÉ OFFICIEL DÉBLOQUÉ',
                      style: GoogleFonts.outfit(
                        color: EskoliaTokens.success,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isValidated ? EskoliaTokens.success.withValues(alpha: 0.2) : EskoliaTokens.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isValidated ? EskoliaTokens.success : EskoliaTokens.orange),
                ),
                child: Text(
                  '${totalScore.toStringAsFixed(1)} / 20',
                  style: GoogleFonts.outfit(
                    color: isValidated ? EskoliaTokens.success : EskoliaTokens.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scenario.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consultez les manipulations exactes Windows 11 US, les scripts PowerShell et notez votre travail.',
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector(Color goldColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(0, '🛠️ Résolutions (GUI/PS)', goldColor),
          ),
          Expanded(
            child: _buildTabItem(1, '📝 Note sur 20', goldColor),
          ),
          Expanded(
            child: _buildTabItem(2, '📄 Modèle Tutoriel', goldColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color goldColor) {
    final isSelected = _activeTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? goldColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: goldColor.withValues(alpha: 0.6)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : EskoliaTokens.textSecondary,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTasksCorrectionList(List<TpExamTask> tasks, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: tasks.map((task) => _buildTaskCorrectionCard(task, goldColor)).toList(),
    );
  }

  Widget _buildTaskCorrectionCard(TpExamTask task, Color goldColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre Tâche
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tâche ${task.order}',
                      style: GoogleFonts.outfit(color: goldColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${task.points.toStringAsFixed(0)} pt',
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Consigne
                  Text(
                    task.instruction,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 14),

                  // Résolution GUI Windows 11 US
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mouse_rounded, size: 14, color: EskoliaTokens.cyan),
                            const SizedBox(width: 6),
                            Text(
                              'Étapes Interface Graphique (Windows 11 English)',
                              style: GoogleFonts.outfit(
                                color: EskoliaTokens.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.guiSteps,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Script PowerShell
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.terminal_rounded, size: 14, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 6),
                            Text(
                              'Commande / Script PowerShell',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF38BDF8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.white54),
                              tooltip: 'Copier le script',
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: task.powerShellScript));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Script PowerShell copié !'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: EskoliaTokens.surface2,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          task.powerShellScript,
                          style: const TextStyle(
                            color: Color(0xFFBAE6FD),
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Preuve capture attendue
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.camera_alt_rounded, size: 14, color: EskoliaTokens.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, height: 1.35),
                            children: [
                              const TextSpan(
                                text: 'Capture de recette attendue : ',
                                style: TextStyle(color: EskoliaTokens.orange, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: task.captureExpected,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSelfEvaluationView(TpExamScenario scenario, double totalScore, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Carte Récapitulative Score
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: EskoliaTokens.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                'Note Globale Auto-Évaluée',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${totalScore.toStringAsFixed(1)} / 20',
                style: GoogleFonts.outfit(
                  color: totalScore >= 10 ? EskoliaTokens.success : EskoliaTokens.orange,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                totalScore >= 10
                    ? '🎉 Félicitations ! Votre niveau valide les exigences de l\'épreuve pratique TIP.'
                    : '⚠️ Score inférieur à la moyenne. Consultez les étapes GUI et PowerShell pour consolider vos acquis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: totalScore >= 10 ? EskoliaTokens.success : EskoliaTokens.orange,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () async {
                  await TpExamRepository.instance.saveEvaluationScore(widget.examId, totalScore);
                  ref.invalidate(tpExamScenarioProvider(widget.examId));
                  ref.invalidate(tpExamListProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Note de ${totalScore.toStringAsFixed(1)}/20 enregistrée avec succès !'),
                        backgroundColor: EskoliaTokens.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_rounded, size: 16, color: Colors.black),
                label: const Text('Enregistrer ma note finale', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section 1 : Barème des 14 tâches (14 pts)
        Text(
          'Partie 1 : Évaluation des Tâches Techniques (14 points)',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...scenario.tasks.map((task) {
          final current = _taskScores[task.id] ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: EskoliaTokens.surface1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tâche ${task.order} : ${task.title}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Barème officiel : ${task.points.toStringAsFixed(0)} pt',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 0.0, label: Text('0')),
                    ButtonSegment(value: 0.5, label: Text('0.5')),
                    ButtonSegment(value: 1.0, label: Text('1.0')),
                  ],
                  selected: {current},
                  onSelectionChanged: (val) {
                    setState(() => _taskScores[task.id] = val.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // Section 2 : Barème du Tutoriel (6 pts)
        Text(
          'Partie 2 : Évaluation du Tutoriel Utilisateur (6 points)',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...scenario.tutorialGuide.evaluationRubric.map((rubric) {
          final current = _rubricScores[rubric.criterion] ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: EskoliaTokens.surface1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rubric.criterion,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${current.toStringAsFixed(1)} / ${rubric.maxPoints.toStringAsFixed(1)} pt',
                      style: const TextStyle(color: EskoliaTokens.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rubric.details, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Slider(
                  value: current.clamp(0.0, rubric.maxPoints),
                  min: 0.0,
                  max: rubric.maxPoints,
                  divisions: (rubric.maxPoints * 2).toInt(),
                  activeColor: EskoliaTokens.cyan,
                  onChanged: (val) {
                    setState(() => _rubricScores[rubric.criterion] = val);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTutorialSolutionView(TpExamTutorialGuide guide, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: EskoliaTokens.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📑', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Modèle Type : ${guide.documentName}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Public cible : ${guide.targetAudience} • Volume max : ${guide.maxPages} pages',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              const Text(
                'Structure Recommandée pour le Document :',
                style: TextStyle(color: EskoliaTokens.cyan, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...guide.formalRequirements.map((req) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_rounded, size: 14, color: EskoliaTokens.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(req, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...guide.modules.map((mod) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EskoliaTokens.surface1.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: EskoliaTokens.violetSoft.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module ${mod.moduleNumber} : ${mod.title}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD8B4FE),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mod.description,
                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ...mod.steps.map((step) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Étape ${step.stepNumber} : ${step.stepTitle}',
                              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.instruction,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            )),
      ],
    );
  }
}
