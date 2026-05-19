import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../data/ai_key_repository.dart';
import '../data/ai_chat_service.dart';
import '../data/ai_provider.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF4CAF50);
const Color _red = Color(0xFFE53935);
const Color _violet = Color(0xFF6C63FF);

class AiSetupScreen extends StatefulWidget {
  const AiSetupScreen({super.key});

  @override
  State<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends State<AiSetupScreen> {
  final _repo = AiKeyRepository();
  final _service = AiChatService();
  final _keyController = TextEditingController();

  bool _loading = true;
  bool _testing = false;
  bool _obscure = true;
  AiConnectionState _state = const AiConnectionState(isConnected: false);
  AiProvider _detected = AiProvider.unknown;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.load();
    if (mounted) {
      setState(() {
        _state = s;
        _loading = false;
        if (s.isConnected && s.apiKey != null) {
          _keyController.text = s.apiKey!;
          _detected = s.provider;
        }
      });
    }
  }

  void _onKeyChanged(String value) {
    final detected = AiProvider.detectFromKey(value);
    if (detected != _detected) setState(() => _detected = detected);
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    if (_detected == AiProvider.unknown) {
      if (!mounted) return;
      showEskoliaSnackBar(context, 'Provider non reconnu — vérifie ta clé.');
      return;
    }
    setState(() => _testing = true);
    final ok = await _service.testKey(key, _detected);
    if (!mounted) return;
    if (!ok) {
      setState(() => _testing = false);
      showEskoliaSnackBar(context, 'Connexion échouée — clé invalide ou quota dépassé.');
      return;
    }
    await _repo.save(key);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _state = AiConnectionState(isConnected: true, apiKey: key, provider: _detected);
    });
    showEskoliaSnackBar(context, '${_detected.emoji} ${_detected.displayName} connecté !');
  }

  Future<void> _disconnect() async {
    await _repo.delete();
    if (!mounted) return;
    _keyController.clear();
    setState(() {
      _state = const AiConnectionState(isConnected: false);
      _detected = AiProvider.unknown;
    });
    showEskoliaSnackBar(context, 'IA déconnectée.');
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: '\u{1F916} Assistant IA'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: _violet))
          else
            ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                16,
                EskoliaLayout.screenPaddingH,
                40,
              ),
              children: [
                _buildStatusBanner(),
                const SizedBox(height: 20),
                _buildKeyInput(),
                const SizedBox(height: 16),
                _buildSaveButton(),
                if (_state.isConnected) ...[
                  const SizedBox(height: 12),
                  _buildDisconnectButton(),
                ],
                const SizedBox(height: 32),
                _buildTutorial(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    if (_state.isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Text('\u{1F7E2}', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('IA connectée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text(_state.provider.displayName, style: TextStyle(color: _slate, fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: 0.5)),
            ),
            child: Text(_state.provider.emoji, style: const TextStyle(fontSize: 16)),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        const Text('\u{26AA}', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Aucune IA connectée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Entre ta clé API ci-dessous', style: TextStyle(color: _slate, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildKeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('CLE API', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(width: 8),
          if (_detected != AiProvider.unknown) ...[
            Text(_detected.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(_detected.displayName, style: TextStyle(color: _violet.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _keyController,
          onChanged: _onKeyChanged,
          obscureText: _obscure,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: 'sk-ant-... / sk-... / AIza... / gsk_...',
            hintStyle: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 12),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: _slate, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _violet.withValues(alpha: 0.7), width: 1.5),
            ),
          ),
        ),
        if (_detected != AiProvider.unknown) ...[
          const SizedBox(height: 6),
          Text(
            'Provider détecté automatiquement',
            style: TextStyle(color: _green.withValues(alpha: 0.85), fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return EskoliaButton(
      label: _testing ? 'Test en cours...' : (_state.isConnected ? 'Mettre a jour' : 'Connecter mon IA'),
      icon: _testing ? Icons.hourglass_empty_rounded : Icons.bolt_rounded,
      variant: EskoliaButtonVariant.primary,
      expand: true,
      onPressed: _testing ? null : _save,
    );
  }

  Widget _buildDisconnectButton() {
    return EskoliaButton(
      label: 'Deconnecter',
      icon: Icons.link_off_rounded,
      variant: EskoliaButtonVariant.secondary,
      expand: true,
      onPressed: _disconnect,
    );
  }

  Widget _buildTutorial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMMENT OBTENIR UNE CLE API',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        Text(
          'Choisis un provider ci-dessous, cree un compte et copie ta cle API dans le champ ci-dessus. '
          'Eskolia detecte automatiquement le provider depuis le format de ta cle.',
          style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        ..._providers.map((p) => _ProviderTutorialCard(
              provider: p,
              onOpenUrl: () => _openUrl(p.apiKeyUrl),
            )),
      ],
    );
  }

  static const List<AiProvider> _providers = [
    AiProvider.groq,
    AiProvider.gemini,
    AiProvider.openai,
    AiProvider.anthropic,
    AiProvider.mistral,
    AiProvider.perplexity,
    AiProvider.xai,
  ];
}

class _ProviderTutorialCard extends StatelessWidget {
  const _ProviderTutorialCard({
    required this.provider,
    required this.onOpenUrl,
  });

  final AiProvider provider;
  final VoidCallback onOpenUrl;

  String get _tip => switch (provider) {
        AiProvider.groq =>
          'Gratuit et ultra-rapide (Llama 3). Parfait pour les eleves — aucune carte bancaire requise.',
        AiProvider.gemini =>
          'Tier gratuit disponible via Google AI Studio. Necessite un compte Google.',
        AiProvider.openai =>
          'GPT-4o-mini. Necessitede mettre des credits (a partir de 5$).',
        AiProvider.anthropic =>
          'Claude Haiku — tres bon rapport qualite/prix. Credits necessaires.',
        AiProvider.mistral =>
          'Modele europeen, open source. Tier gratuit en beta sur la console Mistral.',
        AiProvider.perplexity =>
          'Acces internet en temps reel. Abonnement ou credits necessaires.',
        AiProvider.xai => 'Grok par xAI (Elon Musk). Credits necessaires.',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final isFree = provider.hasFreetier;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFree
                ? const Color(0xFF4CAF50).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(provider.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(
                  provider.displayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                if (isFree) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                    ),
                    child: const Text('GRATUIT', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(_tip, style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 11, height: 1.35)),
            ]),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onOpenUrl,
            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: _violet),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            tooltip: 'Obtenir la cle',
          ),
        ]),
      ),
    );
  }
}
