import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
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
const Color _purple = Color(0xFFB57BFF);

// ── Données providers ─────────────────────────────────────────────────────────

class _TutorialStep {
  const _TutorialStep(this.text, {this.linkLabel, this.linkUrl});
  final String text;
  final String? linkLabel;
  final String? linkUrl;
}

class _AiProviderData {
  const _AiProviderData({
    required this.provider,
    required this.section,
    required this.priceBadge,
    required this.priceBadgeColor,
    required this.tagline,
    required this.qualityCours,
    required this.qualityQuiz,
    required this.pros,
    required this.steps,
    this.warning,
    this.isRecommended = false,
  });

  final AiProvider provider;
  final String section;        // 'free' | 'local' | 'paid'
  final String priceBadge;
  final Color priceBadgeColor;
  final String tagline;
  final int qualityCours;
  final int qualityQuiz;
  final List<String> pros;
  final List<_TutorialStep> steps;
  final String? warning;
  final bool isRecommended;
}

const _providerData = <_AiProviderData>[
  // ── GRATUIT ───────────────────────────────────────────────────────────────
  _AiProviderData(
    provider: AiProvider.gemini,
    section: 'free',
    priceBadge: 'GRATUIT',
    priceBadgeColor: _green,
    tagline: '1 million tokens/jour — Recommande Eskolia',
    qualityCours: 4,
    qualityQuiz: 4,
    isRecommended: true,
    pros: [
      'Tier gratuit genereux : 1M tokens/jour, 15 req/min',
      'Excellente qualite redactionnelle pour les cours IT',
      'JSON mode natif — schemas respectes avec precision',
      'Selecteur de modele integre (Flash, Pro, Lite)',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur Google AI Studio (compte Google suffit)',
        linkLabel: 'aistudio.google.com',
        linkUrl: 'https://aistudio.google.com',
      ),
      _TutorialStep('Connecte-toi avec ton compte Google — c\'est entierement gratuit'),
      _TutorialStep('Clique sur "Get API key" dans le menu de gauche'),
      _TutorialStep('Clique sur "Create API key in new project" — copie la cle (commence par AIza...)'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus — Eskolia detecte Gemini automatiquement'),
      _TutorialStep('Choisis ton modele dans le selecteur qui apparait, puis clique "Connecter"'),
    ],
    warning: 'La limite de 15 req/min est invisible en usage normal. '
        'Gemini peut etre prolixe — les hints seront parfois longs.',
  ),
  _AiProviderData(
    provider: AiProvider.groq,
    section: 'free',
    priceBadge: 'GRATUIT',
    priceBadgeColor: _green,
    tagline: '14 400 requetes gratuites par jour — ultra-rapide',
    qualityCours: 3,
    qualityQuiz: 3,
    pros: [
      'Zero inscription bancaire — aucune CB requise',
      'Streaming quasi instantane (GPU cloud Groq)',
      'Quota tres genereux pour un usage quotidien',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur la console Groq',
        linkLabel: 'console.groq.com',
        linkUrl: 'https://console.groq.com',
      ),
      _TutorialStep('Cree un compte gratuit — email + mot de passe, sans CB'),
      _TutorialStep('Dans le menu de gauche, clique sur "API Keys"'),
      _TutorialStep('Clique "Create API key", donne-lui un nom (ex: Eskolia)'),
      _TutorialStep('Copie la cle generee (commence par gsk_...)'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus et clique "Connecter"'),
    ],
    warning: 'Llama 3.3 suit bien les schemas simples mais favorise les questions "classic". '
        'Les types complexes (sequence, diagnostic) peuvent etre moins bien structures.',
  ),
  _AiProviderData(
    provider: AiProvider.mistral,
    section: 'free',
    priceBadge: 'BETA GRATUIT',
    priceBadgeColor: _cyan,
    tagline: 'Modele europeen open source — RGPD natif',
    qualityCours: 3,
    qualityQuiz: 3,
    pros: [
      'Modele europeen — conformite RGPD native',
      'Open source et transparent',
      'Tier gratuit disponible (quota limite en beta)',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur la console Mistral',
        linkLabel: 'console.mistral.ai',
        linkUrl: 'https://console.mistral.ai',
      ),
      _TutorialStep('Cree un compte gratuit'),
      _TutorialStep('Dans le menu, clique sur "API Keys"'),
      _TutorialStep('Clique "Create new key" et copie la cle generee'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus et clique "Connecter"'),
    ],
    warning: 'Mistral Small peut manquer de rigueur sur les schemas JSON complexes. '
        'Le tier gratuit est en beta et peut etre retire a tout moment.',
  ),
  // ── LOCAL ─────────────────────────────────────────────────────────────────
  _AiProviderData(
    provider: AiProvider.ollama,
    section: 'local',
    priceBadge: 'GRATUIT',
    priceBadgeColor: _amber,
    tagline: 'Modeles locaux sur ton PC — 100% prive, illimite',
    qualityCours: 3,
    qualityQuiz: 3,
    pros: [
      'Aucune donnee ne quitte ton ordinateur',
      'Illimite — pas de quota, pas de facture',
      'Compatible Llama 3, Mistral, Gemma, Phi...',
    ],
    steps: [
      _TutorialStep(
        'Installe Ollama sur ton PC (Mac, Windows, Linux)',
        linkLabel: 'ollama.com',
        linkUrl: 'https://ollama.com',
      ),
      _TutorialStep('Lance Ollama — une icone apparait dans la barre des taches'),
      _TutorialStep('Dans un terminal, tape : ollama pull gemma3'),
      _TutorialStep('Configure l\'URL et le modele ci-dessous, puis clique "Connecter"'),
    ],
    warning: null,
  ),
  // ── PAYANT ────────────────────────────────────────────────────────────────
  _AiProviderData(
    provider: AiProvider.anthropic,
    section: 'paid',
    priceBadge: '~0,001 EUR/quiz',
    priceBadgeColor: _purple,
    tagline: 'Meilleure qualite pedagogique — Claude Sonnet',
    qualityCours: 5,
    qualityQuiz: 5,
    pros: [
      'Meilleure qualite pedagogique parmi tous les providers',
      'Excellente diversite de types (sequence, diagnostic, ticket)',
      'Hints tres explicatifs et adaptes au niveau IT',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur la console Anthropic',
        linkLabel: 'console.anthropic.com',
        linkUrl: 'https://console.anthropic.com',
      ),
      _TutorialStep('Cree un compte et ajoute du credit dans "Billing" (minimum 5 USD)'),
      _TutorialStep('Va dans "API Keys" et clique "Create Key"'),
      _TutorialStep('Copie la cle (commence par sk-ant-...)'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus et clique "Connecter"'),
    ],
    warning: null,
  ),
  _AiProviderData(
    provider: AiProvider.openai,
    section: 'paid',
    priceBadge: '~0,001 EUR/quiz',
    priceBadgeColor: _purple,
    tagline: 'GPT-4o-mini — fiable, JSON mode officiel',
    qualityCours: 5,
    qualityQuiz: 5,
    pros: [
      'GPT-4o-mini tres stable et fiable',
      'JSON mode officiel — aucun JSON malformed',
      'Tres bon equilibre vitesse / qualite',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur la plateforme OpenAI',
        linkLabel: 'platform.openai.com',
        linkUrl: 'https://platform.openai.com',
      ),
      _TutorialStep('Cree un compte et ajoute du credit dans "Settings > Billing"'),
      _TutorialStep('Va dans "API keys" et clique "Create new secret key"'),
      _TutorialStep('Copie la cle (commence par sk-...)'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus et clique "Connecter"'),
    ],
    warning: null,
  ),
  _AiProviderData(
    provider: AiProvider.perplexity,
    section: 'paid',
    priceBadge: '~20 EUR/mois',
    priceBadgeColor: _amber,
    tagline: 'Acces internet temps reel — sujets tech recents',
    qualityCours: 3,
    qualityQuiz: 2,
    pros: [
      'Acces internet en temps reel — tech recente',
      'Utile pour des quiz sur des sujets d\'actualite',
      'Bonne comprehension du contexte IT',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur Perplexity',
        linkLabel: 'perplexity.ai',
        linkUrl: 'https://www.perplexity.ai',
      ),
      _TutorialStep('Cree un compte et souscris a un abonnement Pro (~20 USD/mois)'),
      _TutorialStep('Va dans Settings > API et clique "Generate"'),
      _TutorialStep('Copie ta cle API et colle-la dans le champ "Cle API" ci-dessus'),
    ],
    warning: 'Optimise pour la recherche web, pas pour la generation de schemas JSON stricts. '
        'Recommande uniquement pour des questions sur des sujets tres recents.',
  ),
  _AiProviderData(
    provider: AiProvider.xai,
    section: 'paid',
    priceBadge: 'PAYANT',
    priceBadgeColor: _amber,
    tagline: 'Grok — modele xAI en developpement actif',
    qualityCours: 2,
    qualityQuiz: 2,
    pros: [
      'Modele Grok en developpement actif',
      'Bonne comprehension du langage naturel',
    ],
    steps: [
      _TutorialStep(
        'Rends-toi sur la console xAI',
        linkLabel: 'console.x.ai',
        linkUrl: 'https://console.x.ai',
      ),
      _TutorialStep('Cree un compte et ajoute du credit'),
      _TutorialStep('Genere ta cle API dans la section "API Keys"'),
      _TutorialStep('Colle-la dans le champ "Cle API" ci-dessus et clique "Connecter"'),
    ],
    warning: 'Grok est encore en developpement — resultats imprevus possibles. '
        'Non recommande pour la generation de cours et quiz : prefere Anthropic, OpenAI ou Gemini.',
  ),
];

// ── Ecran principal ───────────────────────────────────────────────────────────

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
  AiProvider?       _expandedProvider;

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

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: '\u{1F916} Assistant IA'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _violet))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      EskoliaLayout.screenPaddingH, 16,
                      EskoliaLayout.screenPaddingH, 60,
                    ),
                    children: [
                      _buildStatusBanner(),
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
                      const SizedBox(height: 32),
                      _buildProviderSection(),
                    ],
                  ),
          ),
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

  // ── Section providers ──────────────────────────────────────────────────────

  Widget _buildProviderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHOISIR SON IA',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          'Clique sur un provider pour voir le tuto et obtenir ta cle API gratuitement ou avec abonnement.',
          style: TextStyle(color: _slate.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        _TierHeader(label: 'GRATUIT — Recommande pour commencer', color: _green),
        const SizedBox(height: 8),
        for (final data in _providerData.where((d) => d.section == 'free'))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AiAccordionCard(
              data: data,
              isExpanded: _expandedProvider == data.provider,
              isConnected: _state.isConnected && _state.provider == data.provider,
              onTap: () => setState(() {
                _expandedProvider =
                    _expandedProvider == data.provider ? null : data.provider;
              }),
            ),
          ),
        const SizedBox(height: 12),
        _TierHeader(label: 'LOCAL — GRATUIT & ILLIMITE', color: _amber),
        const SizedBox(height: 8),
        for (final data in _providerData.where((d) => d.section == 'local'))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AiAccordionCard(
              data: data,
              isExpanded: _expandedProvider == data.provider,
              isConnected: _state.isConnected && _state.provider == data.provider,
              onTap: () => setState(() {
                _expandedProvider =
                    _expandedProvider == data.provider ? null : data.provider;
              }),
              extraContent: data.provider == AiProvider.ollama
                  ? OllamaSetupCard(
                      isConnected: _state.isConnected && _state.provider == AiProvider.ollama,
                      onConnected: () async {
                        final s = await _repo.load();
                        if (mounted) setState(() => _state = s);
                      },
                    )
                  : null,
            ),
          ),
        const SizedBox(height: 12),
        _TierHeader(label: 'PAYANT — Meilleure qualite pedagogique', color: _purple),
        const SizedBox(height: 8),
        for (final data in _providerData.where((d) => d.section == 'paid'))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AiAccordionCard(
              data: data,
              isExpanded: _expandedProvider == data.provider,
              isConnected: _state.isConnected && _state.provider == data.provider,
              onTap: () => setState(() {
                _expandedProvider =
                    _expandedProvider == data.provider ? null : data.provider;
              }),
            ),
          ),
        const SizedBox(height: 24),
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

// ── Widgets secondaires ───────────────────────────────────────────────────────

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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w800)),
    );
  }
}

class _AiAccordionCard extends StatelessWidget {
  const _AiAccordionCard({
    required this.data,
    required this.isExpanded,
    required this.isConnected,
    required this.onTap,
    this.extraContent,
  });

  final _AiProviderData data;
  final bool isExpanded;
  final bool isConnected;
  final VoidCallback onTap;
  final Widget? extraContent;

  Color get _sectionColor => switch (data.section) {
    'free'  => _green,
    'local' => _amber,
    _       => _purple,
  };

  @override
  Widget build(BuildContext context) {
    final accentColor = isConnected
        ? _green
        : (data.isRecommended ? _violet : _sectionColor);

    return EskoliaCardContent(
      accentBorderColor: accentColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(data.provider.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              data.provider.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            if (isConnected) _Chip(label: 'CONNECTE', color: _green),
                            if (data.isRecommended) _Chip(label: 'RECOMMANDE ESKOLIA', color: _violet),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.tagline,
                          style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: data.priceBadgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: data.priceBadgeColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      data.priceBadge,
                      style: TextStyle(
                        color: data.priceBadgeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded, color: _slate.withValues(alpha: 0.7), size: 20),
                  ),
                ],
              ),
            ),
          ),
          // Body expanded
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _QualityBar(label: 'Cours', score: data.qualityCours),
                    const SizedBox(width: 16),
                    _QualityBar(label: 'Quiz', score: data.qualityQuiz),
                  ]),
                  const SizedBox(height: 10),
                  ...data.pros.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.check_rounded, color: _sectionColor, size: 13),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(p, style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 11, height: 1.4)),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.section == 'local' ? 'COMMENT INSTALLER' : 'COMMENT OBTENIR SA CLE',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...data.steps.asMap().entries.map(
                    (e) => _StepRow(num: e.key + 1, step: e.value),
                  ),
                  if (data.warning != null) ...[
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.info_outline_rounded, color: _amber, size: 13),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.warning!,
                          style: TextStyle(color: _amber.withValues(alpha: 0.8), fontSize: 11, height: 1.4),
                        ),
                      ),
                    ]),
                  ],
                  if (extraContent != null) ...[
                    const SizedBox(height: 12),
                    extraContent!,
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.num, required this.step});
  final int num;
  final _TutorialStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: const TextStyle(color: _violet, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.text, style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 11, height: 1.4)),
                  if (step.linkUrl != null) ...[
                    const SizedBox(height: 3),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(step.linkUrl!), mode: LaunchMode.externalApplication),
                      child: Text(
                        step.linkLabel ?? step.linkUrl!,
                        style: TextStyle(
                          color: _violet.withValues(alpha: 0.9),
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                          decorationColor: _violet.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityBar extends StatelessWidget {
  const _QualityBar({required this.label, required this.score});
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
