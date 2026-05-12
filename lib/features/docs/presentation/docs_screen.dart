import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import 'docs_mini_course_dialog.dart';

const Color _slate = Color(0xFF94A3B8);

const String _assetMiniRgpd = 'data/docs/mini_formation_rgpd.md';
const String _assetMiniCnil = 'data/docs/mini_formation_cnil.md';
const String _assetMiniAnssi = 'data/docs/mini_formation_anssi.md';

/// Ressources métiers (repères RGPD / CNIL / ANSSI) et accès rapide aux cours des parcours.
class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  static const String _cnilRgpd =
      'https://www.cnil.fr/fr/reglement-europeen-protection-donnees';
  static const String _cnilHome = 'https://www.cnil.fr/';
  static const String _anssiHome = 'https://www.ssi.gouv.fr/';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: '\u{1F4CB} Docs métier',
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                8,
                EskoliaLayout.screenPaddingH,
                kEskoliaBottomNavReserve,
              ),
              children: [
                Text(
                  'Repères pour techniciens : conformité, protection des données et '
                  'cybersécurité. Rappel pédagogique — ne remplace ni un avis juridique '
                  'ni la politique de ton organisation.',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _DocSectionCard(
                  title: 'RGPD (UE)',
                  accent: EskoliaVisual.neonViolet,
                  body: _rgpdBody,
                  linkLabel: 'Fiche CNIL sur le règlement européen',
                  onLink: () => _openUrl(context, _cnilRgpd),
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — RGPD',
                    assetPath: _assetMiniRgpd,
                    officialUrl: _cnilRgpd,
                    officialLinkLabel: 'Fiche CNIL sur le règlement européen',
                  ),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'CNIL',
                  accent: EskoliaVisual.neonCyan,
                  body: _cnilBody,
                  linkLabel: 'Site de la CNIL',
                  onLink: () => _openUrl(context, _cnilHome),
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — CNIL',
                    assetPath: _assetMiniCnil,
                    officialUrl: _cnilHome,
                    officialLinkLabel: 'Site de la CNIL',
                  ),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'ANSSI & bonnes pratiques ops',
                  accent: EskoliaVisual.neonGreen,
                  body: _anssiBody,
                  linkLabel: 'Site de l’ANSSI',
                  onLink: () => _openUrl(context, _anssiHome),
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — ANSSI',
                    assetPath: _assetMiniAnssi,
                    officialUrl: _anssiHome,
                    officialLinkLabel: 'Site de l’ANSSI',
                  ),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'Ce qu’un bon technicien garde en tête',
                  accent: const Color(0xFFFFB74D),
                  body: _technicianBody,
                  linkLabel: null,
                  onLink: null,
                ),
                const SizedBox(height: 22),
                Text(
                  'Relire les cours',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ouvre le parcours avec les chapitres dépliés pour parcourir les leçons '
                  '(sans obligation de refaire les quiz).',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                _ParcoursShortcutCard(
                  emoji: '\u{1F393}',
                  title: 'Technicien informatique (TIP)',
                  subtitle: 'Parcours TIP — cours et modules',
                  onTap: () => context.go('/parcours?focus=tip'),
                ),
                const SizedBox(height: 10),
                _ParcoursShortcutCard(
                  emoji: '\u{2699}\u{FE0F}',
                  title: 'Parcours Optimus',
                  subtitle: 'Cours Optimus — relecture',
                  onTap: () => context.go('/parcours?focus=optimus'),
                ),
                const SizedBox(height: 10),
                _ParcoursShortcutCard(
                  emoji: '\u{1F4DA}',
                  title: 'Tous les parcours',
                  subtitle: 'Vue complète « Mes Parcours »',
                  onTap: () => context.go('/parcours'),
                  borderMuted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _rgpdBody = '• Finalité et base légale avant de traiter des données perso.\n'
    '• Minimisation : ne collecter que le nécessaire.\n'
    '• Droits des personnes : information, accès, rectification, effacement, limitation, opposition, portabilité selon les cas.\n'
    '• Sécurité : mesures techniques et organisationnelles adaptées au risque.\n'
    '• Sous-traitance : encadrement contractuel (ex. clauses types, DPA).\n'
    '• Violation de données : analyse et notification dans les délais prévus (souvent 72 h vers l’autorité, parfois aux personnes).\n'
    '• Registre des traitements et analyses d’impact (AIPD) lorsque requis.';

const String _cnilBody = 'La CNIL est l’autorité française de protection des données. '
    'Elle publie guides, modèles et recommandations (sécurité, cookies, RH, vidéo, etc.) '
    'et peut être saisie en cas de difficulté. En entreprise, identifier un interlocuteur '
    'référent données / DPO si la taille ou le type d’activité l’impose.';

const String _anssiBody = 'L’ANSSI oriente la cybersécurité en France : bonnes pratiques, '
    'guides d’hygiène numérique, référentiels, sensibilisation et réponse à incident. '
    'Pour un technicien : durcissement, segmentation, journaux, sauvegardes testées, '
    'gestion des mises à jour et culture du signalement.';

const String _technicianBody = '• Moindre privilège et comptes nominatifs (éviter les comptes partagés).\n'
    '• Traçabilité : qui a accédé à quoi, et pourquoi.\n'
    '• Sauvegardes 3-2-1 et tests de restauration réguliers.\n'
    '• Patchs et inventaire : savoir ce qui est exposé.\n'
    '• Pas de copie de bases de prod sur poste non sécurisé ; anonymiser si besoin de tests.\n'
    '• Chiffrement des supports nomades et des canaux sensibles.\n'
    '• En cas d’incident : préserver les preuves, escalader, ne pas improviser seul.';

class _DocSectionCard extends StatelessWidget {
  const _DocSectionCard({
    required this.title,
    required this.accent,
    required this.body,
    required this.linkLabel,
    required this.onLink,
    this.onCardTap,
  });

  final String title;
  final Color accent;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLink;
  /// Mini-formation en popup (carte entière cliquable).
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    final content = GradientBorderCard(
      gradientColors: [
        accent.withValues(alpha: 0.75),
        accent.withValues(alpha: 0.25),
      ],
      glowColor: accent.withValues(alpha: 0.35),
      borderRadius: 18,
      innerBlurSigma: 12,
      innerColor: const Color(0xFF101820),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (onCardTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: accent.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),
          if (onCardTap != null) ...[
            const SizedBox(height: 6),
            Text(
              'Touchez la carte pour une mini-formation',
              style: TextStyle(
                color: accent.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.98),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          if (linkLabel != null && onLink != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onLink,
              icon: Icon(Icons.open_in_new_rounded, size: 18, color: accent),
              label: Text(
                linkLabel!,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onCardTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accent.withValues(alpha: 0.12),
        highlightColor: accent.withValues(alpha: 0.06),
        child: content,
      ),
    );
  }
}

class _ParcoursShortcutCard extends StatelessWidget {
  const _ParcoursShortcutCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.borderMuted = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool borderMuted;

  @override
  Widget build(BuildContext context) {
    final border = borderMuted
        ? [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.06),
          ]
        : EskoliaVisual.borderPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GradientBorderCard(
          gradientColors: border,
          borderRadius: 16,
          innerBlurSigma: 10,
          innerColor: const Color(0xFF121A28),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.92),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
