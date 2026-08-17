import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/eskolia_tokens.dart';
import '../../models/tp_exam_model.dart';

class TpExamCard extends StatelessWidget {
  const TpExamCard({
    super.key,
    required this.scenario,
    this.onRefresh,
  });

  final TpExamScenario scenario;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFB300);
    final isDone = scenario.isCompleted;
    final checkedCount = scenario.checkedTaskIds.length;
    final totalCount = scenario.tasks.length;
    final hasStarted = checkedCount > 0 && !isDone;

    return Container(
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? EskoliaTokens.success.withValues(alpha: 0.5)
              : (hasStarted ? EskoliaTokens.cyan.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1)),
          width: isDone || hasStarted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? EskoliaTokens.success.withValues(alpha: 0.08)
                : (hasStarted ? EskoliaTokens.cyan.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.2)),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec statuts
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛠️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          'TP VM Win 11',
                          style: GoogleFonts.outfit(
                            color: goldColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isDone) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: EskoliaTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: EskoliaTokens.success, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            scenario.userScore != null
                                ? 'Note : ${scenario.userScore!.toStringAsFixed(1)}/20'
                                : 'Épreuve Validée',
                            style: GoogleFonts.outfit(
                              color: EskoliaTokens.success,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (hasStarted) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '$checkedCount / $totalCount tâches',
                        style: GoogleFonts.outfit(
                          color: EskoliaTokens.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Non commencé',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenario.subtitle,
                    style: TextStyle(
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contexte collaborateur & VM
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoLine(
                          Icons.person_rounded,
                          'Collaborateur',
                          '${scenario.candidateName} (${scenario.companyName})',
                        ),
                        const SizedBox(height: 6),
                        _buildInfoLine(
                          Icons.accessible_rounded,
                          'Handicap / Adaptation',
                          scenario.accessibilityContext,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoLine(
                          Icons.computer_rounded,
                          'Machine Cible',
                          '${scenario.vmInfo.vmName} ➔ ${scenario.vmInfo.targetHostname}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/exams/tp/${scenario.id}').then((_) => onRefresh?.call());
                          },
                          icon: Icon(
                            isDone ? Icons.visibility_rounded : Icons.play_arrow_rounded,
                            size: 16,
                            color: goldColor,
                          ),
                          label: Text(
                            isDone ? 'Voir l\'épreuve' : (hasStarted ? 'Continuer' : 'Lancer l\'épreuve'),
                            style: GoogleFonts.outfit(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: goldColor.withValues(alpha: 0.6)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      if (isDone) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/exams/tp/${scenario.id}/correction').then((_) => onRefresh?.call());
                            },
                            icon: const Icon(Icons.school_rounded, size: 16, color: Colors.black),
                            label: Text(
                              'Corrigé & Note',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EskoliaTokens.success,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoLine(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, height: 1.3),
              children: [
                TextSpan(
                  text: '$label : ',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
