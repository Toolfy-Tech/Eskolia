import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/eskolia_folder_service.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../economy/data/daily_quest_reward_service.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/parcours_section_badge_rewards.dart';
import '../../parcours/data/tip_progress_repository.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_course_link.dart';
import '../services/quiz_repository.dart';
import '../services/revision_pool_repository.dart';
import '../presentation/quiz_lesson_preview_dialog.dart';
import '../presentation/quiz_question_report_dialog.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF4CAF50);
const Color _red = Color(0xFFF44336);
const Color _cyan = Color(0xFF00BCD4);
const Color _orange = Color(0xFFFF9800);

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.sessionId,
    required this.score,
    required this.total,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.questions,
    required this.userScores, 
    required this.sessionTitle,
    this.survivalRun = false,
    this.survivalEliminated = false,
    this.survivalCatalogTrack,
    this.exitDestination = QuizResultExitDestination.parcours,
  });

  final String sessionId;
  final double score; 
  final int total;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final List<QuizQuestion> questions;
  final List<double?> userScores; 
  final String sessionTitle;
  final bool survivalRun;
  final bool survivalEliminated;
  final QuizCatalogTrack? survivalCatalogTrack;
  final QuizResultExitDestination exitDestination;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entrance;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOut),
    );
    _entrance.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveOnce());
  }

  Future<void> _saveOnce() async {
    if (_saved) return;
    _saved = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      String? moduleMarkedPassed;
      if (uid != null) {
        // QuizRepository dispose maintenant de la méthode saveResult
        await QuizRepository().saveResult(
          uid,
          widget.sessionId,
          widget.score,
          widget.total,
        );
        
        await DailyQuestRewardService().onQuizCompleted(uid);
        await AchievementTriggers(
          onUnlocked: (emoji, title) {
            if (mounted) showAchievementSnackBar(context, emoji, title);
          },
        ).onQuizSessionCompleted(
          uid,
          score: widget.score,
          total: widget.total,
          sessionId: widget.sessionId,
          survivalRun: widget.survivalRun,
          survivalEliminated: widget.survivalEliminated,
        );
      }
      await _autoPoolWrongAnswers();
      
      final pct = widget.total <= 0 ? 0.0 : widget.score / widget.total;
      
      final mod = ParcoursRepository.moduleById(widget.sessionId);
      if (mod != null) {
        final threshold = mod.type == 'exam'
            ? OptimusProgressRepository.sectionFinalExamPassRatio
            : OptimusProgressRepository.passScoreRatio;
        if (pct >= threshold) {
          await OptimusProgressRepository().markModulePassed(widget.sessionId);
          moduleMarkedPassed = widget.sessionId;
        }
      }

      final passedId = moduleMarkedPassed;
      if (uid != null && passedId != null) {
        await ParcoursSectionBadgeRewards().tryAwardSectionBadge(uid, passedId);
      }
    } catch (_) {}
  }

  Future<void> _autoPoolWrongAnswers() async {
    final qs = widget.questions;
    final scores = widget.userScores;
    final repo = RevisionPoolRepository();
    for (var i = 0; i < qs.length && i < scores.length; i++) {
      if ((scores[i] ?? 0.0) < 0.5) { 
        await repo.add(qs[i]);
      }
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  (String emoji, String title) _headline() {
    if (widget.survivalRun && widget.survivalEliminated) {
      return ('\u{1F480}', 'Game over');
    }
    final pct = widget.total <= 0 ? 0.0 : widget.score / widget.total;
    if (pct >= 0.9) return ('\u{1F3C6}', 'Expertise Totale !');
    if (pct >= 0.7) return ('\u{1F31F}', 'Excellent !');
    if (pct >= 0.5) return ('\u{1F4AA}', 'Maîtrise en cours');
    return ('\u{1F4DA}', 'Besoin de révision');
  }

  @override
  Widget build(BuildContext context) {
    final h = _headline();
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    final String displayScore = widget.score.toStringAsFixed(widget.score.truncateToDouble() == widget.score ? 0 : 2);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                const SizedBox(height: 16),
                                Text(h.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48)),
                                const SizedBox(height: 8),
                                Text(h.$2, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 24),
                                Center(
                                  child: Container(
                                    width: 160, height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle, 
                                      color: Colors.white.withValues(alpha: 0.05),
                                      border: Border.all(color: _violet.withValues(alpha: 0.3), width: 4)
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(displayScore, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                                        Text('sur ${widget.total}', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // XP GAGNÉ (Task 5.1)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: EskoliaVisual.neonAmber.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: EskoliaVisual.neonAmber.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('✨', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '+${(widget.score * 10).toInt()} XP',
                                          style: TextStyle(
                                            color: EskoliaVisual.neonAmber,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildScoreBar(),
                                const SizedBox(height: 32),
                                _detailSummary(),
                                const SizedBox(height: 16),
                                if (_findNextModule() != null) ...[
                                  _buildNextChapterCard(_findNextModule()!),
                                  const SizedBox(height: 16),
                                ],
                                const Text('Détail de la maîtrise', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                const SizedBox(height: 12),
                              ]),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) {
                                  final q = widget.questions[i];
                                  final sc = widget.userScores[i] ?? 0.0;
                                  return _buildQuestionCard(i, q, sc);
                                },
                                childCount: widget.questions.length,
                              ),
                            ),
                          ),
                          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                        ],
                      ),
                    ),
                    _buildBottomButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuizQuestion q, double score) {
    Color statusColor = _red;
    IconData statusIcon = Icons.close_rounded;

    if (score >= 1.0) {
      statusColor = _green;
      statusIcon = Icons.verified_rounded;
    } else if (score > 0) {
      statusColor = _orange;
      statusIcon = Icons.lightbulb_rounded;
    }

    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text('Question ${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(q.question, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _slate, fontSize: 11)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(q.answer, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                if (q.explanation != null) ...[
                  const SizedBox(height: 12),
                  Text(q.explanation!, style: TextStyle(color: _slate, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _miniAction(Icons.push_pin_rounded, "Révision", () => RevisionPoolRepository().add(q)),
                    const SizedBox(width: 8),
                    _miniAction(Icons.menu_book_rounded, "Cours", () async {
                      final id = await courseModuleIdForQuizContext(widget.sessionId, q);
                      if (id != null && mounted) {
                        showQuizLessonPreviewDialog(context, id);
                      }
                    }),
                    const SizedBox(width: 8),
                    _miniAction(Icons.flag_outlined, "Signaler", () {
                      showQuizQuestionReportDialog(context, q);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: _cyan),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _detailSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(widget.correctCount.toString(), "Maîtrisées", _green),
          _statItem(widget.unansweredCount.toString(), "Passées", _slate),
          _statItem(widget.wrongCount.toString(), "À revoir", _red),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScoreBar() {
    final scores = widget.userScores;
    if (scores.isEmpty) return const SizedBox.shrink();
    return Row(
      children: List.generate(scores.length, (i) {
        final s = scores[i] ?? 0.0;
        final Color c = s >= 1.0 ? _green : (s > 0 ? _orange : _red);
        final isLast = i == scores.length - 1;
        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: isLast ? 0 : 3),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  ModuleModel? _findNextModule() {
    final loc = ParcoursRepository.moduleLocation[widget.sessionId];
    if (loc == null) return null;
    final section = ParcoursRepository.sectionByCompoundKey['${loc.formationId}::${loc.sectionId}'];
    if (section == null) return null;
    final modules = section.modules;
    final idx = modules.indexWhere((m) => m.id == widget.sessionId);
    if (idx < 0 || idx >= modules.length - 1) return null;
    return modules[idx + 1];
  }

  Widget _buildNextChapterCard(ModuleModel next) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.go('/parcours');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _violet.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _violet.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _violet.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('\u{1F4D6}', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapitre suivant',
                    style: TextStyle(color: _violet, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    next.title,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: _violet, size: 14),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadBilan() async {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final questions = List.generate(widget.questions.length, (i) {
      final q = widget.questions[i];
      final s = widget.userScores[i] ?? 0.0;
      final result = s >= 1.0 ? 'correct' : s > 0 ? 'partial' : 'wrong';
      return {
        'question': q.question,
        'answer': q.answer,
        if (q.explanation != null) 'explanation': q.explanation,
        'result': result,
        'userScore': s,
      };
    });
    final payload = jsonEncode({
      'bilan': {
        'quizTitle': widget.sessionTitle,
        'date': date,
        'score': widget.score,
        'total': widget.total,
        'correct': widget.correctCount,
        'wrong': widget.wrongCount,
        'unanswered': widget.unansweredCount,
      },
      'questions': questions,
    });
    final safeName = widget.sessionTitle
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    await EskoliaFolderService.instance.saveFile(
      EskoliaFolder.bilans,
      'bilan_${safeName}_$date.json',
      payload,
      mimeType: 'application/json',
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    final next = _findNextModule();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, _bg.withValues(alpha: 0.8), _bg])
      ),
      child: Column(
        children: [
          if (next != null) ...[
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/parcours');
              },
              style: FilledButton.styleFrom(backgroundColor: _violet, minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                next.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: next != null ? Colors.white.withValues(alpha: 0.08) : _violet,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('REJOUER LA SESSION', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _downloadBilan,
            style: OutlinedButton.styleFrom(
              foregroundColor: _cyan,
              side: BorderSide(color: _cyan.withValues(alpha: 0.4)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Sauvegarder mon bilan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              final destination = widget.exitDestination == QuizResultExitDestination.soloMenu ? '/solo' : '/parcours';
              Navigator.of(context).pop();
              context.go(destination);
            },
            child: Text('RETOUR AU MENU', style: TextStyle(color: _slate, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
