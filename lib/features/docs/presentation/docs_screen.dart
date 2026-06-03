import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import 'docs_mini_course_dialog.dart';


const String _assetMiniRgpd = 'data/docs/mini_formation_rgpd.md';
const String _assetMiniCnil = 'data/docs/mini_formation_cnil.md';
const String _assetMiniAnssi = 'data/docs/mini_formation_anssi.md';
const String _assetMiniItil = 'data/docs/mini_formation_itil.md';
const String _assetMiniOsi = 'data/docs/mini_formation_osi.md';

/// Ressources métiers : conformité, cybersécurité, réseaux, gestion des services IT.
class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  static const String _cnilRgpd =
      'https://www.cnil.fr/fr/reglement-europeen-protection-donnees';
  static const String _cnilHome = 'https://www.cnil.fr/';
  static const String _anssiHome = 'https://www.ssi.gouv.fr/';
  static const String _itilHome = 'https://www.axelos.com/best-practice-solutions/itil';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
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
                  'Repères pour techniciens : conformité, protection des données, '
                  'cybersécurité et gestion des services IT. '
                  'Rappel pédagogique — ne remplace pas un avis juridique.',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const _MesCoursCard(),
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
                  onQuiz: () => context.go('/quiz/quick'),
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
                  onQuiz: () => context.go('/quiz/quick'),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'ANSSI & bonnes pratiques ops',
                  accent: EskoliaVisual.neonGreen,
                  body: _anssiBody,
                  linkLabel: 'Site de l\'ANSSI',
                  onLink: () => _openUrl(context, _anssiHome),
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — ANSSI',
                    assetPath: _assetMiniAnssi,
                    officialUrl: _anssiHome,
                    officialLinkLabel: 'Site de l\'ANSSI',
                  ),
                  onQuiz: () => context.go('/quiz/quick'),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'ITIL 4 — Gestion des services IT',
                  accent: const Color(0xFF60A5FA),
                  body: _itilBody,
                  linkLabel: 'Site officiel ITIL (Axelos)',
                  onLink: () => _openUrl(context, _itilHome),
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — ITIL 4',
                    assetPath: _assetMiniItil,
                    officialUrl: _itilHome,
                    officialLinkLabel: 'Site officiel ITIL',
                  ),
                  onQuiz: () => context.go('/quiz/quick'),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'Modèle OSI & réseaux',
                  accent: const Color(0xFF34D399),
                  body: _osiBody,
                  linkLabel: null,
                  onLink: null,
                  onCardTap: () => showDocsMiniCourseDialog(
                    context,
                    title: 'Mini-formation — Modèle OSI',
                    assetPath: _assetMiniOsi,
                    officialUrl: null,
                    officialLinkLabel: null,
                  ),
                  onQuiz: () => context.go('/quiz/quick'),
                ),
                const SizedBox(height: 12),
                _DocSectionCard(
                  title: 'Ce qu\'un bon technicien garde en tête',
                  accent: const Color(0xFFFFB74D),
                  body: _technicianBody,
                  linkLabel: null,
                  onLink: null,
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
    '• Droits des personnes : information, accès, rectification, effacement, '
    'limitation, opposition, portabilité selon les cas.\n'
    '• Sécurité : mesures techniques et organisationnelles adaptées au risque.\n'
    '• Violation de données : analyse et notification dans les délais (souvent 72 h).\n'
    '• Registre des traitements et AIPD lorsque requis.';

const String _cnilBody = 'La CNIL est l\'autorité française de protection des données. '
    'Elle publie guides, modèles et recommandations (sécurité, cookies, RH, etc.) '
    'et peut être saisie en cas de difficulté. Identifier un DPO si la taille '
    'ou le type d\'activité l\'impose.';

const String _anssiBody = 'L\'ANSSI oriente la cybersécurité en France : bonnes pratiques, '
    'guides d\'hygiène numérique, référentiels et réponse à incident. '
    'Pour un technicien : durcissement, segmentation, journaux, sauvegardes testées, '
    'gestion des mises à jour et culture du signalement.';

const String _itilBody = '• SVS (Service Value System) : gouvernance, pratiques, '
    'chaîne de valeur et amélioration continue.\n'
    '• 4 dimensions : Organisations, Information/Tech, Partenaires, Flux de valeur.\n'
    '• Pratiques clés : gestion des incidents, des problèmes, des changements, '
    'centre de services, SLA/OLA.\n'
    '• Incident = interruption non planifiée. Problème = cause racine. '
    'CMDB = inventaire des CI.\n'
    '• 7 principes directeurs dont : focaliser sur la valeur, itérer avec feedback, simplifier.';

const String _osiBody = '• 7 couches (bas → haut) : Physique, Liaison, Réseau, '
    'Transport, Session, Présentation, Application.\n'
    '• Couche 3 (Réseau) : IP, routeurs. Couche 2 (Liaison) : MAC, switches.\n'
    '• TCP (couche 4) : fiable et ordonné. UDP : rapide mais sans garantie.\n'
    '• Encapsulation : données → segment → paquet → trame → bits.\n'
    '• TCP/IP regroupe en 4 couches : Application, Transport, Internet, Accès réseau.';

const String _technicianBody = '• Moindre privilège et comptes nominatifs (éviter les comptes partagés).\n'
    '• Traçabilité : qui a accédé à quoi, et pourquoi.\n'
    '• Sauvegardes 3-2-1 et tests de restauration réguliers.\n'
    '• Patchs et inventaire : savoir ce qui est exposé.\n'
    '• Pas de copie de bases de prod sur poste non sécurisé.\n'
    '• Chiffrement des supports nomades et des canaux sensibles.\n'
    '• En cas d\'incident : préserver les preuves, escalader, ne pas improviser seul.';

class _MesCoursCard extends StatefulWidget {
  const _MesCoursCard();

  @override
  State<_MesCoursCard> createState() => _MesCoursCardState();
}

class _MesCoursCardState extends State<_MesCoursCard> {
  Future<void> _pick() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.cours);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun cours dans Eskolia/Cours/. Genere des cours depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CoursFilePicker(files: files),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.cours, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce cours.')));
      return;
    }
    if (!mounted) return;
    final title = picked.replaceAll('cours_', '').replaceAll('.md', '').replaceAll('_', ' ');
    _openCours(title, content);
  }

  void _openCours(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 20), onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                h2: const TextStyle(color: EskoliaTokens.cyanSoft, fontSize: 15, fontWeight: FontWeight.w600),
                h3: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                listBullet: const TextStyle(color: EskoliaTokens.textSecondary),
                strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                code: const TextStyle(color: EskoliaTokens.success, fontFamily: 'monospace', fontSize: 12, backgroundColor: EskoliaTokens.bgBase),
                blockquote: const TextStyle(color: EskoliaTokens.amber, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer', style: TextStyle(color: EskoliaTokens.textSecondary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      gradientColors: [
        const EskoliaTokens.violetSoft.withValues(alpha: 0.6),
        const EskoliaTokens.cyanSoft.withValues(alpha: 0.3),
      ],
      glowColor: const EskoliaTokens.violetSoft.withValues(alpha: 0.25),
      borderRadius: 18,
      innerBlurSigma: 12,
      innerColor: EskoliaTokens.bgBase,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('\u{1F4D6}', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Mes cours sauvegardés',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Lis les cours .md que tu as generés depuis le Notebook et sauvegardes dans Eskolia/Cours/.',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pick,
            style: OutlinedButton.styleFrom(
              foregroundColor: const EskoliaTokens.violetSoft,
              side: BorderSide(color: const EskoliaTokens.violetSoft.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.folder_open_rounded, size: 16),
            label: const Text('Ouvrir un cours'),
          ),
        ],
      ),
    );
  }
}

class _CoursFilePicker extends StatelessWidget {
  const _CoursFilePicker({required this.files});
  final List<String> files;

  String _label(String f) => f.replaceAll('cours_', '').replaceAll('.md', '').replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Choisir un cours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.description_rounded, color: EskoliaTokens.violetSoft),
              title: Text(_label(files[i]), style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(files[i], style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
              onTap: () => Navigator.of(context).pop(files[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DocSectionCard extends StatelessWidget {
  const _DocSectionCard({
    required this.title,
    required this.accent,
    required this.body,
    required this.linkLabel,
    required this.onLink,
    this.onCardTap,
    this.onQuiz,
  });

  final String title;
  final Color accent;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLink;
  final VoidCallback? onCardTap;
  final VoidCallback? onQuiz;

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
      innerColor: EskoliaTokens.bgBase,
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
            const SizedBox(height: 4),
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
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.98),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          if (linkLabel != null && onLink != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onLink,
              icon: Icon(Icons.open_in_new_rounded, size: 16, color: accent),
              label: Text(
                linkLabel!,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          if (onQuiz != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onQuiz,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: accent.withValues(alpha: 0.15),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_rounded, size: 14, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        'Quiz rapide',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
