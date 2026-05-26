import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../feedback/data/models/question_feedback.dart';
import '../../feedback/data/question_feedback_repository.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF43E97B);
const Color _red = Color(0xFFE53935);
const Color _violet = Color(0xFF6C63FF);
const Color _surface = Color(0xFF1E293B);

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _repo = QuestionFeedbackRepository();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<_ThemeStat> _byTheme(List<QuestionFeedback> all) {
    final map = <String, _ThemeStat>{};
    for (final f in all) {
      if (f.vote == 0) continue;
      final key = f.theme ?? f.quizTitle ?? 'Sans theme';
      map[key] ??= _ThemeStat(label: key);
      if (f.vote > 0) map[key]!.pos++;
      else map[key]!.neg++;
    }
    return map.values.toList()
      ..sort((a, b) => (b.pos + b.neg).compareTo(a.pos + a.neg));
  }

  List<_QuestionStat> _byQuestion(List<QuestionFeedback> all, {required bool liked}) {
    final map = <String, _QuestionStat>{};
    for (final f in all) {
      if (f.vote == 0) continue;
      map[f.questionId] ??= _QuestionStat(
        questionId: f.questionId,
        quizTitle: f.quizTitle,
        theme: f.theme,
        questionType: f.questionType,
        difficulty: f.difficulty,
      );
      if (f.vote > 0) map[f.questionId]!.pos++;
      else map[f.questionId]!.neg++;
    }
    return (map.values.where((q) => liked ? q.pos > 0 : q.neg > 0).toList()
      ..sort((a, b) => liked ? b.pos.compareTo(a.pos) : b.neg.compareTo(a.neg)))
        .take(50)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
      title: 'Feedback questions',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(
          context,
          title: 'Feedback questions',
          bottom: TabBar(
            controller: _tabs,
            labelColor: Colors.white,
            unselectedLabelColor: _slate,
            indicatorColor: _violet,
            tabs: const [
              Tab(text: 'Par theme'),
              Tab(text: '👍 Appreciees'),
              Tab(text: '👎 Rejetees'),
            ],
          ),
        ),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: StreamBuilder<List<QuestionFeedback>>(
                stream: _repo.watchAllFeedback(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Erreur de chargement.',
                        style: TextStyle(color: _slate),
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data!;
                  return TabBarView(
                    controller: _tabs,
                    children: [
                      _buildThemeTab(all),
                      _buildRankingTab(all, liked: true),
                      _buildRankingTab(all, liked: false),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTab(List<QuestionFeedback> all) {
    final stats = _byTheme(all);
    if (stats.isEmpty) return _empty('Aucun vote enregistre pour l\'instant.');
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        16,
        EskoliaLayout.screenPaddingH,
        EskoliaLayout.screenPaddingBottom,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ThemeCard(stat: stats[i]),
      ),
    );
  }

  Widget _buildRankingTab(List<QuestionFeedback> all, {required bool liked}) {
    final stats = _byQuestion(all, liked: liked);
    if (stats.isEmpty) {
      return _empty(liked
          ? 'Aucune question avec des 👍 pour l\'instant.'
          : 'Aucune question avec des 👎 pour l\'instant.');
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        16,
        EskoliaLayout.screenPaddingH,
        EskoliaLayout.screenPaddingBottom,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _QuestionStatCard(stat: stats[i], liked: liked, rank: i + 1),
      ),
    );
  }

  Widget _empty(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📊', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      );
}

class _ThemeStat {
  _ThemeStat({required this.label});
  final String label;
  int pos = 0;
  int neg = 0;
  int get total => pos + neg;
  double get ratio => total == 0 ? 0 : pos / total;
}

class _QuestionStat {
  _QuestionStat({
    required this.questionId,
    this.quizTitle,
    this.theme,
    required this.questionType,
    required this.difficulty,
  });
  final String questionId;
  final String? quizTitle;
  final String? theme;
  final String questionType;
  final String difficulty;
  int pos = 0;
  int neg = 0;
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.stat});
  final _ThemeStat stat;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${stat.total} vote${stat.total > 1 ? "s" : ""}',
                style: TextStyle(color: _slate, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 12, color: _red.withValues(alpha: 0.25)),
                      FractionallySizedBox(
                        widthFactor: stat.ratio.clamp(0.0, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '👍 ${stat.pos}  👎 ${stat.neg}',
                style: TextStyle(color: _slate, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionStatCard extends StatelessWidget {
  const _QuestionStatCard({
    required this.stat,
    required this.liked,
    required this.rank,
  });
  final _QuestionStat stat;
  final bool liked;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final accent = liked ? _green : _red;
    final count = liked ? stat.pos : stat.neg;
    return EskoliaCardContent(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stat.quizTitle != null)
                  Text(
                    stat.quizTitle!,
                    style: TextStyle(color: _slate, fontSize: 10),
                  ),
                if (stat.theme != null)
                  Text(
                    stat.theme!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(stat.questionType),
                    _chip(stat.difficulty),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${liked ? "👍" : "👎"} $count',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(color: _slate, fontSize: 10)),
      );
}
