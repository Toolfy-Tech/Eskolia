import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/tip_section_theme.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../economy/data/daily_quest_reward_service.dart';
import '../../home/data/daily_quests_repository.dart';
import '../../quiz/data/quiz_repository.dart';
import '../data/parcours_repository.dart';
import '../data/tip_progress_repository.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _violetBrand = Color(0xFF6C63FF);
const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _slateLight = Color(0xFF94A3B8);
const Color _surface = Color(0xFF1E293B);

class ParcoursScreen extends StatefulWidget {
  const ParcoursScreen({super.key, this.expandFormationId});

  /// Si présent (`tip`, `optimus`, …), la carte du parcours correspondant s’ouvre dépliée.
  final String? expandFormationId;

  @override
  State<ParcoursScreen> createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends State<ParcoursScreen>
    with SingleTickerProviderStateMixin {
  final ParcoursRepository _repo = ParcoursRepository();
  late AnimationController _pulseController;
  int _streamRetry = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await DailyQuestRewardService().onParcoursVisited(uid);
        final u = await UserRepository().getUserById(uid);
        if (u != null) {
          await AchievementTriggers(
            onUnlocked: (emoji, title) {
              if (!mounted) return;
              showAchievementSnackBar(context, emoji, title);
            },
          ).syncFromUserSnapshot(u);
        }
      } else {
        await DailyQuestsRepository().markParcoursProgressDone();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: uid.isEmpty
                          ? const _EmptyState(
                              emoji: '\u{1F4ED}',
                              message: 'Aucune formation disponible',
                            )
                          : StreamBuilder<List<FormationModel>>(
                              key: ValueKey(_streamRetry),
                              stream: _repo.watchFormations(uid),
                              builder: (context, snap) {
                                if (snap.hasError) {
                                  return _ErrorState(
                                    message: snap.error.toString(),
                                    onRetry: () =>
                                        setState(() => _streamRetry++),
                                  );
                                }
                                if (snap.connectionState ==
                                        ConnectionState.waiting &&
                                    !snap.hasData) {
                                  return _SkeletonLoader(
                                    pulse: _pulseController,
                                  );
                                }
                                if (!snap.hasData) {
                                  return _SkeletonLoader(
                                    pulse: _pulseController,
                                  );
                                }
                                final list = snap.data!;
                                if (list.isEmpty) {
                                  return const _EmptyState(
                                    emoji: '\u{1F4ED}',
                                    message: 'Aucune formation disponible',
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    EskoliaLayout.screenPaddingH,
                                    8,
                                    EskoliaLayout.screenPaddingH,
                                    100,
                                  ),
                                  itemCount: list.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return const Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: _DocsMetierCard(),
                                      );
                                    }
                                    final formation = list[index - 1];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: _FormationCard(
                                        formation: formation,
                                        index: index - 1,
                                        initiallyExpanded: widget.expandFormationId !=
                                                null &&
                                            formation.id ==
                                                widget.expandFormationId,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.menu_book_rounded,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            tooltip: 'Docs métier',
            onPressed: () => context.push('/docs'),
          ),
          const Expanded(
            child: Text(
              'Mes Parcours',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _FormationCard extends StatefulWidget {
  const _FormationCard({
    required this.formation,
    required this.index,
    this.initiallyExpanded = false,
  });

  final FormationModel formation;
  final int index;
  final bool initiallyExpanded;

  @override
  State<_FormationCard> createState() => _FormationCardState();
}

class _FormationCardState extends State<_FormationCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant _FormationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formation;
    final ratio = f.progress.clamp(0.0, 1.0);
    final done = ratio >= 0.999;
    final started = ratio > 0.02;
    final List<Color> borderGrad;
    final Color? glow;
    if (done) {
      borderGrad = EskoliaVisual.borderLive;
      glow = EskoliaVisual.neonGreen;
    } else if (started) {
      borderGrad = EskoliaVisual.borderPrimary;
      glow = _violetBrand;
    } else {
      borderGrad = [
        Colors.white.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.08),
      ];
      glow = null;
    }

    Widget card = GradientBorderCard(
      gradientColors: borderGrad,
      glowColor: glow,
      borderRadius: 20,
      innerBlurSigma: 14,
      innerColor: const Color(0xFF0E1520),
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12),
              splashColor: _violetBrand.withValues(alpha: 0.2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.iconEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.description,
                          style: TextStyle(
                            color: _slateLight.withValues(alpha: 0.95),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 6,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(color: _surface),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: ratio,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [_violetBrand, _cyan],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              '${f.completedModules} / ${f.totalModules} modules',
                              style: TextStyle(
                                color: _slate.withValues(alpha: 0.95),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: _slateLight.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < f.sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _SectionTile(section: f.sections[i]),
                    ],
                    if (f.id == 'tip' || f.id == 'optimus') ...[
                      const SizedBox(height: 14),
                      _GrandFinaleParcoursSection(formation: f),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
    );

    return card
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.06,
          duration: 300.ms,
          delay: (widget.index * 100).ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    final t = TipSectionTheme.colorsFor(section.id);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.primary.withValues(alpha: 0.22)),
        color: t.primary.withValues(alpha: 0.06),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: EskoliaVisual.glow(t.glow, blur: 10, alpha: 0.4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.98),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final m in section.modules)
            _ModuleTile(module: m, sectionAccent: t.primary),
        ],
      ),
    );
  }
}

bool _formationAllSectionExamsCompleted(FormationModel f) {
  for (final sec in f.sections) {
    for (final m in sec.modules) {
      if (m.type == 'exam' && !m.isCompleted) return false;
    }
  }
  return true;
}

/// Carte « examen blanc » (TIP ou Optimus) — débloquée quand chaque section a son évaluation validée.
class _GrandFinaleParcoursSection extends StatefulWidget {
  const _GrandFinaleParcoursSection({required this.formation});

  final FormationModel formation;

  @override
  State<_GrandFinaleParcoursSection> createState() =>
      _GrandFinaleParcoursSectionState();
}

class _GrandFinaleParcoursSectionState extends State<_GrandFinaleParcoursSection> {
  StreamSubscription<void>? _sub;
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _reloadIds();
    _sub = TipProgressRepository.updates.listen((_) => _reloadIds());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _reloadIds() async {
    final s = await TipProgressRepository().readCompletedIds();
    if (mounted) setState(() => _completed = s);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formation;
    final isTip = f.id == 'tip';
    final progressId = isTip
        ? QuizRepository.grandFinaleSessionId
        : QuizRepository.optimusGrandFinaleSessionId;
    final route = isTip
        ? '/quiz/epreuve-finale-tip'
        : '/quiz/epreuve-finale-optimus';
    final title = isTip
        ? 'Examen blanc — fin TIP'
        : 'Examen blanc — fin Optimus';
    final unlocked = _formationAllSectionExamsCompleted(f);
    final grandDone = _completed.contains(progressId);

    final borderColors = unlocked
        ? (isTip
            ? const [Color(0xFFFFB74D), Color(0xFFE040FB)]
            : const [Color(0xFF00BCD4), Color(0xFF6C63FF)])
        : [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.06),
          ];
    final accent = isTip ? const Color(0xFFFFB74D) : const Color(0xFF00BCD4);

    return GradientBorderCard(
      gradientColors: borderColors,
      glowColor: unlocked ? accent : null,
      borderRadius: 16,
      innerBlurSigma: 12,
      innerColor: const Color(0xFF121A28),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(isTip ? '\u{1F3C6}' : '\u{1F916}',
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: unlocked ? 1 : 0.65),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (grandDone)
                Text(
                  '\u{2705} Réussie',
                  style: TextStyle(
                    color: _slateLight.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            unlocked
                ? (isTip
                    ? 'Au moins 40 questions (moyen + difficile sur tout le catalogue TIP ; '
                        '« faciles » exclues sauf complément). Pour valider : 80 % de bonnes réponses.'
                    : 'Au moins ${QuizRepository.grandFinaleOptimusMinQuestions} questions '
                        '(moyen + difficile sur tout le catalogue Optimus ; « faciles » en complément). '
                        'Pour valider : 80 % de bonnes réponses.')
                : (isTip
                    ? 'Termine d’abord toutes les évaluations finales de section '
                        '(S01–S10).'
                    : 'Termine d’abord toutes les évaluations finales de section '
                        '(O01–O06).'),
            style: TextStyle(
              color: _slateLight.withValues(alpha: unlocked ? 0.9 : 0.65),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: unlocked ? () => context.push(route) : null,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor:
                  isTip ? const Color(0xFF1A1206) : const Color(0xFF0A1628),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
              disabledForegroundColor: _slate,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              grandDone ? 'Repasser l’épreuve' : 'Lancer l’épreuve finale',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.sectionAccent,
  });

  final ModuleModel module;
  final Color sectionAccent;

  static String _iconForType(String type) {
    switch (type) {
      case 'exam':
        return '\u{1F393}';
      case 'chapitre':
        return '\u{1F4D6}';
      case 'quiz':
        return '\u{1F4DD}';
      case 'flashcard':
        return '\u{1F0CF}';
      case 'cours':
      default:
        return '\u{1F4D6}';
    }
  }

  void _onTap(BuildContext context) {
    if (module.isLocked) return;
    switch (module.type) {
      case 'exam':
        if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'chapitre':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'quiz':
        context.push('/quiz/${module.id}');
        break;
      case 'cours':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'flashcard':
        context.push('/flashcards');
        break;
      default:
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = module.isLocked;
    final completed = module.isCompleted;

    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: locked ? 0.4 : 1,
        child: InkWell(
          onTap: locked ? null : () => _onTap(context),
          splashColor: sectionAccent.withValues(alpha: 0.35),
          highlightColor: sectionAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Text(
                  _iconForType(module.type),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    module.title,
                    style: TextStyle(
                      color: completed
                          ? _slateLight.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (completed)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\u{2705}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Terminé',
                        style: TextStyle(
                          color: _slate,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                else if (locked)
                  const Text(
                    '\u{1F512}',
                    style: TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final t = pulse.value;
              final c = Color.lerp(_surface, const Color(0xFF2D3748), t)!;
              return AnimatedContainer(
                duration: Duration.zero,
                height: 140,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '\u{26A0}\u{FE0F}',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slateLight.withValues(alpha: 0.95),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: _violetBrand,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.emoji,
    required this.message,
  });

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.95),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocsMetierCard extends StatelessWidget {
  const _DocsMetierCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/docs'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00BCD4).withValues(alpha: 0.18),
                const Color(0xFF6C63FF).withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF00BCD4).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Docs Metier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'RGPD, CNIL, ANSSI, ITIL, OSI — references et mini-formations.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
