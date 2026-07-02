import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/eskolia_visual.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../shared/widgets/eskolia_button.dart';

class NotebookSubjectResult {
  const NotebookSubjectResult({
    required this.subject,
    required this.course,
    required this.quizJson,
  });

  final String subject;
  final String course;
  final String quizJson;

  bool get hasCourse => course.isNotEmpty;

  bool get hasQuiz {
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      return ((data['questions'] as List?)?.isNotEmpty) ?? false;
    } catch (_) {
      return false;
    }
  }

  int get questionCount {
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      return ((data['questions'] as List<dynamic>?)?.length) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  List<(int, String, Color)> get typeSummary {
    const labels = <String, (String, Color)>{
      'classic':            ('Q&R',        EskoliaTokens.violetSoft),
      'ticket':             ('Ticket',     EskoliaTokens.cyan),
      'diagnostic_indices': ('Diagnostic', EskoliaTokens.amber),
      'sequence':           ('Sequence',   EskoliaTokens.success),
    };
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>? ?? [];
      final counts = <String, int>{};
      for (final q in questions) {
        if (q is! Map) continue;
        final t = (q['type'] as String?)?.trim() ?? 'classic';
        counts[t] = (counts[t] ?? 0) + 1;
      }
      return counts.entries.map((e) {
        final info = labels[e.key] ?? ('Autre', EskoliaTokens.textSecondary);
        return (e.value, info.$1, info.$2);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class NotebookCourseSheet extends StatelessWidget {
  const NotebookCourseSheet({
    super.key,
    required this.result,
    required this.onPlayQuiz,
    required this.onDownloadQuiz,
    required this.onDownloadCourse,
  });

  final NotebookSubjectResult result;
  final VoidCallback onPlayQuiz;
  final VoidCallback onDownloadQuiz;
  final VoidCallback onDownloadCourse;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: EskoliaVisual.bgElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Text('\u{1F4DA}', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              // Markdown content
              Expanded(
                child: Markdown(
                  controller: scrollCtrl,
                  data: result.course,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                    h1: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    h2: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    h3: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    code: const TextStyle(
                      color: EskoliaTokens.cyan,
                      backgroundColor: Colors.white10,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    blockquote: const TextStyle(
                      color: EskoliaTokens.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                    listBullet: const TextStyle(color: EskoliaTokens.violetSoft, fontSize: 13),
                    tableBody: const TextStyle(color: Colors.white70, fontSize: 12),
                    tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: EskoliaVisual.bgElevated,
                  border: Border(
                    top: BorderSide(color: Colors.white12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EskoliaButton(
                      label: 'Faire le quiz associé',
                      icon: Icons.sports_esports_rounded,
                      variant: EskoliaButtonVariant.primary,
                      expand: true,
                      onPressed: onPlayQuiz,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EskoliaButton(
                            label: 'Télécharger cours .md',
                            icon: Icons.download_rounded,
                            variant: EskoliaButtonVariant.secondary,
                            expand: true,
                            color: EskoliaTokens.amber,
                            textColor: EskoliaTokens.amber,
                            onPressed: onDownloadCourse,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EskoliaButton(
                            label: 'Télécharger quiz .json',
                            icon: Icons.download_rounded,
                            variant: EskoliaButtonVariant.secondary,
                            expand: true,
                            color: EskoliaTokens.success,
                            textColor: EskoliaTokens.success,
                            onPressed: onDownloadQuiz,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
