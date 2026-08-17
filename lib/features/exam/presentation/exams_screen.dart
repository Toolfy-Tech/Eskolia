import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../admin/data/staff_capability.dart';
import '../../lobby/data/lobby_repository.dart';
import '../../quiz/services/quiz_template_service.dart';
import '../../tp/exam_tp/data/tp_exam_repository.dart';
import '../../tp/exam_tp/models/tp_exam_model.dart';
import '../../tp/exam_tp/presentation/widgets/tp_exam_card.dart';
import '../data/exam_model.dart';
import '../data/exam_repository.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final ExamRepository _examRepo = ExamRepository.instance;
  final TpExamRepository _tpRepo = TpExamRepository.instance;

  int _selectedTabIndex = 0; // 0 = Épreuves Théoriques (Quiz), 1 = Épreuves Pratiques (TP)
  List<ExamQuizItem> _exams = [];
  List<TpExamScenario> _tpScenarios = [];
  bool _loading = true;
  bool _isStaff = false;
  String? _loadingLobbyExamId;

  @override
  void initState() {
    super.initState();
    _checkStaff();
    _loadAll();
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

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final examsList = await _examRepo.loadAllExams();
      final tpList = await _tpRepo.loadAllScenarios();
      if (mounted) {
        setState(() {
          _exams = examsList;
          _tpScenarios = tpList;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startExam(ExamQuizItem exam) {
    final session = _examRepo.buildExamSession(exam);
    context.push('/quiz/run', extra: session);
  }

  Future<void> _startExamLobby(ExamQuizItem exam) async {
    setState(() => _loadingLobbyExamId = exam.id);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      String name = 'Hôte';
      if (uid != 'guest') {
        final userDoc = await UserRepository().getUserById(uid);
        if (userDoc != null && userDoc.username.isNotEmpty) {
          name = userDoc.username;
        }
      }

      final customQs = exam.questions.map((q) => {
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

      final lobbyId = await LobbyRepository().createLobby(LobbyModel(
        id: '',
        title: 'Examen : ${exam.title}',
        subject: 'Examen Blanc · ${exam.questionCount} questions',
        hostName: name,
        hostAvatar: '🎓',
        currentPlayers: 1,
        maxPlayers: kLobbyMaxPlayers,
        status: 'waiting',
        difficulty: 'Examen Blanc',
        quizId: 'custom',
        createdAt: DateTime.now(),
        hostId: uid,
        questionAssetPaths: const [],
        customQuestionsJson: jsonEncode(customQs),
        isPrivate: false,
        correctionMode: 'after_each', // Correction après chaque question
        timed: false,
        questionCount: exam.questionCount,
        difficultyFilters: const ['facile', 'moyen', 'difficile', 'unknown'],
        playerMeta: [
          PlayerMeta(userId: uid, displayName: name, avatar: '🎓'),
        ],
      ));

      if (mounted) {
        setState(() => _loadingLobbyExamId = null);
        context.push('/lobbys/$lobbyId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLobbyExamId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du salon : $e'),
            backgroundColor: EskoliaTokens.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFB300);

    return StreamBuilder<bool>(
      stream: _tpRepo.watchTpExamEnabled(),
      builder: (context, snapshot) {
        final isTpEnabled = snapshot.data ?? false;
        final showTpTab = isTpEnabled;

        // Si les TP sont désactivés, forcer l'onglet théorique
        if (!showTpTab && _selectedTabIndex != 0) {
          _selectedTabIndex = 0;
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: EskoliaAppBar.standard(
            context,
            title: 'Examens Blancs',
            actions: [
              if (_selectedTabIndex == 0)
                IconButton(
                  tooltip: 'Télécharger le modèle JSON',
                  icon: const Icon(Icons.file_download_outlined, color: goldColor),
                  onPressed: () => QuizTemplateService.downloadTemplate(context),
                ),
              IconButton(
                tooltip: 'Actualiser',
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                onPressed: _loadAll,
              ),
            ],
          ),
          body: Stack(
            children: [
              const EskoliaAmbientBackground(),
              EskoliaShellBody(
                safeAreaTop: false,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    16,
                    EskoliaLayout.screenPaddingH,
                    EskoliaLayout.screenPaddingBottom + 90,
                  ),
                  children: [
                    // Header Banner
                    _buildHeaderBanner(goldColor, isTpEnabled: isTpEnabled),
                    const SizedBox(height: 14),

                    // Carte Contrôle Formateur : Rendre visible / Masquer les TP VM (Réservé au formateur/admin)
                    if (_isStaff) ...[
                      _buildTeacherControlCard(isTpEnabled),
                      const SizedBox(height: 14),
                    ],

                    // Sélecteur d'onglets (affiché si TP activé ou si mode formateur/staff)
                    if (showTpTab) ...[
                      _buildTabSelector(goldColor, isTpEnabled: isTpEnabled),
                      const SizedBox(height: 16),
                    ],

                    // Contenu selon l'onglet actif
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(color: goldColor),
                        ),
                      )
                    else if (_selectedTabIndex == 0)
                      _buildTheoricalTabContent(goldColor)
                    else
                      _buildPracticalTabContent(goldColor, isTpEnabled: isTpEnabled),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeacherControlCard(bool isTpEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTpEnabled
            ? EskoliaTokens.cyan.withValues(alpha: 0.12)
            : Colors.amber.shade900.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTpEnabled
              ? EskoliaTokens.cyan.withValues(alpha: 0.55)
              : Colors.amberAccent.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTpEnabled
                  ? EskoliaTokens.cyan.withValues(alpha: 0.2)
                  : Colors.amber.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTpEnabled ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: isTpEnabled ? EskoliaTokens.cyan : Colors.amberAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Épreuves Pratiques TP VM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTpEnabled
                            ? Colors.green.shade900.withValues(alpha: 0.6)
                            : Colors.amber.shade900.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isTpEnabled ? Colors.greenAccent : Colors.amberAccent,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isTpEnabled ? '🟢 VISIBLE' : '🔒 MASQUÉ',
                        style: TextStyle(
                          color: isTpEnabled ? Colors.greenAccent : Colors.amberAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isTpEnabled
                      ? 'Les 4 TP VM sont débloqués et accessibles à toute la classe.'
                      : 'Les 4 TP VM sont masqués. Activez pour ouvrir la session pratique.',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isTpEnabled,
            activeColor: EskoliaTokens.cyan,
            onChanged: (val) async {
              await _tpRepo.setTpExamEnabled(val);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      val
                          ? '✅ Épreuves pratiques TP VM activées et visibles pour les élèves !'
                          : '🔒 Épreuves pratiques TP VM masquées aux élèves.',
                    ),
                    backgroundColor: val ? Colors.green.shade800 : Colors.grey.shade900,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(Color goldColor, {required bool isTpEnabled}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              0,
              '📝 Épreuves Théoriques (${_exams.length})',
              goldColor,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              1,
              '🛠️ Épreuves Pratiques TP (${_tpScenarios.length})',
              goldColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, Color goldColor) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? goldColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: goldColor.withValues(alpha: 0.6)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : EskoliaTokens.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTheoricalTabContent(Color goldColor) {
    if (_exams.isEmpty) {
      return _buildEmptyState(goldColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTheoreticalStatsRow(goldColor),
        const SizedBox(height: 16),
        Text(
          '8 Épreuves Transversales REAC TIP (Niveau 4)',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._exams.map((exam) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildExamCard(exam, goldColor),
            )),
      ],
    );
  }

  Widget _buildPracticalTabContent(Color goldColor, {required bool isTpEnabled}) {
    if (!isTpEnabled && !_isStaff) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: EskoliaTokens.surface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_rounded, size: 48, color: Colors.amberAccent),
            const SizedBox(height: 12),
            Text(
              'Épreuves Pratiques TP Verrouillées',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette session d\'examen pratique sera ouverte par votre formateur au moment prévu. Revenez dès que le professeur aura lancé l\'épreuve !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EskoliaTokens.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (_tpScenarios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: EskoliaTokens.surface1,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'Aucun TP pratique disponible.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isTpEnabled && _isStaff) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: Colors.amberAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mode Formateur : les épreuves TP sont actuellement masquées aux élèves. Vous pouvez les activer en 1 clic dans le panneau Modération.',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/admin'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amberAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Panneau Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
        _buildPracticalStatsRow(goldColor),
        const SizedBox(height: 16),
        Text(
          '4 Mises en Situation Pratiques sur Machine Virtuelle Windows 11',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._tpScenarios.map((scenario) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TpExamCard(
                scenario: scenario,
                onRefresh: _loadAll,
              ),
            )),
      ],
    );
  }

  Widget _buildHeaderBanner(Color accent, {required bool isTpEnabled}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: const Text('🎓', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examens Blancs & Révisions',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTpEnabled
                      ? 'Préparez votre Titre Professionnel TIP avec 8 épreuves théoriques et 4 TP d\'examen complets sur machine virtuelle.'
                      : 'Préparez votre Titre Professionnel TIP avec 8 épreuves théoriques transversales conformes au REAC.',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: EskoliaTokens.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoreticalStatsRow(Color accent) {
    final completedCount = _exams.where((e) => e.isCompleted).length;
    final totalCount = _exams.length;
    final scores = _exams.map((e) => e.bestScore).whereType<double>().toList();
    final avgScore = scores.isNotEmpty ? (scores.reduce((a, b) => a + b) / scores.length).round() : null;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Quiz complétés', '$completedCount / $totalCount', accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem('Moyenne théorique', avgScore != null ? '$avgScore%' : '—', accent),
        ),
      ],
    );
  }

  Widget _buildPracticalStatsRow(Color accent) {
    final completedCount = _tpScenarios.where((s) => s.isCompleted).length;
    final totalCount = _tpScenarios.length;
    final scores = _tpScenarios.map((s) => s.userScore).whereType<double>().toList();
    final avgScore = scores.isNotEmpty ? (scores.reduce((a, b) => a + b) / scores.length) : null;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem('TP terminés', '$completedCount / $totalCount', accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            'Moyenne pratique sur 20',
            avgScore != null ? '${avgScore.toStringAsFixed(1)} / 20' : '—',
            accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface2.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: EskoliaTokens.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamQuizItem exam, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: exam.isCompleted
              ? EskoliaTokens.success.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFFFFB300), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exam.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (exam.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: EskoliaTokens.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              exam.bestScore != null ? '${exam.bestScore!.round()}%' : 'Terminé',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: EskoliaTokens.success,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exam.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EskoliaTokens.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildMetaChip(Icons.help_outline_rounded, '${exam.questionCount} questions'),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton pour lancer directement un salon multijoueur avec correction entre chaque question
                  OutlinedButton.icon(
                    onPressed: _loadingLobbyExamId == exam.id ? null : () => _startExamLobby(exam),
                    icon: _loadingLobbyExamId == exam.id
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: EskoliaTokens.cyan),
                          )
                        : const Icon(Icons.groups_rounded, size: 15, color: EskoliaTokens.cyan),
                    label: const Text(
                      'Créer un Salon (Correction live)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: EskoliaTokens.cyan),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: EskoliaTokens.cyan.withValues(alpha: 0.10),
                      side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bouton Solo Démarrer
                  ElevatedButton.icon(
                    onPressed: () => _startExam(exam),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.black),
                    label: Text(
                      exam.isCompleted ? 'Rejouer en solo' : 'Démarrer en solo',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: EskoliaTokens.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: EskoliaTokens.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Text('📁', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 14),
          Text(
            'En attente des 8 quiz d\'examen',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Déposez vos fichiers JSON d\'examen dans le dossier :\n'
            'data/exam/\n\n'
            'Ils apparaîtront automatiquement ici dès leur ajout !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: EskoliaTokens.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => QuizTemplateService.downloadTemplate(context),
                icon: const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFFFFB300)),
                label: const Text('Modèle .json', style: TextStyle(color: Color(0xFFFFB300), fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _loadAll,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.black),
                label: const Text('Actualiser', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
