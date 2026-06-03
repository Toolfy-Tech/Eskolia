import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../auth/data/user_model.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/tip_progress_repository.dart';

const Color _gold = Color(0xFFFFD166);
const Color _goldDark = Color(0xFFCC9B1A);
const Color _slate = Color(0xFF94A3B8);

/// Affiche le certificat de completion d'une formation.
/// Route : /certificate/:formationId  (ex. /certificate/optimus)
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.formationId});

  final String formationId;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  UserModel? _user;
  int _completed = 0;
  int _total = 0;
  bool _loading = true;
  DateTime? _completionDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final userSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userSnap.data();
    UserModel? user;
    if (userData != null) {
      user = UserModel.fromFirestore(userSnap);
    }

    // Progression Optimus
    final done = await TipProgressRepository().readCompletedIds();
    final completed = done.where((id) => id.startsWith('${widget.formationId}_')).length;
    final total = ParcoursRepository.moduleCatalog.keys
        .where((k) => k.startsWith('${widget.formationId}_'))
        .length;

    // Date de completion (SharedPrefs ou aujourd'hui si complété)
    final completionDate = completed >= total && total > 0 ? DateTime.now() : null;

    if (!mounted) return;
    setState(() {
      _user = user;
      _completed = completed;
      _total = total > 0 ? total : 23;
      _completionDate = completionDate;
      _loading = false;
    });
  }

  String get _formationLabel => switch (widget.formationId) {
        'optimus' => 'Parcours Optimus TIP',
        _ => widget.formationId,
      };

  static String _formatDate(DateTime d) {
    const months = [
      'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'aout', 'septembre', 'octobre', 'novembre', 'decembre'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String _compactDate(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  String get _certId {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'XXX';
    final date = _compactDate(_completionDate ?? DateTime.now());
    return 'ESK-${widget.formationId.toUpperCase()}-${uid.substring(0, 6).toUpperCase()}-$date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              children: [
                EskoliaAppBar.standard(context, title: 'Certificat'),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: EskoliaVisual.neonCyan))
                      : _completed < _total
                          ? _buildNotEarned()
                          : _buildCertificate(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotEarned() {
    final ratio = _total > 0 ? (_completed / _total) : 0.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.emoji_events_outlined, color: _gold, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pas encore !',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Termine les $_total chapitres du $_formationLabel pour\ndebloquer ton certificat.',
              style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progression', style: TextStyle(color: _slate, fontSize: 13)),
                      Text(
                        '$_completed / $_total chapitres',
                        style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(_gold),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.go('/parcours'),
              icon: const Icon(Icons.arrow_forward_rounded, color: _gold),
              label: const Text('Continuer le parcours', style: TextStyle(color: _gold, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificate() {
    final user = _user;
    final dateStr = _formatDate(_completionDate ?? DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          // Carte certificat
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E293B),
                  _gold.withValues(alpha: 0.06),
                  const Color(0xFF0F172A),
                ],
              ),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // En-tete
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded, color: _gold, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'ESKOLIA',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Plateforme de formation IT',
                  style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: _gold.withValues(alpha: 0.25)),
                const SizedBox(height: 24),
                const Text(
                  'CERTIFICAT DE COMPLETION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ce certificat atteste que',
                  style: TextStyle(color: _slate, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Apprenant',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'a completé avec succes le',
                  style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  _formationLabel,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: _gold.withValues(alpha: 0.15)),
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(value: '$_total', label: 'Chapitres'),
                    Container(width: 1, height: 40, color: _gold.withValues(alpha: 0.2)),
                    _Stat(value: '${user?.totalQuizzesPlayed ?? 0}', label: 'Quiz joués'),
                    Container(width: 1, height: 40, color: _gold.withValues(alpha: 0.2)),
                    _Stat(value: '${user?.xp ?? 0}', label: 'XP total'),
                  ],
                ),
                const SizedBox(height: 24),
                Container(height: 1, color: _gold.withValues(alpha: 0.15)),
                const SizedBox(height: 16),
                Text(
                  'Délivré le $dateStr',
                  style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  _certId,
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.45),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Boutons
          _PrintButton(),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.home_rounded, color: _slate.withValues(alpha: 0.6), size: 18),
            label: Text(
              'Retour a l\'accueil',
              style: TextStyle(color: _slate.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: _gold, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }
}

class _PrintButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilise Ctrl+P (ou Cmd+P) depuis ton navigateur pour imprimer / sauvegarder en PDF.'),
              duration: Duration(seconds: 5),
            ),
          );
        },
        icon: const Icon(Icons.print_rounded, color: _gold),
        label: const Text('Imprimer / Exporter PDF', style: TextStyle(color: _gold, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _gold.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
