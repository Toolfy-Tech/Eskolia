import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../admin/data/staff_capability.dart';
import '../../auth/data/user_model.dart';
import '../../../core/constants/eskolia_tokens.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = EskoliaTokens.violetSoft;
const Color _cyan = EskoliaTokens.cyan;
const Color _slate = EskoliaTokens.textSecondary;

/// Hub Le Labo — blueprint v3.
class LaboHubScreen extends StatelessWidget {
  const LaboHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final email = FirebaseAuth.instance.currentUser?.email;
    final userFuture = uid.isEmpty
        ? Future<UserModel?>.value(null)
        : UserRepository().getUserById(uid);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Le Labo'),
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
                FutureBuilder<UserModel?>(
                  future: userFuture,
                  builder: (context, snap) {
                    final staff = userHasStaffAccess(snap.data, email);
                    if (!staff) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => context.push('/admin'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '\u{1F6E1}\u{FE0F}',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Espace modération',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Signalements & brouillons questions',
                                        style: TextStyle(
                                          color: _slate.withValues(alpha: 0.85),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'Contribue à la qualité du contenu TIP : signale les erreurs, '
                  'propose des questions (intégrées aux quiz une fois validées), '
                  'partage des astuces.',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                EskoliaCardContent(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u{1F6A9} Remonter une erreur',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'À la fin d’un quiz, ouvre le détail d’une question et '
                        'tape « Signaler ». Choisis le type (faute, mauvaise réponse, …) '
                        'et envoie : ça part vers l’équipe.',
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.95),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: uid.isEmpty
                            ? null
                            : () => context.push('/labo/reports'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _cyan,
                          foregroundColor: Colors.black87,
                        ),
                        icon: const Icon(Icons.list_alt_rounded, size: 20),
                        label: const Text('Mes signalements'),
                      ),
                      if (uid.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Connecte-toi pour voir ton historique.',
                            style: TextStyle(
                              color: _slate.withValues(alpha: 0.65),
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                EskoliaCardContent(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u{2795} Créer une question',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'QCM 4 choix, aperçu avant envoi. Après validation admin, la '
                        'question est mélangée aux quiz (rapide, personnalisé, survival, '
                        'examen blanc…) selon la section indiquée.',
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.95),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => context.push('/labo/create-question'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _violet,
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 22),
                        label: const Text('Ouvrir le formulaire'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                EskoliaCardContent(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u{1F4A1} Proposer un tip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Astuce, piège, mnémotechnique… Liée à un module du parcours. '
                        'Visible sur la page cours après validation.',
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.95),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => context.push('/labo/create-tip'),
                        style: FilledButton.styleFrom(
                          backgroundColor: EskoliaTokens.pink,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.lightbulb_outline_rounded, size: 22),
                        label: const Text('Proposer une astuce'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
