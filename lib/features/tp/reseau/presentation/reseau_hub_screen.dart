import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';

const Color _slate  = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _cyan   = Color(0xFF00BCD4);

class ReseauHubScreen extends StatelessWidget {
  const ReseauHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Réseau & Adressage IP',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 100),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cyan.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: _cyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'TPs complets avec corrigé automatique et calculatrice intégrée.',
                          style: TextStyle(color: _slate, fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                EskoliaCardContent(
                  accentBorderColor: _violet,
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.push('/tp/binaire'),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _violet.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('\u{1F4DD}', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'TPs Binaire & Adressage',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _violet.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    '15 TPs',
                                    style: TextStyle(
                                      color: _violet,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Conversions, classes IP, masques, CIDR et subnetting. 3 niveaux + génération IA.',
                              style: TextStyle(
                                color: _slate.withValues(alpha: 0.8),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white24),
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
