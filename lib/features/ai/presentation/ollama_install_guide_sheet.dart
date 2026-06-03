import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/eskolia_tokens.dart';

// ── Donnees modeles ──────────────────────────────────────────────────────────

class _ModelRow {
  const _ModelRow(this.name, this.ram, this.quality, this.stars);
  final String name;
  final String ram;
  final String quality;
  final int stars;
}

const _models = <_ModelRow>[
  _ModelRow('gemma3',     '8 GB',  'Recommande',  5),
  _ModelRow('gemma3:12b', '16 GB', 'Excellent',   5),
  _ModelRow('llama3.3',   '8 GB',  'Tres bon',    4),
  _ModelRow('mistral',    '8 GB',  'Tres bon',    4),
  _ModelRow('qwen2.5',    '6 GB',  'Bon',         3),
];

// ── Widget principal ─────────────────────────────────────────────────────────

/// Fiche guide d'installation d'Ollama presentee en DraggableScrollableSheet.
/// A afficher via showModalBottomSheet avec isScrollControlled: true.
class OllamaInstallGuideSheet extends StatelessWidget {
  const OllamaInstallGuideSheet({super.key});

  /// Raccourci pour afficher la fiche depuis n'importe quel contexte.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OllamaInstallGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: EskoliaTokens.bgBase,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Poignee de drag
              const _DragHandle(),
              // En-tete fixe avec bouton fermer
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                  children: const [
                    SizedBox(height: 8),
                    _Step1(),
                    SizedBox(height: 20),
                    _Step2(),
                    SizedBox(height: 20),
                    _Step3(),
                    SizedBox(height: 20),
                    _UrlSection(),
                    SizedBox(height: 20),
                    _VerifySection(),
                    SizedBox(height: 20),
                    _ModelsTable(),
                    SizedBox(height: 20),
                    _TroubleshootSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── En-tete ──────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        children: [
          const Text(
            '\u{1F999}',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Installer Ollama en 3 etapes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: EskoliaTokens.textSecondary, size: 22),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: EskoliaTokens.violet,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ── Bloc terminal ─────────────────────────────────────────────────────────────

class _TerminalBlock extends StatelessWidget {
  const _TerminalBlock({required this.command});
  final String command;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: command));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande copiee : $command'),
        duration: const Duration(seconds: 2),
        backgroundColor: EskoliaTokens.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              command,
              style: const TextStyle(
                color: EskoliaTokens.success,
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _copy(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1F4CB}', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'Copier',
                    style: TextStyle(
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Etape 1 ───────────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1();

  Future<void> _openDownload() async {
    await launchUrl(
      Uri.parse('https://ollama.com/download'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ETAPE 1 — Telecharger Ollama'),
        const SizedBox(height: 12),
        Text(
          'Rendez-vous sur ollama.com/download',
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 4),
        _BulletLine('Choisissez Windows, macOS ou Linux'),
        _BulletLine('Lancez l\'installateur (~500 MB)'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openDownload,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Ouvrir ollama.com/download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EskoliaTokens.violet,
              side: BorderSide(color: EskoliaTokens.violet.withValues(alpha: 0.6)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section URLs ──────────────────────────────────────────────────────────────

class _UrlSection extends StatelessWidget {
  const _UrlSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('URL DE CONNEXION'),
        const SizedBox(height: 12),
        Text(
          'Selon votre plateforme, utilisez l\'URL adaptee :',
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 10),
        _UrlRow(label: 'Web / Bureau', url: 'http://127.0.0.1:11434'),
        const SizedBox(height: 6),
        _UrlRow(label: 'Emulateur Android', url: 'http://10.0.2.2:11434'),
      ],
    );
  }
}

class _UrlRow extends StatelessWidget {
  const _UrlRow({required this.label, required this.url});
  final String label;
  final String url;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL copiee : $url'),
        duration: const Duration(seconds: 2),
        backgroundColor: EskoliaTokens.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: EskoliaTokens.violet.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: EskoliaTokens.violet,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                color: EskoliaTokens.success,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => _copy(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                '\u{1F4CB}',
                style: TextStyle(fontSize: 14, color: EskoliaTokens.textSecondary.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Etape 2 ───────────────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  const _Step2();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ETAPE 2 — Installer Gemma 3'),
        const SizedBox(height: 12),
        Text(
          'Ouvrez un terminal (PowerShell sur Windows) et collez cette commande :',
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 10),
        const _TerminalBlock(command: 'ollama pull gemma3'),
        const SizedBox(height: 10),
        Text(
          'Telechargement : 3 a 10 minutes selon connexion (~5 GB)',
          style: TextStyle(
            color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ── Etape 3 ───────────────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  const _Step3();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('ETAPE 3 — Lancer Ollama'),
        const SizedBox(height: 12),
        Text(
          'Ollama demarre automatiquement. Si ce n\'est pas le cas :',
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 10),
        const _TerminalBlock(command: 'ollama serve'),
      ],
    );
  }
}

// ── Verification ─────────────────────────────────────────────────────────────

class _VerifySection extends StatelessWidget {
  const _VerifySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('VERIFIER QUE CA FONCTIONNE'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: EskoliaTokens.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EskoliaTokens.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: EskoliaTokens.success, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dans Eskolia, cliquez sur "Tester la connexion".',
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.95), fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tableau des modeles ───────────────────────────────────────────────────────

class _ModelsTable extends StatelessWidget {
  const _ModelsTable();

  String _stars(int count) {
    final filled = '⭐' * count;
    return filled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('MODELES RECOMMANDES'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: EskoliaTokens.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2.5),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.white.withValues(alpha: 0.07),
                width: 0.5,
              ),
            ),
            children: [
              // En-tete
              TableRow(
                decoration: BoxDecoration(
                  color: EskoliaTokens.violet.withValues(alpha: 0.2),
                ),
                children: const [
                  _TableHeader('Modele'),
                  _TableHeader('RAM'),
                  _TableHeader('Qualite'),
                ],
              ),
              // Lignes de donnees
              for (int i = 0; i < _models.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.025),
                  ),
                  children: [
                    _TableCell(
                      _models[i].name,
                      mono: true,
                      highlight: i == 0,
                    ),
                    _TableCell(_models[i].ram),
                    _TableCell(
                      '${_models[i].quality} ${_stars(_models[i].stars)}',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {this.mono = false, this.highlight = false});
  final String text;
  final bool mono;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Text(
        text,
        style: TextStyle(
          color: highlight ? EskoliaTokens.amber : EskoliaTokens.textSecondary.withValues(alpha: 0.85),
          fontSize: 12,
          fontFamily: mono ? 'monospace' : null,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Problemes frequents ───────────────────────────────────────────────────────

class _TroubleshootSection extends StatelessWidget {
  const _TroubleshootSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('PROBLEMES FREQUENTS'),
        const SizedBox(height: 12),
        _TroubleshootItem(
          question: '"Ollama non detecte"',
          answer: 'Ollama n\'est pas lance. Sur Windows/macOS cherchez l\'icone '
              'Ollama dans la barre des taches (pres de l\'heure). '
              'Si elle est absente, lancez Ollama via le menu Demarrer '
              'ou avec la commande :',
          command: 'ollama serve',
        ),
        const SizedBox(height: 8),
        _TroubleshootItem(
          question: 'Erreur CORS (Windows)',
          answer: 'Le navigateur bloque la requete vers Ollama. '
              'Quittez Ollama (icone systray > Quitter), '
              'ajoutez la variable d\'environnement systeme, '
              'puis relancez Ollama.',
          command: 'setx OLLAMA_ORIGINS "*"',
          commandNote: 'Dans PowerShell, puis relancez Ollama depuis le menu Demarrer.',
        ),
        const SizedBox(height: 8),
        _TroubleshootItem(
          question: 'Generation lente',
          answer: 'Votre PC utilise le CPU au lieu du GPU. '
              'Normal sans carte graphique dediee — comptez 1 a 3 min par generation.',
        ),
        const SizedBox(height: 8),
        _TroubleshootItem(
          question: '"model not found"',
          answer: 'Le modele n\'est pas encore telecharge. Relancez :',
          command: 'ollama pull gemma3',
        ),
      ],
    );
  }
}

class _TroubleshootItem extends StatelessWidget {
  const _TroubleshootItem({
    required this.question,
    required this.answer,
    this.command,
    this.commandNote,
  });
  final String question;
  final String answer;
  final String? command;
  final String? commandNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❓', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  answer,
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                if (command != null) ...[
                  const SizedBox(height: 8),
                  _TerminalBlock(command: command!),
                  if (commandNote != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      commandNote!,
                      style: TextStyle(
                        color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '→ ',
            style: TextStyle(color: EskoliaTokens.violet.withValues(alpha: 0.8), fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
