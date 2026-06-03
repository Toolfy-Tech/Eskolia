import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../data/ai_key_repository.dart';
import '../data/ollama_service.dart';
import 'ollama_install_guide_sheet.dart';

// ── Prefixes preferes pour l'auto-selection du meilleur modele ───────────────

const _kPreferredPrefixes = <String>['gemma3', 'llama3', 'mistral', 'qwen'];

// ── Widget principal ──────────────────────────────────────────────────────────

/// Carte de configuration Ollama a inserer en tete de la tier list
/// dans [AiSetupScreen].
class OllamaSetupCard extends StatefulWidget {
  const OllamaSetupCard({
    super.key,
    required this.isConnected,
    required this.onConnected,
  });

  /// Vrai si une connexion Ollama est deja validee.
  final bool isConnected;

  /// Appele apres un test de connexion reussi.
  final VoidCallback onConnected;

  @override
  State<OllamaSetupCard> createState() => _OllamaSetupCardState();
}

class _OllamaSetupCardState extends State<OllamaSetupCard> {
  final _urlController   = TextEditingController(text: 'http://127.0.0.1:11434');
  final _modelController = TextEditingController(text: 'gemma3');

  bool         _testing         = false;
  String?      _status;
  bool         _statusOk        = false;
  List<String> _installedModels = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final url   = prefs.getString('ollama_url');
    final model = prefs.getString('ollama_model');
    if (!mounted) return;
    if (url != null && url.isNotEmpty) {
      _urlController.text = url;
    }
    if (model != null && model.isNotEmpty) {
      _modelController.text = model;
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _status  = null;
    });

    final status = await OllamaService().checkOllamaConnection(
      _urlController.text.trim(),
    );

    if (!mounted) return;

    if (status.ok) {
      // Noms bruts depuis /api/tags (ex: "gemma3:latest", "llama3.3:70b").
      final rawNames = status.models;

      // Auto-selectionner le meilleur modele selon les prefixes preferes.
      final currentModel = _modelController.text.trim();
      final bestInstalled = rawNames.isEmpty
          ? currentModel
          : rawNames.firstWhere(
              (m) => _kPreferredPrefixes.any((p) => m.startsWith(p)),
              orElse: () => rawNames.first,
            );
      _modelController.text = bestInstalled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ollama_url',   _urlController.text.trim());
      await prefs.setString('ollama_model', bestInstalled);

      await AiKeyRepository().saveOllama(
        url:   _urlController.text.trim(),
        model: bestInstalled,
      );

      if (!mounted) return;

      final suffix = rawNames.isNotEmpty
          ? ' — ${rawNames.length} modele(s) detecte(s)'
          : ' — aucun modele installe (ollama pull gemma3)';

      setState(() {
        _testing         = false;
        _installedModels = rawNames;
        _status          = 'Ollama connecte$suffix';
        _statusOk        = true;
      });

      widget.onConnected();
    } else {
      setState(() {
        _testing  = false;
        _status   = 'Ollama non detecte — verifiez qu\'Ollama est lance';
        _statusOk = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      accentBorderColor: EskoliaTokens.amber,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tete ────────────────────────────────────────────────────────
          Row(
            children: [
              const Text('\u{1F999}', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ollama (Local)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.isConnected) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EskoliaTokens.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'CONNECTE',
                    style: TextStyle(
                      color: EskoliaTokens.success,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: EskoliaTokens.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: EskoliaTokens.amber.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'ILLIMITE',
                  style: TextStyle(
                    color: EskoliaTokens.amber,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'gemma3 · llama3 · mistral — Tourne sur votre PC',
            style: TextStyle(
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // ── Barres qualite ─────────────────────────────────────────────────
          Row(
            children: [
              _QualityDots(label: 'Cours', score: 5),
              const SizedBox(width: 16),
              _QualityDots(label: 'Quiz', score: 5),
            ],
          ),
          const SizedBox(height: 8),
          // ── Avantages ──────────────────────────────────────────────────────
          _ProLine('100% gratuit et illimite'),
          _ProLine('Donnees restent sur votre machine'),
          _ProLine('Fonctionne sans Internet'),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warningEskoliaTokens.amber_rounded, color: EskoliaTokens.amber, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Necessite l\'installation d\'Ollama (~5 min)',
                  style: TextStyle(
                    color: EskoliaTokens.amber.withValues(alpha: 0.85),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Champ URL ──────────────────────────────────────────────────────
          Text(
            'URL Ollama',
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          EskoliaTextField(
            controller: _urlController,
            hintText: 'http://127.0.0.1:11434',
          ),
          const SizedBox(height: 4),
          // Note URLs selon la plateforme
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: EskoliaTokens.textSecondary.withValues(alpha: 0.5), size: 11),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Web/Bureau : 127.0.0.1:11434  |  Emulateur Android : 10.0.2.2:11434',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.55),
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Modele ────────────────────────────────────────────────────────
          Text(
            'Modele',
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          _ModelSelector(
            controller: _modelController,
            installedModels: _installedModels,
          ),
          const SizedBox(height: 12),
          // ── Statut ─────────────────────────────────────────────────────────
          if (_status != null) ...[
            _StatusBanner(message: _status!, ok: _statusOk),
            const SizedBox(height: 8),
          ],
          // ── Boutons ────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _testing ? null : _testConnection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EskoliaTokens.amber,
                    side: BorderSide(color: EskoliaTokens.amber.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _testing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: EskoliaTokens.amber,
                          ),
                        )
                      : const Text(
                          '\u{1F50D} Tester la connexion',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => OllamaInstallGuideSheet.show(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EskoliaTokens.violet,
                    side: BorderSide(color: EskoliaTokens.violet.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '\u{1F4D6} Guide',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sous-widgets ─────────────────────────────────────────────────────────────

class _ProLine extends StatelessWidget {
  const _ProLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: EskoliaTokens.amber, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityDots extends StatelessWidget {
  const _QualityDots({required this.label, required this.score});
  final String label;
  final int score;

  static const _colors = [
    EskoliaTokens.error,
    EskoliaTokens.orange,
    EskoliaTokens.amber,
    EskoliaTokens.success,
    EskoliaTokens.success,
  ];

  @override
  Widget build(BuildContext context) {
    final dotColor = score >= 1 ? _colors[score.clamp(1, 5) - 1] : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 10),
        ),
        const SizedBox(width: 6),
        Row(
          children: List.generate(5, (i) {
            final filled = i < score;
            return Container(
              width: 12,
              height: 5,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: filled ? dotColor : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.ok});
  final String message;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? EskoliaTokens.success : EskoliaTokens.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selecteur de modele : champ texte libre avant connexion, dropdown dynamique apres.
class _ModelSelector extends StatefulWidget {
  const _ModelSelector({
    required this.controller,
    this.installedModels = const [],
  });
  final TextEditingController controller;
  final List<String> installedModels;

  @override
  State<_ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<_ModelSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _syncSelected();
  }

  @override
  void didUpdateWidget(_ModelSelector old) {
    super.didUpdateWidget(old);
    if (old.installedModels != widget.installedModels) {
      setState(_syncSelected);
    }
  }

  void _syncSelected() {
    if (widget.installedModels.isEmpty) {
      _selected = null;
      return;
    }
    final current = widget.controller.text;
    if (widget.installedModels.contains(current)) {
      _selected = current;
    } else {
      _selected = widget.installedModels.first;
      widget.controller.text = _selected!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avant connexion : champ texte libre
    if (widget.installedModels.isEmpty) {
      return EskoliaTextField(
        controller: widget.controller,
        hintText: 'Tester la connexion pour voir les modeles',
      );
    }

    // Apres connexion : dropdown peuple dynamiquement depuis /api/tags
    return DropdownButtonFormField<String>(
      value: _selected,
      dropdownColor: EskoliaTokens.surface2,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EskoliaTokens.textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: EskoliaTokens.violet.withValues(alpha: 0.7)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
      ),
      items: widget.installedModels.map((m) {
        return DropdownMenuItem<String>(
          value: m,
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: EskoliaTokens.success, size: 13),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selected = value);
        widget.controller.text = value;
      },
    );
  }
}
