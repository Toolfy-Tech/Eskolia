import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../tp/osi/presentation/widgets/osi_memento_dialog.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';
import '../../../shared/widgets/eskolia_section_card.dart';
import 'docs_mini_course_dialog.dart';
import '../../../core/constants/eskolia_tokens.dart';
import 'providers/docs_providers.dart';

import '../../quiz/services/quiz_repository.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';

const Color _slate = EskoliaTokens.textSecondary;

Future<void> openDocsUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
    );
  }
}

/// Ressources métiers : conformité, cybersécurité, réseaux, gestion des services IT.
class DocsScreen extends ConsumerStatefulWidget {
  const DocsScreen({super.key});

  @override
  ConsumerState<DocsScreen> createState() => _DocsScreenState();

  static const String assetMiniRgpd = 'data/docs/mini_formation_rgpd.md';
  static const String assetMiniCnil = 'data/docs/mini_formation_cnil.md';
  static const String assetMiniAnssi = 'data/docs/mini_formation_anssi.md';
  static const String assetMiniItil = 'data/docs/mini_formation_itil.md';
  static const String assetMiniOsi = 'data/docs/mini_formation_osi.md';

  static const String cnilRgpd =
      'https://www.cnil.fr/fr/reglement-europeen-protection-donnees';
  static const String cnilHome = 'https://www.cnil.fr/';
  static const String anssiHome = 'https://www.ssi.gouv.fr/';
  static const String itilHome = 'https://www.axelos.com/best-practice-solutions/itil';

  static const String rgpdBody =
      '• 6 Principes Fondamentaux : Licéité, Limitation des finalités, Minimisation des données, Exactitude, Conservation limitée, Intégrité & Confidentialité (chiffrement TLS/AES).\n'
      '• Droits des Personnes : Droit d\'accès, de rectification, d\'effacement (« droit à l\'oubli »), de limitation, de portabilité et d\'opposition.\n'
      '• Rôle Ops & Technicien : Tenue du Registre des traitements, habilitations strictes (RBAC), interdiction formelle de copier des bases de prod en local.\n'
      '• Violations de données : Notification obligatoire à la CNIL sous 72 h max en cas de fuite, perte ou altération de données personnelles.\n'
      '• Sanctions : Jusqu\'à 20 millions d\'euros ou 4 % du chiffre d\'affaires mondial annuel.';

  static const String cnilBody =
      '• Autorité française de régulation : Protège la vie privée, contrôle le respect du RGPD, accompagne la mise en conformité et sanctionne les abus.\n'
      '• Guides & Référentiels Ops : Recommandations sécurité (mots de passe 12+ car / MFA, traçabilité des logs, politique de sauvegardes, contrôle d\'accès).\n'
      '• Cookies & Traceurs (ePrivacy) : Recueil obligatoire du consentement préalable libre, éclairé, spécifique et univoque avant tout dépôt.\n'
      '• AIPD (Analyse d\'Impact) : Obligatoire pour tout traitement à risque élevé pour les droits et libertés (données de santé, biométrie, surveillance).\n'
      '• Délégué à la Protection des Données (DPO) : Interlocuteur clé de la DSI, désignation obligatoire dans le secteur public et pour les activités sensibles.';

  static const String anssiBody =
      '• Guide d\'Hygiène Informatique (40 règles d\'or de l\'autorité nationale) :\n'
      '• Authentification & Accès : MFA obligatoire (accès distants & comptes d\'administration), mots de passe robustes (12+ car), séparation stricte compte utilisateur / compte admin (PoLP).\n'
      '• Maintien en Condition de Sécurité : Patch management régulier, élimination des protocoles obsolètes (SMBv1, NTLMv1, TLS 1.0/1.1), durcissement GPO.\n'
      '• Architecture & Résilience : Segmentation étanche (VLANs filtrés, DMZ, réseau d\'admin dédié), règle de sauvegarde 3-2-1 (copie immuable / hors-ligne).\n'
      '• Traçabilité & Supervision : Centralisation et horodatage des logs (NTP), remontée d\'alertes auprès du CERT-FR.\n'
      '• Réflexe Incident / Ransomware : Déconnecter immédiatement du réseau (câble + Wi-Fi), ne PAS éteindre la machine (préserver la RAM), prévenir le RSSI.';

  static const String itilBody =
      '• SVS & 4 Dimensions : Organisations/Personnes, Information/Tech, Partenaires/Fournisseurs, Flux de valeur & Processus.\n'
      '• Gestion des Incidents : Rétablir le service normal le plus rapidement possible (solutions de contournement / workarounds prioritaires).\n'
      '• Gestion des Problèmes : Identifier la cause racine (RCA - Root Cause Analysis) et documenter les erreurs connues (Known Errors / KEDB).\n'
      '• Gestion des Changements (Change Enablement) : Évaluation des risques, validation CAB, plan de test et plan de rollback obligatoire.\n'
      '• Service Desk & CMDB : Point de contact unique (SPOC), gestion des SLA/OLA (GTI/GTR), cartographie des CI et de leurs dépendances.\n'
      '• 7 Principes Directeurs : Focaliser sur la valeur, partir de l\'existant, itérer avec feedback, collaborer, penser holistique, faire simple, optimiser et automatiser.';

  static const String osiBody =
      '• Les 7 Couches & PDU (de haut en bas) :\n'
      '  - L7 Application (HTTP/S, DNS, DHCP, SSH, FTP) • PDU : Données\n'
      '  - L6 Présentation (TLS/SSL, JSON, JPEG, encodage) • PDU : Données\n'
      '  - L5 Session (RPC, NetBIOS, maintien de sessions) • PDU : Données\n'
      '  - L4 Transport : TCP (fiable / 3-way handshake) vs UDP (rapide / temps réel) • PDU : Segments / Datagrammes\n'
      '  - L3 Réseau : Adressage IPv4/IPv6, routage, ICMP (Ping), ARP • PDU : Paquets\n'
      '  - L2 Liaison : Adresses MAC, trames Ethernet, Switchs L2, VLANs (802.1Q) • PDU : Trames\n'
      '  - L1 Physique : Câblage RJ45 Cat 6, fibre optique, signaux électriques / optiques / radio • PDU : Bits\n'
      '• Encapsulation : Données ➔ Segments ➔ Paquets ➔ Trames ➔ Bits.\n'
      '• Diagnostics Réseau : ping, tracert, nslookup, ipconfig /all, netstat -ano, wireshark.';

  static const String technicianBody =
      '• Moindre Privilège & Identités : Séparation stricte compte utilisateur / compte admin (aucun compte partagé), modèle de tiering AD (Tier 0, Tier 1, Tier 2).\n'
      '• Postes Clients & Données : Chiffrement intégral des disques (BitLocker / FileVault), verrouillage automatique de session (Win+L / 5 min), zéro données réelles de prod sur postes locaux.\n'
      '• Baies de Brassage & Câblage : Repérage et étiquetage systématique des câbles RJ45, brassage propre, testeur de continuité réseau, sécurisation des ports switch (802.1X, Port Security).\n'
      '• Gestion des Secrets & Mots de Passe : Coffre-fort chiffré partagé (KeePass, Bitwarden), aucun mot de passe en clair dans un ticket ou fichier texte.\n'
      '• Réflexe Alerte Cyber / Ransomware : Isoler la machine du réseau (débrancher câble + couper Wi-Fi), ne PAS éteindre le PC (préserver la RAM pour l\'analyse forensic), alerter immédiatement le N2 / RSSI.';
}

class _DocsScreenState extends ConsumerState<DocsScreen> {
  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    final width = MediaQuery.sizeOf(context).width;

    final isLargeScreen = width >= 700;
    final sidebarWidth = isLargeScreen ? (ref.watch(sidebarCollapsedProvider) ? 78.0 : 250.0) : 0.0;
    final availableWidth = (width - sidebarWidth - (hPad * 2)).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('docs'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final order = ref.watch(docsCardsOrderProvider);

    const availableDocsCards = [
      EskoliaCardOption(key: 'feature:docs_mes_cours', title: 'Mes cours sauvegardés', emoji: '📚'),
      EskoliaCardOption(key: 'feature:docs_mes_quiz', title: 'Mes quiz sauvegardés', emoji: '🎮'),
      EskoliaCardOption(key: 'feature:docs_rgpd', title: 'RGPD (UE)', emoji: '⚖️'),
      EskoliaCardOption(key: 'feature:docs_cnil', title: 'CNIL & Règlements', emoji: '🏛️'),
      EskoliaCardOption(key: 'feature:docs_anssi', title: 'ANSSI & bonnes pratiques', emoji: '🛡️'),
      EskoliaCardOption(key: 'feature:docs_itil', title: 'ITIL 4 (Services IT)', emoji: '🎟️'),
      EskoliaCardOption(key: 'feature:docs_osi', title: 'Modèle OSI & réseaux', emoji: '🌐'),
      EskoliaCardOption(key: 'feature:docs_technician', title: 'Technicien - Bonnes pratiques', emoji: '💡'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
              children: [
                EskoliaPageHeaderToolbar(
                  title: 'Docs métier',
                  screenKey: 'docs',
                  onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(order),
                  onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(order),
                  availableCards: availableDocsCards,
                  maxColumns: 4,
                ),
                const SizedBox(height: 12),
                EskoliaMultiColumnBoard(
                  screenKey: 'docs',
                  activeKeys: order,
                  numColumns: numColumns,
                  cardWidth: cardWidth,
                  cardBuilder: (ctx, key) => _buildCardContent(key, ctx),
                ),
                const SizedBox(height: 40),
                Text(
                  'Repères pour techniciens : conformité, protection des données, cybersécurité et gestion des services IT.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(String key, BuildContext context) {
    if (key == 'feature:docs_mes_cours') {
      return _buildInteractiveCard(
        key: key,
        category: 'MÉMOS PERSO',
        title: 'Mes cours sauvegardés',
        defaultEmoji: '📚',
        accentColor: EskoliaTokens.violetSoft,
        body: const MesCoursCard(),
      );
    }
    if (key == 'feature:docs_mes_quiz') {
      return _buildInteractiveCard(
        key: key,
        category: 'QUIZ PERSO',
        title: 'Mes quiz sauvegardés',
        defaultEmoji: '🎮',
        accentColor: EskoliaTokens.cyan,
        body: const MesQuizCard(),
      );
    }
    if (key == 'feature:docs_rgpd') {
      return _buildInteractiveCard(
        key: key,
        category: 'CONFORMITÉ',
        title: 'RGPD (UE)',
        defaultEmoji: '⚖️',
        accentColor: EskoliaVisual.neonViolet,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonViolet,
          body: DocsScreen.rgpdBody,
          linkLabel: 'Fiche CNIL sur le RGPD',
          onLink: () => openDocsUrl(context, DocsScreen.cnilRgpd),
          onMiniCourse: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — RGPD',
            assetPath: DocsScreen.assetMiniRgpd,
            officialUrl: DocsScreen.cnilRgpd,
            officialLinkLabel: 'Fiche CNIL sur le règlement européen',
          ),
          onQuiz: () => context.go('/quiz/quick'),
        ),
      );
    }
    if (key == 'feature:docs_cnil') {
      return _buildInteractiveCard(
        key: key,
        category: 'CONFORMITÉ',
        title: 'CNIL',
        defaultEmoji: '🏢',
        accentColor: EskoliaVisual.neonCyan,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonCyan,
          body: DocsScreen.cnilBody,
          linkLabel: 'Site officiel CNIL',
          onLink: () => openDocsUrl(context, DocsScreen.cnilHome),
          onMiniCourse: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — CNIL',
            assetPath: DocsScreen.assetMiniCnil,
            officialUrl: DocsScreen.cnilHome,
            officialLinkLabel: 'Site de la CNIL',
          ),
          onQuiz: () => context.go('/quiz/quick'),
        ),
      );
    }
    if (key == 'feature:docs_anssi') {
      return _buildInteractiveCard(
        key: key,
        category: 'SÉCURITÉ',
        title: 'ANSSI & bonnes pratiques',
        defaultEmoji: '🛡️',
        accentColor: EskoliaVisual.neonGreen,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonGreen,
          body: DocsScreen.anssiBody,
          linkLabel: 'Site officiel ANSSI',
          onLink: () => openDocsUrl(context, DocsScreen.anssiHome),
          onMiniCourse: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — ANSSI',
            assetPath: DocsScreen.assetMiniAnssi,
            officialUrl: DocsScreen.anssiHome,
            officialLinkLabel: 'Site de l\'ANSSI',
          ),
          onQuiz: () => context.go('/quiz/quick'),
        ),
      );
    }
    if (key == 'feature:docs_itil') {
      return _buildInteractiveCard(
        key: key,
        category: 'SERVICES IT',
        title: 'ITIL 4 (Services IT)',
        defaultEmoji: '🎟️',
        accentColor: const Color(0xFF60A5FA),
        body: DocSectionCardBody(
          accent: const Color(0xFF60A5FA),
          body: DocsScreen.itilBody,
          linkLabel: 'Site officiel ITIL (Axelos)',
          onLink: () => openDocsUrl(context, DocsScreen.itilHome),
          onMiniCourse: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — ITIL 4',
            assetPath: DocsScreen.assetMiniItil,
            officialUrl: DocsScreen.itilHome,
            officialLinkLabel: 'Site officiel ITIL',
          ),
          onQuiz: () => context.go('/quiz/quick'),
        ),
      );
    }
    if (key == 'feature:docs_osi') {
      return _buildInteractiveCard(
        key: key,
        category: 'INFRA & RÉSEAUX',
        title: 'Modèle OSI & réseaux',
        defaultEmoji: '🌐',
        accentColor: const Color(0xFF34D399),
        body: DocSectionCardBody(
          accent: const Color(0xFF34D399),
          body: DocsScreen.osiBody,
          linkLabel: null,
          onLink: null,
          onMiniCourse: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — Modèle OSI',
            assetPath: DocsScreen.assetMiniOsi,
            officialUrl: null,
            officialLinkLabel: null,
          ),
          onQuiz: () => context.go('/quiz/quick'),
          extraButtons: [
            ElevatedButton.icon(
              onPressed: () => context.go('/tp/osi'),
              icon: const Icon(Icons.rocket_launch_rounded, size: 15),
              label: const Text('Accéder au Hub Modèle OSI 🚀'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => OsiMementoDialog.show(context),
              icon: const Icon(Icons.menu_book_rounded, size: 15),
              label: const Text('Mémento OSI 📖'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF34D399),
                side: BorderSide(color: const Color(0xFF34D399).withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    if (key == 'feature:docs_technician') {
      return _buildInteractiveCard(
        key: key,
        category: 'BONNES PRATIQUES',
        title: 'Technicien - Bonnes pratiques',
        defaultEmoji: '💡',
        accentColor: const Color(0xFFFFB74D),
        body: DocSectionCardBody(
          accent: const Color(0xFFFFB74D),
          body: DocsScreen.technicianBody,
          linkLabel: null,
          onLink: null,
          onQuiz: () => context.go('/quiz/quick'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInteractiveCard({
    required String key,
    required String category,
    required String title,
    required String defaultEmoji,
    required Color accentColor,
    required Widget body,
    VoidCallback? onCardTap,
  }) {
    final isPinned = ref.watch(docsPinnedCardsProvider).contains(key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);

    return EskoliaSectionCard(
      cardKey: key,
      badge: 'DOCS',
      title: title,
      accentColor: accentColor,
      isPinned: isPinned,
      onTogglePin: () => ref.read(docsPinnedCardsProvider.notifier).togglePin(key),
      isAddedToHome: isAddedToHome,
      onToggleHome: () {
        if (isAddedToHome) {
          ref.read(homeCardsOrderProvider.notifier).removeCard(key);
        } else {
          ref.read(homeCardsOrderProvider.notifier).addCard(key);
        }
      },
      onInfoTap: (key == 'feature:docs_mes_cours' || key == 'feature:docs_mes_quiz')
          ? () => _showOrganizerTutoDialog(context, key)
          : null,
      body: body,
    );
  }

  void _showOrganizerTutoDialog(BuildContext context, String key) {
    final isCours = key == 'feature:docs_mes_cours';
    final title = isCours
        ? 'Organiser tes cours sauvegardés'
        : 'Organiser tes quiz et flashcards';

    final settingsMap = ref.read(homeCardSettingsProvider);
    final settings = settingsMap[key];
    final displayAccentColor = settings != null
        ? Color(settings.colorHex)
        : (isCours ? EskoliaTokens.violetSoft : EskoliaTokens.cyan);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: EskoliaTokens.surface1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Icon(
                        isCours ? Icons.menu_book_rounded : Icons.sports_esports_rounded,
                        color: displayAccentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTutoStep(
                          number: '1',
                          title: 'Sélectionne un dossier sur ton PC',
                          subtitle: 'Rends-toi dans l\'onglet Réglages ⚙️ puis sous la section « Mes fichiers » pour connecter un dossier de ton choix (ex: Documents/Eskolia).',
                        ),
                        const SizedBox(height: 16),
                        _buildTutoStep(
                          number: '2',
                          title: 'Classe tes fichiers librement',
                          subtitle: isCours
                              ? 'Tous les cours que tu sauvegarderas s\'enregistreront dans le sous-dossier « Cours ». Crée des dossiers par matière (Maths, Réseau, etc.) directement depuis ton ordinateur pour les trier !'
                              : 'Les quiz se placent dans « Quiz » et les flashcards dans « Flashcards ». Tu peux créer des sous-dossiers par matière sur ton PC pour organiser ta liste automatiquement.',
                        ),
                        const SizedBox(height: 16),
                        _buildTutoStep(
                          number: '3',
                          title: 'Profite de la sauvegarde en ligne',
                          subtitle: 'Si tu n\'as pas connecté de dossier sur ton PC, pas d\'inquiétude ! Tous tes contenus restent sauvegardés en mémoire dans l\'application.',
                        ),
                        if (isCours) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: displayAccentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: displayAccentColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Un grand merci à Angélique pour la rédaction soignée des cours !',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                // Action
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: displayAccentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Compris !', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutoStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MesCoursCard extends StatefulWidget {
  const MesCoursCard({super.key});

  @override
  State<MesCoursCard> createState() => _MesCoursCardState();
}

class _MesCoursCardState extends State<MesCoursCard> {
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
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir un cours',
        icon: Icons.description_rounded,
        iconColor: EskoliaTokens.violetSoft,
      ),
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
                h2: const TextStyle(color: EskoliaTokens.cyan, fontSize: 15, fontWeight: FontWeight.w600),
                h3: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                listBullet: const TextStyle(color: EskoliaTokens.textSecondary),
                strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                code: const TextStyle(color: EskoliaVisual.neonGreen, fontFamily: 'monospace', fontSize: 12, backgroundColor: EskoliaTokens.bgBase),
                blockquote: const TextStyle(color: Color(0xFFFFC107), fontStyle: FontStyle.italic),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lis les cours .md que tu as generés depuis le Notebook et sauvegardes dans Eskolia/Cours/.',
          style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pick,
          style: OutlinedButton.styleFrom(
            foregroundColor: EskoliaTokens.violetSoft,
            side: BorderSide(color: EskoliaTokens.violetSoft.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.folder_open_rounded, size: 16),
          label: const Text('Ouvrir un cours'),
        ),
      ],
    );
  }
}

class _DocFilePicker extends StatelessWidget {
  const _DocFilePicker({
    required this.files,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final List<String> files;
  final String title;
  final IconData icon;
  final Color iconColor;

  String _label(String f) => f
      .replaceAll('cours_', '')
      .replaceAll('quiz_', '')
      .replaceAll('flashcards_', '')
      .replaceAll('.md', '')
      .replaceAll('.json', '')
      .replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (_, i) => ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(_label(files[i]), style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(files[i], style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 11)),
              onTap: () => Navigator.of(context).pop(files[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class MesQuizCard extends StatefulWidget {
  const MesQuizCard({super.key});

  @override
  State<MesQuizCard> createState() => _MesQuizCardState();
}

class _MesQuizCardState extends State<MesQuizCard> {
  Future<void> _pickQuiz() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.quiz);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun quiz dans Eskolia/Quiz/. Génère des quiz depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir un quiz',
        icon: Icons.quiz_rounded,
        iconColor: EskoliaTokens.cyan,
      ),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.quiz, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce quiz.')));
      return;
    }
    try {
      final subject = picked.replaceAll('quiz_', '').replaceAll('.json', '').replaceAll('_', ' ');
      final session = await QuizRepository().buildFromNotebookQuizJson(content, subject);
      if (mounted) context.push('/quiz/run', extra: session);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du décodage du quiz.')));
    }
  }

  Future<void> _pickFlashcards() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.flashcards);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune flashcard dans Eskolia/Flashcards/. Génère des flashcards depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir des flashcards',
        icon: Icons.style_rounded,
        iconColor: Colors.amber,
      ),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.flashcards, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ces flashcards.')));
      return;
    }
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>? ?? [];
      final cards = <DeckFlashcard>[];
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        cards.add(DeckFlashcard(
          id: 'fc_$i',
          front: q['question'] ?? '',
          back: q['answer'] ?? '',
          mastery: 0,
          nextDue: DateTime.now(),
        ));
      }
      if (mounted) {
        context.push('/flashcards/session', extra: FlashcardSessionRouteArgs(cards: cards, ephemeral: true));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du décodage des flashcards.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Joue aux quiz et flashcards que tu as générés depuis le Notebook et sauvegardés sur ton PC.',
          style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickQuiz,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EskoliaTokens.cyan,
                  side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: const Text('Lancer un quiz'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFlashcards,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.style_rounded, size: 16),
                label: const Text('Ouvrir Flashcards'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DocSectionCardBody extends StatelessWidget {
  const DocSectionCardBody({
    super.key,
    required this.accent,
    required this.body,
    this.linkLabel,
    this.onLink,
    this.onCardTap,
    this.onMiniCourse,
    this.onQuiz,
    this.extraButtons,
  });

  final Color accent;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLink;
  final VoidCallback? onCardTap;
  final VoidCallback? onMiniCourse;
  final VoidCallback? onQuiz;
  final List<Widget>? extraButtons;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          body,
          style: const TextStyle(
            color: _slate,
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
        if (extraButtons != null && extraButtons!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: extraButtons!,
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (onMiniCourse != null || onCardTap != null)
              OutlinedButton.icon(
                onPressed: onMiniCourse ?? onCardTap,
                icon: const Icon(Icons.school_outlined, size: 14),
                label: const Text('Mini-cours complet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            if (onQuiz != null)
              InkWell(
                onTap: onQuiz,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: accent.withValues(alpha: 0.15),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_rounded, size: 13, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        'Quiz rapide',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (linkLabel != null && onLink != null)
              TextButton.icon(
                onPressed: onLink,
                icon: Icon(Icons.open_in_new_rounded, size: 13, color: accent),
                label: Text(
                  linkLabel!,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
