/// Providers IA supportes — detection automatique par prefixe de cle API.
enum AiProvider {
  ollama,
  anthropic,
  openai,
  gemini,
  groq,
  perplexity,
  xai,
  mistral,
  unknown;

  String get displayName => switch (this) {
        AiProvider.ollama => 'Ollama (Local)',
        AiProvider.anthropic => 'Anthropic (Claude)',
        AiProvider.openai => 'OpenAI (ChatGPT)',
        AiProvider.gemini => 'Google Gemini',
        AiProvider.groq => 'Groq (Llama — Gratuit)',
        AiProvider.perplexity => 'Perplexity AI',
        AiProvider.xai => 'xAI (Grok)',
        AiProvider.mistral => 'Mistral AI',
        AiProvider.unknown => 'Inconnu',
      };

  String get emoji => switch (this) {
        AiProvider.ollama => '\u{1F999}',
        AiProvider.anthropic => '\u{1F7E3}',
        AiProvider.openai => '\u{1F7E2}',
        AiProvider.gemini => '\u{1F535}',
        AiProvider.groq => '⚡',
        AiProvider.perplexity => '\u{1F50D}',
        AiProvider.xai => '❎',
        AiProvider.mistral => '\u{1F300}',
        AiProvider.unknown => '❔',
      };

  String get baseUrl => switch (this) {
        AiProvider.ollama => 'http://localhost:11434',
        AiProvider.anthropic => 'https://api.anthropic.com',
        AiProvider.openai => 'https://api.openai.com',
        AiProvider.gemini => 'https://generativelanguage.googleapis.com',
        AiProvider.groq => 'https://api.groq.com/openai',
        AiProvider.perplexity => 'https://api.perplexity.ai',
        AiProvider.xai => 'https://api.x.ai',
        AiProvider.mistral => 'https://api.mistral.ai',
        AiProvider.unknown => '',
      };

  String get defaultModel => switch (this) {
        AiProvider.ollama => 'gemma3',
        AiProvider.anthropic => 'claude-3-5-haiku-20241022',
        AiProvider.openai => 'gpt-4o-mini',
        AiProvider.gemini => 'gemini-2.5-flash',
        AiProvider.groq => 'llama-3.3-70b-versatile',
        AiProvider.perplexity => 'llama-3.1-sonar-small-128k-online',
        AiProvider.xai => 'grok-beta',
        AiProvider.mistral => 'mistral-small-latest',
        AiProvider.unknown => '',
      };

  String get apiKeyUrl => switch (this) {
        AiProvider.ollama => 'https://ollama.com/download',
        AiProvider.anthropic => 'https://console.anthropic.com/settings/keys',
        AiProvider.openai => 'https://platform.openai.com/api-keys',
        AiProvider.gemini => 'https://aistudio.google.com/app/apikey',
        AiProvider.groq => 'https://console.groq.com/keys',
        AiProvider.perplexity => 'https://www.perplexity.ai/settings/api',
        AiProvider.xai => 'https://console.x.ai/',
        AiProvider.mistral => 'https://console.mistral.ai/api-keys/',
        AiProvider.unknown => '',
      };

  bool get isLocal => this == AiProvider.ollama;

  bool get hasFreetier => this == AiProvider.groq || this == AiProvider.gemini;

  String get freeTierNote => switch (this) {
        AiProvider.groq => 'Gratuit avec limites genereuuses — ideal pour les eleves',
        AiProvider.gemini => 'Tier gratuit disponible sur Google AI Studio',
        _ => '',
      };

  /// Modeles connus pour ce provider — utilises dans les selecteurs UI.
  List<String> get availableModels => switch (this) {
        AiProvider.gemini    => ['gemini-2.5-flash', 'gemini-2.5-pro', 'gemini-2.0-flash', 'gemini-1.5-flash'],
        AiProvider.openai    => ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'o1-mini', 'o3-mini'],
        AiProvider.anthropic => ['claude-opus-4-8', 'claude-sonnet-4-6', 'claude-haiku-4-5-20251001', 'claude-3-5-sonnet-20241022', 'claude-3-5-haiku-20241022'],
        AiProvider.groq      => ['llama-3.3-70b-versatile', 'llama-3.1-8b-instant', 'gemma2-9b-it', 'mixtral-8x7b-32768'],
        AiProvider.perplexity=> ['llama-3.1-sonar-large-128k-online', 'llama-3.1-sonar-small-128k-online', 'llama-3.1-sonar-huge-128k-online'],
        AiProvider.xai       => ['grok-3', 'grok-3-fast', 'grok-beta', 'grok-2'],
        AiProvider.mistral   => ['mistral-large-latest', 'mistral-small-latest', 'codestral-latest', 'open-mistral-nemo'],
        AiProvider.ollama    => ['gemma3', 'llama3.2', 'mistral', 'phi4', 'qwen2.5', 'deepseek-r1'],
        _                    => [],
      };

  /// Detecte le provider en analysant la structure complete de la cle (regex).
  /// Le sentinel 'ollama' identifie le provider local sans cle API.
  static AiProvider detectFromKey(String key) {
    final k = key.trim();
    if (k == 'ollama') return AiProvider.ollama;
    // Anthropic : sk-ant- suivi d'au moins 80 caracteres base64url
    if (RegExp(r'^sk-ant-[a-zA-Z0-9\-_]{80,}$').hasMatch(k))   return AiProvider.anthropic;
    // Gemini Google AI Studio : AIza + 35 chars OU AQ. + base64url
    if (RegExp(r'^AIza[a-zA-Z0-9_\-]{35}$').hasMatch(k))       return AiProvider.gemini;
    if (RegExp(r'^AQ\.[a-zA-Z0-9_\-\.]{20,}$').hasMatch(k))    return AiProvider.gemini;
    // Groq : gsk_ + 50+ chars
    if (RegExp(r'^gsk_[a-zA-Z0-9]{50,}$').hasMatch(k))         return AiProvider.groq;
    // Perplexity : pplx- + 40+ chars
    if (RegExp(r'^pplx-[a-zA-Z0-9]{40,}$').hasMatch(k))        return AiProvider.perplexity;
    // xAI Grok : xai- + 80+ chars
    if (RegExp(r'^xai-[a-zA-Z0-9]{80,}$').hasMatch(k))         return AiProvider.xai;
    // OpenAI project key : sk-proj- + 50+ chars
    if (RegExp(r'^sk-proj-[a-zA-Z0-9_\-]{50,}$').hasMatch(k))  return AiProvider.openai;
    // OpenAI legacy key : sk- + 48+ chars alphanumerique
    if (RegExp(r'^sk-[a-zA-Z0-9]{48,}$').hasMatch(k))          return AiProvider.openai;
    // Mistral : 32 chars alphanumeriques sans separateur
    if (RegExp(r'^[a-zA-Z0-9]{32}$').hasMatch(k))               return AiProvider.mistral;
    return AiProvider.unknown;
  }

  static AiProvider fromName(String name) {
    return AiProvider.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AiProvider.unknown,
    );
  }
}
