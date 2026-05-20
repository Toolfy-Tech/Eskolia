import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../data/ai_key_repository.dart';
import '../data/ollama_service.dart';
import 'ollama_install_guide_sheet.dart';

// ── Couleurs locales ─────────────────────────────────────────────────────────

const Color _slate  = Color(0xFF94A3B8);
const Color _amber  = Color(0xFFFFC107);
const Color _violet = Color(0xFF6C63FF);
const Color _green  = Color(0xFF4CAF50);
const Color _red    = Color(0xFFE53935);

// ── Modeles disponibles ───────────────────────────────────────────────────────

const _kAvailableModels = <String>[
  'gemma3',
  'gemma3:12b',
  'llama3.3',
  'mistral',
  'qwen2.5',
];

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
  final _urlController   = TextEditingController(text: 'http://localhost:11434');
  final _modelController = TextEditingController(text: 'gemma3');

  bool    _testing   = false;
  String? _status;
  bool    _statusOk  = false;

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
    if (model != null && model.isNotEmpty && _kAvailableModels.contains(model)) {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ollama_url',   _urlController.text.trim());
      await prefs.setString('ollama_model', _modelController.text.trim());

      await AiKeyRepository().saveOllama(
        url:   _urlController.text.trim(),
        model: _modelController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _testing   = false;
        _status    = 'Ollama connecte — ${status.models.length} modele(s) disponible(s)';
        _statusOk  = true;
      });

      widget.onConnected();
    } else {
      setState(() {
        _testing   = false;
        _status    = 'Ollama non detecte — verifiez qu\'Ollama est lance';
        _statusOk  = false;
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
      accentBorderColor: _amber,
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
                  'Ollama + Gemma 3',
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
                    color: _green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'CONNECTE',
                    style: TextStyle(
                      color: _green,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Badge ILLIMITE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: _amber.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'ILLIMITE',
                  style: TextStyle(
                    color: _amber,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Sous-titre
          Text(
            'gemma3 · Tourne sur votre PC',
            style: TextStyle(
              color: _slate.withValues(alpha: 0.7),
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
          // Avertissement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: _amber, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Necessite l\'installation d\'Ollama (~5 min)',
                  style: TextStyle(
                    color: _amber.withValues(alpha: 0.85),
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
              color: _slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          EskoliaTextField(
            controller: _urlController,
            hintText: 'http://localhost:11434',
          ),
          const SizedBox(height: 8),
          // ── Dropdown modele ────────────────────────────────────────────────
          Text(
            'Modele',
            style: TextStyle(
              color: _slate,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          _ModelDropdown(controller: _modelController),
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
                    foregroundColor: _amber,
                    side: BorderSide(color: _amber.withValues(alpha: 0.6)),
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
                            color: _amber,
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
                    foregroundColor: _violet,
                    side: BorderSide(color: _violet.withValues(alpha: 0.6)),
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
          const Icon(Icons.check_rounded, color: _amber, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _slate.withValues(alpha: 0.85),
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

/// Barres de qualite inline (equivalent de _QualityBar prive dans ai_setup_screen).
class _QualityDots extends StatelessWidget {
  const _QualityDots({required this.label, required this.score});
  final String label;
  final int score;

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFC107),
    Color(0xFF66BB6A),
    Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    final dotColor = score >= 1 ? _colors[score.clamp(1, 5) - 1] : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 10),
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
    final color = ok ? _green : _red;
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

class _ModelDropdown extends StatefulWidget {
  const _ModelDropdown({required this.controller});
  final TextEditingController controller;

  @override
  State<_ModelDropdown> createState() => _ModelDropdownState();
}

class _ModelDropdownState extends State<_ModelDropdown> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.controller.text;
    _selected = _kAvailableModels.contains(initial)
        ? initial
        : _kAvailableModels.first;
    widget.controller.text = _selected;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selected,
      dropdownColor: const Color(0xFF1E1E38),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _slate.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _violet.withValues(alpha: 0.7)),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
      ),
      items: _kAvailableModels.map((m) {
        return DropdownMenuItem<String>(
          value: m,
          child: Text(
            m,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
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
