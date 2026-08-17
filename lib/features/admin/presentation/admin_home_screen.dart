import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../tp/exam_tp/data/tp_exam_repository.dart';
import 'staff_gate_scaffold.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
      title: 'Modération',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(context, title: 'Modération'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  EskoliaLayout.screenPaddingH,
                  12,
                  EskoliaLayout.screenPaddingH,
                  EskoliaLayout.screenPaddingBottom,
                ),
                children: [
                  Text(
                    'File de validation, signalements et contrôle des épreuves.',
                    style: TextStyle(
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Carte de contrôle : Épreuves Pratiques TP VM
                  StreamBuilder<bool>(
                    stream: TpExamRepository.instance.watchTpExamEnabled(),
                    builder: (context, snapshot) {
                      final isEnabled = snapshot.data ?? false;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? EskoliaTokens.cyan.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEnabled
                                ? EskoliaTokens.cyan.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '🛠️',
                              style: TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Épreuves Pratiques TP VM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isEnabled
                                              ? Colors.green.shade900.withValues(alpha: 0.5)
                                              : Colors.amber.shade900.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isEnabled ? Colors.greenAccent : Colors.amberAccent,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          isEnabled ? '🟢 VISIBLE ÉLÈVES' : '🔒 MASQUÉ',
                                          style: TextStyle(
                                            color: isEnabled ? Colors.greenAccent : Colors.amberAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isEnabled
                                        ? 'Les 4 TP VM sont actuellement débloqués et visibles par les élèves dans la section Examens Blancs.'
                                        : 'Les 4 TP VM sont masqués aux élèves. Basculez l\'interrupteur pour ouvrir la session d\'examen pratique.',
                                    style: TextStyle(
                                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch.adaptive(
                              value: isEnabled,
                              activeColor: EskoliaTokens.cyan,
                              onChanged: (val) async {
                                await TpExamRepository.instance.setTpExamEnabled(val);
                                if (context.mounted) {
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
                    },
                  ),
                  const SizedBox(height: 14),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{1F6A9}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Signalements',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Erreurs signalées sur les questions',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/signalements'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{2795}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Brouillons de questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Propositions du Labo (labo_question_drafts)',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/drafts'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{1F4A1}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Tips communauté',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Astuces liées aux modules (community_tips)',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/tips'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{1F44D}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Feedback questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Votes 👍/👎 des joueurs par thème et question',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/feedback'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{1F4DA}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Quiz du prof',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Quiz importés et gérés par les admins',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/teacher-quizzes'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text(
                        '\u{1F465}',
                        style: TextStyle(fontSize: 32),
                      ),
                      title: const Text(
                        'Vue classe',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'XP, série, quiz et activité de chaque élève',
                        style: TextStyle(
                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/classe'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
