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
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../../../admin/data/staff_capability.dart';
import '../data/tp_exam_repository.dart';
import '../models/tp_exam_model.dart';
import 'providers/tp_exam_providers.dart';

class TpExamSessionScreen extends ConsumerStatefulWidget {
  const TpExamSessionScreen({super.key, required this.examId});
  final String examId;

  @override
  ConsumerState<TpExamSessionScreen> createState() => _TpExamSessionScreenState();
}

class _TpExamSessionScreenState extends ConsumerState<TpExamSessionScreen> {
  final Set<String> _checkedTasks = {};
  bool _isCompleted = false;
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
          title: 'Épreuve Pratique TIP',
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
                        'Épreuve Pratique Verrouillée',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cette épreuve pratique sur machine virtuelle sera ouverte par votre formateur. Revenez dès que le professeur aura lancé la session !',
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
        title: 'Épreuve Pratique TIP',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          asyncScenario.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Erreur de chargement de l\'épreuve : $err',
                style: const TextStyle(color: EskoliaTokens.error),
              ),
            ),
            data: (scenario) {
              if (scenario == null) {
                return const Center(
                  child: Text('Épreuve introuvable.', style: TextStyle(color: Colors.white70)),
                );
              }

              // Initialisation locale des tâches cochées
              if (_checkedTasks.isEmpty && scenario.checkedTaskIds.isNotEmpty) {
                _checkedTasks.addAll(scenario.checkedTaskIds);
              }
              _isCompleted = scenario.isCompleted;

              final hPad = EskoliaLayout.lessonHorizontalPadding(context);
              final maxW = EskoliaLayout.lessonContentMaxWidth(context);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  MediaQuery.paddingOf(context).top + 60,
                  hPad,
                  EskoliaLayout.screenPaddingBottom + 80,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // En-tête Épreuve
                        _buildHeader(scenario, goldColor),
                        const SizedBox(height: 16),

                        // Panneau Identifiants & Prérequis VM
                        _buildVmCredentialsPanel(scenario.vmInfo, goldColor),
                        const SizedBox(height: 16),

                        // Contexte & Handicap
                        _buildContextPanel(scenario),
                        const SizedBox(height: 24),

                        // PARTIE 1 : Checklist des 14 tâches
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'PARTIE 1',
                                style: GoogleFonts.outfit(
                                  color: goldColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Configuration, Administration & Recette VM (${_checkedTasks.length}/${scenario.tasks.length})',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        ...scenario.tasks.map((task) => _buildTaskChecklistCard(task, goldColor)),
                        const SizedBox(height: 24),

                        // PARTIE 2 : Livrable Tutoriel
                        _buildTutorialGuideBanner(scenario.tutorialGuide, goldColor),
                        const SizedBox(height: 24),

                        // Bannière de verrouillage / Déblocage de la correction
                        _buildCorrectionLockBanner(scenario, goldColor),
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

  Widget _buildHeader(TpExamScenario scenario, Color goldColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: goldColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'EXAMEN BLANC PRATIQUE (NIVEAU 4)',
                  style: GoogleFonts.outfit(
                    color: goldColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              if (_isCompleted)
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
                        'Corrigé Débloqué',
                        style: GoogleFonts.outfit(
                          color: EskoliaTokens.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scenario.title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scenario.subtitle,
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVmCredentialsPanel(TpExamVmInfo vm, Color goldColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dvr_rounded, color: EskoliaTokens.cyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'Accès Machine Virtuelle (Windows 11 English)',
                style: GoogleFonts.outfit(
                  color: EskoliaTokens.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildCopyCredentialChip('VM Cible', vm.vmName),
              _buildCopyCredentialChip('Nom Poste Final', vm.targetHostname),
              _buildCopyCredentialChip('Admin User', vm.adminUser),
              _buildCopyCredentialChip('Admin MDP', vm.adminPassword),
              _buildCopyCredentialChip('Clé TPM BitLocker', vm.tpmKey),
              _buildCopyCredentialChip('Compte Utilisateur', '${vm.userAccount.username} (${vm.userAccount.password})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyCredentialChip(String label, String value) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('« $value » copié dans le presse-papier !'),
            duration: const Duration(seconds: 2),
            backgroundColor: EskoliaTokens.surface2,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: EskoliaTokens.surface2.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.copy_rounded, color: EskoliaTokens.cyan, size: 13),
          ],
        ),
      ),
    );
  }

  Widget _buildContextPanel(TpExamScenario scenario) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'Contexte Métier : ${scenario.candidateName} — ${scenario.companyName} (${scenario.role})',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            scenario.accessibilityContext,
            style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskChecklistCard(TpExamTask task, Color goldColor) {
    final isChecked = _checkedTasks.contains(task.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isChecked ? EskoliaTokens.surface2.withValues(alpha: 0.4) : EskoliaTokens.surface1.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChecked ? EskoliaTokens.success.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          setState(() {
            if (isChecked) {
              _checkedTasks.remove(task.id);
            } else {
              _checkedTasks.add(task.id);
            }
          });
          await TpExamRepository.instance.toggleTaskChecked(widget.examId, task.id, !isChecked);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                activeColor: EskoliaTokens.success,
                checkColor: Colors.black,
                onChanged: (val) async {
                  final checked = val ?? false;
                  setState(() {
                    if (checked) {
                      _checkedTasks.add(task.id);
                    } else {
                      _checkedTasks.remove(task.id);
                    }
                  });
                  await TpExamRepository.instance.toggleTaskChecked(widget.examId, task.id, checked);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tâche ${task.order} : ${task.title}',
                          style: GoogleFonts.outfit(
                            color: isChecked ? Colors.white70 : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${task.points.toStringAsFixed(0)} pt',
                            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.instruction,
                      style: TextStyle(
                        color: isChecked ? Colors.white54 : EskoliaTokens.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 12, color: EskoliaTokens.cyan),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Preuve Recette : ${task.captureExpected}',
                            style: const TextStyle(
                              color: EskoliaTokens.cyan,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
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
      ),
    );
  }

  Widget _buildTutorialGuideBanner(TpExamTutorialGuide guide, Color goldColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EskoliaTokens.violetSoft.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EskoliaTokens.violetSoft.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: EskoliaTokens.violetSoft.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PARTIE 2',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD8B4FE),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rédaction du Livrable : ${guide.documentName} (max ${guide.maxPages} pages)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Consignes de formalisation : ${guide.formalRequirements.join(' • ')}',
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          ...guide.modules.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📄', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Module ${m.moduleNumber} : ${m.title} — ${m.description}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCorrectionLockBanner(TpExamScenario scenario, Color goldColor) {
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: EskoliaTokens.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.lock_open_rounded, color: EskoliaTokens.success, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Épreuve Finalisée — Corrigé Débloqué !',
                        style: GoogleFonts.outfit(
                          color: EskoliaTokens.success,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vous pouvez consulter toutes les étapes GUI, les scripts PowerShell et vous auto-évaluer sur 20.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/exams/tp/${scenario.id}/correction');
                },
                icon: const Icon(Icons.school_rounded, color: Colors.black, size: 18),
                label: Text(
                  'Consulter le Corrigé & S\'auto-évaluer',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.success,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded, color: EskoliaTokens.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corrigé & Guide de Révision Verrouillés',
                      style: GoogleFonts.outfit(
                        color: EskoliaTokens.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Réalisez vos configurations sur votre machine virtuelle. Une fois vos travaux terminés, cliquez ci-dessous pour débloquer la correction détaillée.',
                      style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmFinishExam(scenario),
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 18),
              label: Text(
                'Terminer l\'épreuve & Débloquer la correction',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFinishExam(TpExamScenario scenario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Terminer l\'épreuve pratique ?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Vous avez coché ${_checkedTasks.length} sur ${scenario.tasks.length} tâches.\n\nEn confirmant, vous allez débloquer le corrigé complet (GUI Windows 11 US, scripts PowerShell et modèle de tutoriel) ainsi que la grille d\'auto-évaluation sur 20.',
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer sur VM', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.black,
            ),
            child: const Text('Valider & Voir le Corrigé', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await TpExamRepository.instance.completeExam(widget.examId);
      ref.invalidate(tpExamScenarioProvider(widget.examId));
      ref.invalidate(tpExamListProvider);
      if (mounted) {
        context.pushReplacement('/exams/tp/${widget.examId}/correction');
      }
    }
  }
}
