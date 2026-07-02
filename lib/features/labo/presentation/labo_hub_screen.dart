import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/providers/home_providers.dart';

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
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                12,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Center(
                          child: Text(
                            '🔬 Le Labo',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final isAddedToHome = ref.watch(homeCardsOrderProvider).contains('feature:labo_contrib');
                          return IconButton(
                            icon: Icon(
                              isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                              color: isAddedToHome ? EskoliaTokens.cyan : Colors.white54,
                            ),
                            onPressed: () {
                              if (isAddedToHome) {
                                ref.read(homeCardsOrderProvider.notifier).removeCard('feature:labo_contrib');
                              } else {
                                ref.read(homeCardsOrderProvider.notifier).addCard('feature:labo_contrib');
                              }
                            },
                            tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                FutureBuilder<UserModel?>(
                  future: userFuture,
                  builder: (context, snap) {
                    final staff = userHasStaffAccess(snap.data, email);
                    if (!staff) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              EskoliaTokens.amber.withValues(alpha: 0.15),
                              EskoliaTokens.error.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: EskoliaTokens.amber.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: EskoliaTokens.amber.withValues(alpha: 0.08),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/admin'),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: EskoliaTokens.amber.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '\u{1F6E1}\u{FE0F}',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Espace modération',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Signalements & gestion des questions',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white60,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'Contribue à la qualité du contenu TIP : signale les erreurs, propose des questions (intégrées aux quiz une fois validées), partage des astuces.',
                  style: GoogleFonts.plusJakartaSans(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                
                // Card 1 : Remonter une erreur
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 6,
                            color: Colors.orangeAccent,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('\u{1F6A9}', style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remonter une erreur',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'À la fin d’un quiz, ouvre le détail d’une question et tape « Signaler ». Choisis le type (faute, mauvaise réponse, …) et envoie : ça part vers l’équipe.',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _slate.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: uid.isEmpty
                                        ? null
                                        : () => context.push('/labo/reports'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
                                      foregroundColor: Colors.orangeAccent,
                                      side: const BorderSide(color: Colors.orangeAccent, width: 1.2),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                                    label: Text(
                                      'Mes signalements',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                  if (uid.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Connecte-toi pour voir ton historique.',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _slate.withValues(alpha: 0.6),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2 : Créer une question
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 6,
                            color: _cyan,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('\u{2795}', style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Créer une question',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'QCM 4 choix, aperçu avant envoi. Après validation admin, la question est mélangée aux quiz (rapide, personnalisé, survival, examen blanc…) selon la section indiquée.',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _slate.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () => context.push('/labo/create-question'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _cyan.withValues(alpha: 0.15),
                                      foregroundColor: _cyan,
                                      side: const BorderSide(color: _cyan, width: 1.2),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                                    label: Text(
                                      'Ouvrir le formulaire',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3 : Proposer un tip
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 6,
                            color: EskoliaTokens.pink,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('\u{1F4A1}', style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Proposer un tip',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Astuce, piège, mnémotechnique… Liée à un module du parcours. Visible sur la page cours après validation.',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _slate.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () => context.push('/labo/create-tip'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: EskoliaTokens.pink.withValues(alpha: 0.15),
                                      foregroundColor: EskoliaTokens.pink,
                                      side: const BorderSide(color: EskoliaTokens.pink, width: 1.2),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 20),
                                    label: Text(
                                      'Proposer une astuce',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
