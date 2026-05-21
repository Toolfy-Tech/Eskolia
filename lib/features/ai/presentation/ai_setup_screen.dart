import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../data/ai_key_repository.dart';
import '../data/ai_chat_service.dart';
import '../data/ai_provider.dart';
import 'gemini_model_selector.dart';
import 'ollama_setup_card.dart';

const Color _bg     = EskoliaVisual.bgDeep;
const Color _slate  = Color(0xFF94A3B8);
const Color _green  = Color(0xFF4CAF50);
const Color _violet = Color(0xFF6C63FF);
const Color _cyan   = Color(0xFF00BCD4);
const Color _amber  = Color(0xFFFFC107);
const Color _red    = Color(0xFFE53935);

// ── Données tier list ────────────────────────────────────────────────────────

class _ProviderInfo {
  const _ProviderInfo({
    required this.provider,
    required this.tier,
    required this.tierLabel,
    required this.tierColor,
    required this.price,
    required this.priceBadge,
    required this.priceBadgeColor,
    required this.qualityCours,
    required this.qualityQuiz,
    required this.pros,
    required this.warning,
  });

  final AiProvider provider;
  final int tier;               // 1 = meilleur
  final String tierLabel;
  final Color tierColor;
  final String price;           // description courte
  final String priceBadge;      // GRATUIT / ~0,001€ / etc.
  final Color priceBadgeColor;
  final int qualityCours;       // /5
  final int qualityQuiz;        // /5
  final List<String> pros;
  final String? warning;
}

const _providers = <_ProviderInfo>[
  _ProviderInfo(
    provider: AiProvider.groq,
    tier: 1,
    tierLabel: 'GRATUIT',
    tierColor: _green,
    price: '100 % gratuit — aucune CB requise',
    priceBadge: 'GRATUIT',
    priceBadgeColor: _green,
    qualityCours: 3,
    qualityQuiz: 3,
    pros: [
      'Zero inscription bancaire — parfait pour les eleves',
      'Ultra-rapide (streaming quasi instantane)',
      '14 400 requetes gratuites par jour',
    ],
    warning: 'Llama 3.3 suit bien les schemas simples mais peut produire des questions moins variees '
        '(favorise "classic" plutot que "sequence" ou "diagnostic"). '
        'Ideal pour un usage quotidien ; deconseille pour des cours tres techniques ou pointus.',
  ),
  _ProviderInfo(
    provider: AiProvider.gemini,
    tier: 1,
    tierLabel: 'GRATUIT',
    tierColor: _green,
    price: '15 req/min gratuites — Google AI Studio',
    priceBadge: 'GRATUIT',
    priceBadgeColor: _green,
    qualityCours: 4,
    qualityQuiz: 4,
    pros: [
      'Tier gratuit genereux (1 million tokens/jour)',
      'Tres bonne qualite redactionnelle pour les cours',
      'JSON mode natif — schemas tres bien respectes',
    ],
    warning: 'Necessite un compte Google et un acces a Google AI Studio. '
        'La limite de 15 requetes/minute est invisible en usage normal. '
        'Gemini peut parfois etre prolixe dans ses explications — les hints seront longs.',
  ),
  _ProviderInfo(
    provider: AiProvider.anthropic,
    tier: 2,
    tierLabel: 'PREMIUM',
    tierColor: Color(0xFFB57BFF),
    price: 'Payant — credits a partir de 5 USD',
    priceBadge: '~0,001 EUR/quiz',
    priceBadgeColor: Color(0xFFB57BFF),
    qualityCours: 5,
    qualityQuiz: 5,
    pros: [
      'Meilleure qualite pedagogique parmi tous les providers',
      'Excellente diversite de types (sequence, diagnostic, ticket)',
      'Hints tres explicatifs et adaptes au niveau IT',
    ],
    warning: null,
  ),
  _ProviderInfo(
    provider: AiProvider.openai,
    tier: 2,
    tierLabel: 'PREMIUM',
    tierColor: Color(0xFFB57BFF),
    price: 'Payant — credits a partir de 5 USD',
    priceBadge: '~0,001 EUR/quiz',
    priceBadgeColor: Color(0xFFB57BFF),
    qualityCours: 5,
    qualityQuiz: 5,
    pros: [
      'GPT-4o-mini tres stable et fiable',
      'JSON mode officiel — aucun JSON malformed',
      'Tres bon equilibre vitesse / qualite',
    ],
    warning: null,
  ),
  _ProviderInfo(
    provider: AiProvider.mistral,
    tier: 3,
    tierLabel: 'ALTERNATIF',
    tierColor: _cyan,
    price: 'Tier gratuit beta disponible',
    priceBadge: 'BETA GRATUIT',
    priceBadgeColor: _cyan,
    qualityCours: 3,
    qualityQuiz: 3,
    pros: [
      'Modele europeen — conformite RGPD native',
      'Open source et transparent',
      'Tier gratuit disponible (quota limite)',
    ],
    warning: 'Mistral Small peut manquer de rigueur sur les schemas JSON complexes. '
        'Si tu obtiens des erreurs "JSON invalide", regenere le quiz. '
        'Le tier gratuit est en beta et peut etre retire.',
  ),
  _ProviderInfo(
    provider: AiProvider.perplexity,
    tier: 3,
    tierLabel: 'ALTERNATIF',
    tierColor: _cyan,
    price: 'Abonnement ~20 USD/mois ou credits',
    priceBadge: '~20 EUR/mois',
    priceBadgeColor: _amber,
    qualityCours: 3,
    qualityQuiz: 2,
    pros: [
      'Acces internet en temps reel — actu tech recente',
      'Utile pour les quiz sur des sujets d\'actualite',
      'Bonne comprehension du contexte IT',
    ],
    warning: 'Perplexity est optimise pour la recherche web, pas pour la generation de schemas JSON stricts. '
        'Les quiz generes peuvent etre moins bien structures. '
        'Recommande uniquement si tu veux des questions sur des sujets tres recents.',
  ),
  _ProviderInfo(
    provider: AiProvider.xai,
    tier: 3,
    tierLabel: 'ALTERNATIF',
    tierColor: _cyan,
    price: 'Credits necessaires — API payante',
    priceBadge: 'PAYANT',
    priceBadgeColor: _amber,
    qualityCours: 2,
    qualityQuiz: 2,
    pros: [
      'Modele Grok en developpement actif',
      'Bonne comprehension du langage naturel',
    ],
    warning: 'xAI Grok est encore en developpement et peut produire des resultats imprevus. '
        'Non recommande pour la generation de cours et quiz — privilegie Anthropic, OpenAI ou Gemini.',
  ),
];

// ── Ecran principal ──────────────────────────────────────────────────────────

class AiSetupScreen extends StatefulWidget {
  const AiSetupScreen({super.key});

  @override
  State<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends State<AiSetupScreen> {
  final _repo          = AiKeyRepository();
  final _service       = AiChatService();
  final _keyController = TextEditingController();

  bool _loading        = true;
  bool _testing        = false;
  bool _obscure        = true;
  bool _privacyConsent = false;
  String _geminiModel  = 'gemini-2.5-flash';
  AiConnectionState _state    = const AiConnectionState(isConnected: false);
  AiProvider        _detected = AiProvider.unknown;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s     = await _repo.load();
    final model = await _repo.loadGeminiModel();
    if (mounted) {
      setState(() {
        _state        = s;
        _loading      = false;
        _geminiModel  = model;
        // Ne pas copier le sentinel 'ollama' dans le champ cle API.
        if (s.isConnected && s.apiKey != null && !s.provider.isLocal) {
          _keyController.text = s.apiKey!;
          _detected = s.provider;
        }
      });
    }
  }

  void _onKeyChanged(String value) {
    final detected = AiProvider.detectFromKey(value);
    if (detected != _detected) {
      setState(() {
        _detected = detected;
        _privacyConsent = false;
      });
    }
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    if (_detected == AiProvider.unknown) {
      if (!mounted) return;
      showEskoliaSnackBar(context, 'Provider non reconnu — verifie ta cle.');
      return;
    }
    setState(() => _testing = true);
    final error = await _service.testKey(key, _detected);
    if (!mounted) return;
    if (error != null) {
      setState(() => _testing = false);
      showEskoliaSnackBar(context, error);
      return;
    }
    await _repo.save(key);
    if (_detected == AiProvider.gemini) {
      await _repo.saveGeminiModel(_geminiModel);
    }
    if (!mounted) return;
    setState(() {
      _testing = false;
      _state   = AiConnectionState(isConnected: true, apiKey: key, provider: _detected);
    });
    showEskoliaSnackBar(context, '${_detected.emoji} ${_detected.displayName} connecte !');
  }

  Future<void> _disconnect() async {
    await _repo.delete();
    if (!mounted) return;
    _keyController.clear();
    setState(() {
      _state    = const AiConnectionState(isConnected: false);
      _detected = AiProvider.unknown;
    });
    showEskoliaSnackBar(context, 'IA deconnectee.');
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH, 16,
                EskoliaLayout.screenPaddingH, 60,
              ),
              children: [
                _buildStatusBanner(),
                // Sélecteur de modèle Gemini — visible dès que Gemini est actif
                // (clé sauvegardée ou en cours de saisie).
                Builder(builder: (_) {
                  final connectedGemini =
                      _state.isConnected && _state.provider == AiProvider.gemini;
                  final typingGemini = _detected == AiProvider.gemini &&
                      _keyController.text.trim().length >= 10;
                  if (!connectedGemini && !typingGemini) return const SizedBox.shrink();
                  final apiKey = connectedGemini
                      ? (_state.apiKey ?? _keyController.text.trim())
                      : _keyController.text.trim();
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      GeminiModelSelector(
                        key: ValueKey(apiKey),
                        apiKey: apiKey,
                        initialModel: _geminiModel,
                        onChanged: (m) => setState(() => _geminiModel = m),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                _buildKeyInput(),
                const SizedBox(height: 14),
                if (_detected != AiProvider.unknown && !_detected.isLocal) ...[
                  const SizedBox(height: 14),
                  _buildConsentCheckbox(),
                  const SizedBox(height: 10),
                ],
                _buildSaveButton(),
                if (_state.isConnected) ...[
                  const SizedBox(height: 10),
                  _buildDisconnectButton(),
                ],
                // Avertissement contextuel (cloud providers uniquement)
                if (_detected != AiProvider.unknown && !_detected.isLocal) ...[
                  const SizedBox(height: 14),
                  _buildWarningCard(_detected),
                ],
                const SizedBox(height: 32),
                _buildTierList(),
                const SizedBox(height: 32),
                _buildHowToSection(),
              ],
            ),
    );
  }

  // ── Banner statut ──────────────────────────────────────────────────────────

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
              const Text('IA connectee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text(_state.provider.displayName, style: TextStyle(color: _slate, fontSize: 12)),
            ]),
          ),
          Text(_state.provider.emoji, style: const TextStyle(fontSize: 22)),
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
            const Text('Aucune IA connectee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Entre ta cle API ci-dessous', style: TextStyle(color: _slate, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  // ── Saisie de la cle ───────────────────────────────────────────────────────

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
        EskoliaTextField(
          controller: _keyController,
          hintText: 'sk-ant-... / sk-... / AIza... / gsk_...',
          obscureText: _obscure,
          onChanged: _onKeyChanged,
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: _slate, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        if (_detected != AiProvider.unknown) ...[
          const SizedBox(height: 6),
          Text('Provider detecte automatiquement', style: TextStyle(color: _green.withValues(alpha: 0.85), fontSize: 11)),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    final needsConsent = _detected != AiProvider.unknown &&
        !_detected.isLocal &&
        !_privacyConsent;
    return EskoliaButton(
      label: _testing ? 'Test en cours...' : (_state.isConnected ? 'Mettre a jour' : 'Connecter mon IA'),
      icon: _testing ? Icons.hourglass_empty_rounded : Icons.bolt_rounded,
      variant: EskoliaButtonVariant.primary,
      expand: true,
      onPressed: (_testing || needsConsent) ? null : _save,
    );
  }

  Widget _buildDisconnectButton() => EskoliaButton(
    label: 'Deconnecter',
    icon: Icons.link_off_rounded,
    variant: EskoliaButtonVariant.secondary,
    expand: true,
    onPressed: _disconnect,
  );

  // ── Consentement confidentialite ───────────────────────────────────────────

  Widget _buildConsentCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _privacyConsent,
            onChanged: (v) => setState(() => _privacyConsent = v ?? false),
            activeColor: _violet,
            side: BorderSide(color: _slate.withValues(alpha: 0.4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _privacyConsent = !_privacyConsent),
              child: Text(
                'J\'ai compris qu\'en utilisant une cle API Cloud, mes requetes peuvent etre analysees par le fournisseur. '
                'Je m\'engage a ne partager aucune donnee personnelle.',
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.85),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avertissement contextuel ───────────────────────────────────────────────

  Widget _buildWarningCard(AiProvider provider) {
    final info = _providers.firstWhere((p) => p.provider == provider, orElse: () => _providers.first);
    final hasWarning = info.warning != null;
    final borderColor = hasWarning ? _amber : _green;
    final icon = hasWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    final title = hasWarning ? 'A savoir pour ${provider.displayName}' : '${provider.displayName} — Bon choix !';
    final body = hasWarning
        ? info.warning!
        : 'Ce provider offre une excellente qualite pour la generation de cours et quiz dans Eskolia.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: borderColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: TextStyle(color: borderColor, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12, height: 1.5)),
          const SizedBox(height: 10),
          // Barres de qualite
          Row(children: [
            _QualityBar(label: 'Cours', score: info.qualityCours),
            const SizedBox(width: 16),
            _QualityBar(label: 'Quiz', score: info.qualityQuiz),
          ]),
        ],
      ),
    );
  }

  // ── Tier list ──────────────────────────────────────────────────────────────

  Widget _buildTierList() {
    final tiers = <int>{for (final p in _providers) p.tier};
    final tierTitles = {
      1: ('GRATUIT — Recommande pour commencer', _green),
      2: ('PREMIUM — Meilleure qualite pedagogique', Color(0xFFB57BFF)),
      3: ('ALTERNATIF — Usages specifiques', _cyan),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOISIR SON IA',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          'Comparatif des providers supportes — qualite evaluee sur la generation de cours et quiz IT.',
          style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        // Section LOCAL
        _TierHeader(label: 'LOCAL — GRATUIT & ILLIMITE', color: _amber),
        const SizedBox(height: 8),
        OllamaSetupCard(
          isConnected: _state.isConnected && _state.provider == AiProvider.ollama,
          onConnected: () async {
            final s = await _repo.load();
            if (mounted) setState(() => _state = s);
          },
        ),
        const SizedBox(height: 12),
        for (final tier in tiers.toList()..sort()) ...[
          _TierHeader(
            label: tierTitles[tier]!.$1,
            color: tierTitles[tier]!.$2,
          ),
          const SizedBox(height: 8),
          for (final info in _providers.where((p) => p.tier == tier))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProviderCard(
                info: info,
                isConnected: _state.isConnected && _state.provider == info.provider,
                onOpenUrl: () => _openUrl(info.provider.apiKeyUrl),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  // ── Comment obtenir sa cle ─────────────────────────────────────────────────

  Widget _buildHowToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMMENT OBTENIR SA CLE API',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          'Clique sur le lien de ton provider, cree un compte, puis copie-colle ta cle dans le champ ci-dessus. '
          'Eskolia detecte automatiquement le provider.',
          style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        _HowToStep(num: '1', text: 'Choisis un provider dans la liste ci-dessus (Groq ou Gemini si tu veux gratuit)'),
        _HowToStep(num: '2', text: 'Clique sur le bouton lien pour acceder a la console du provider'),
        _HowToStep(num: '3', text: 'Cree un compte si necessaire, puis genere une cle API'),
        _HowToStep(num: '4', text: 'Copie la cle (commence par sk-ant-, gsk_, AIza...) et colle-la dans le champ en haut'),
        _HowToStep(num: '5', text: 'Clique sur "Connecter" — Eskolia teste la cle automatiquement'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _violet.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: _violet, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ta cle est stockee uniquement dans ton profil Firestore — jamais en clair cote serveur Eskolia. '
                  'Elle est utilisee uniquement pour les requetes IA que tu declenches.',
                  style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Widgets secondaires ──────────────────────────────────────────────────────

class _TierHeader extends StatelessWidget {
  const _TierHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
    ]);
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.info,
    required this.isConnected,
    required this.onOpenUrl,
  });

  final _ProviderInfo info;
  final bool isConnected;
  final VoidCallback onOpenUrl;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      accentBorderColor: isConnected ? _green : info.tierColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(info.provider.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(
                    info.provider.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  if (isConnected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('CONNECTE', style: TextStyle(color: _green, fontSize: 8, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  info.provider.defaultModel,
                  style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 10, fontFamily: 'monospace'),
                ),
              ]),
            ),
            // Badge prix
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: info.priceBadgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: info.priceBadgeColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                info.priceBadge,
                style: TextStyle(color: info.priceBadgeColor, fontSize: 9, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onOpenUrl,
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: _violet),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              tooltip: 'Obtenir la cle',
            ),
          ]),
          const SizedBox(height: 10),
          // Barres qualite
          Row(children: [
            _QualityBar(label: 'Cours', score: info.qualityCours),
            const SizedBox(width: 16),
            _QualityBar(label: 'Quiz', score: info.qualityQuiz),
          ]),
          const SizedBox(height: 10),
          // Pros
          ...info.pros.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_rounded, color: info.tierColor, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(p, style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 11, height: 1.4)),
                ),
              ]),
            ),
          ),
          if (info.warning != null) ...[
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, color: _amber, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  info.warning!,
                  style: TextStyle(color: _amber.withValues(alpha: 0.8), fontSize: 11, height: 1.4),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _QualityBar extends StatelessWidget {
  const _QualityBar({required this.label, required this.score});
  final String label;
  final int score; // /5

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFF7043),
    Color(0xFFFFC107),
    Color(0xFF66BB6A),
    Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 10)),
      const SizedBox(width: 6),
      Row(
        children: List.generate(5, (i) {
          final filled = i < score;
          return Container(
            width: 12,
            height: 5,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: filled ? _colors[score - 1] : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    ]);
  }
}

class _HowToStep extends StatelessWidget {
  const _HowToStep({required this.num, required this.text});
  final String num;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: _violet.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num, style: const TextStyle(color: _violet, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text, style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12, height: 1.4)),
          ),
        ),
      ]),
    );
  }
}
