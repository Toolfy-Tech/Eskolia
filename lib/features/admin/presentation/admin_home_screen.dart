import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
      title: 'Modération',
      child: Scaffold(
        backgroundColor: _bg,
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
                    'File de validation et signalements (Firestore).',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.95),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                          color: _slate.withValues(alpha: 0.9),
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
                          color: _slate.withValues(alpha: 0.9),
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
                          color: _slate.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => context.push('/admin/tips'),
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
