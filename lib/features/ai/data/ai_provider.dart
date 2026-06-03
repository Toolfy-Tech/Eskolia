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

  /// Detecte automatiquement le provider depuis le prefixe de la cle.
  /// Le sentinel 'ollama' identifie le provider local sans cle API.
  static AiProvider detectFromKey(String key) {
    final k = key.trim();
    if (k == 'ollama') return AiProvider.ollama;
    if (k.startsWith('sk-ant-')) return AiProvider.anthropic;
    if (k.startsWith('AIza') || k.startsWith('AQ.')) return AiProvider.gemini;
    if (k.startsWith('gsk_')) return AiProvider.groq;
    if (k.startsWith('pplx-')) return AiProvider.perplexity;
    if (k.startsWith('xai-')) return AiProvider.xai;
    if (k.startsWith('sk-proj-') || k.startsWith('sk-')) return AiProvider.openai;
    if (RegExp(r'^[a-zA-Z0-9]{32,}$').hasMatch(k) && !k.contains('-')) {
      return AiProvider.mistral;
    }
    return AiProvider.unknown;
  }

  static AiProvider fromName(String name) {
    return AiProvider.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AiProvider.unknown,
    );
  }
}
