import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../solo/data/practical_missions_firestore_repository.dart';

const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);

class TpHubScreen extends StatefulWidget {
  const TpHubScreen({super.key});

  @override
  State<TpHubScreen> createState() => _TpHubScreenState();
}

class _TpHubScreenState extends State<TpHubScreen> {
  final _firestoreRepo = PracticalMissionsFirestoreRepository();
  final Set<String> _interestedTracks = {};

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;

    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Travaux Pratiques'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 100),
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Color(0xFF3B82F6), width: 3)),
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text(
                        'SCÉNARIOS ACTIVE DIRECTORY',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 11 * 0.08,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScenarioCard(
                      id: 'tp_ad_aerotech',
                      title: 'AeroTech Solutions',
                      description: 'Installation et configuration de base d\'un contrôleur de domaine Windows Server 2022.',
                      emoji: '✈️',
                      difficulty: 'Débutant',
                    ),
                    const SizedBox(height: 12),
                    _buildScenarioCard(
                      id: 'tp_ad_pixel',
                      title: 'Pixel Academy',
                      description: 'Gestion des GPO et déploiement de logiciels pour une école de design.',
                      emoji: '🎨',
                      difficulty: 'Intermédiaire',
                    ),
                    const SizedBox(height: 12),
                    _buildScenarioCard(
                      id: 'tp_ad_saint_lazare',
                      title: 'Saint-Lazare Digital',
                      description: 'Sécuriser l\'infrastructure d\'un hôpital sous contraintes RGPD.',
                      emoji: '🏥',
                      difficulty: 'Avancé',
                      accentColor: const Color(0xFFE74C3C),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Color(0xFF64748B), width: 3)),
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text(
                        'BIENTÔT DISPONIBLE',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 11 * 0.08,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildComingSoonCard(
                      id: 'tp_filius',
                      title: 'Simulation Réseau',
                      description: 'Maîtrise les topologies réseau avec Filius et Packet Tracer.',
                      emoji: '🌐',
                    ),
                    const SizedBox(height: 12),
                    _buildComingSoonCard(
                      id: 'tp_itil',
                      title: 'Gestion de Tickets (ITIL)',
                      description: 'Apprends à gérer un Service Desk comme un pro.',
                      emoji: '🎫',
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard({
    required String id,
    required String title,
    required String description,
    required String emoji,
    required String difficulty,
    Color? accentColor,
  }) {
    final color = accentColor ?? _violet;
    return EskoliaCardContent(
      accentBorderColor: color,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/tp/$id'),
      child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(difficulty, style: const TextStyle(color: _slate, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
    );
  }

  Widget _buildComingSoonCard({
    required String id,
    required String title,
    required String description,
    required String emoji,
  }) {
    final hasInterest = _interestedTracks.contains(id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 11)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: hasInterest ? null : () async {
                    await _firestoreRepo.markInterest(id);
                    if (mounted) {
                      setState(() => _interestedTracks.add(id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('C\'est noté ! On vous préviendra. 🚀')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasInterest ? Colors.transparent : _violet.withValues(alpha: 0.15),
                    foregroundColor: hasInterest ? _slate : _violet,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: hasInterest ? Colors.white10 : _violet.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Text(hasInterest ? 'Inscrit ✔' : 'Ça m\'intéresse'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
