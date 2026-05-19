import '../../../features/ai/data/ai_chat_service.dart';
import '../../../features/ai/data/ai_provider.dart';

/// Generateur IA pour les notes — mini-cours Markdown et quiz JSON.
class NoteAiGenerator {
  NoteAiGenerator({AiChatService? service})
      : _service = service ?? AiChatService();

  final AiChatService _service;

  // ── Mini-cours ─────────────────────────────────────────────────────────────

  /// Stream un mini-cours en Markdown genere a partir du contenu de la note.
  Stream<String> streamMiniCourse({
    required String apiKey,
    required AiProvider provider,
    required String noteContent,
    required String noteTitle,
  }) {
    const systemPrompt =
        'Tu es formateur IT pour techniciens et apprentis. Redige en francais, sois pedagogique.';

    final userPrompt =
        'A partir des notes suivantes, genere un mini-cours structure en Markdown. '
        'Titre H1, intro, sections H2, tableaux si pertinent, exemples, resume final. '
        'Genere UNIQUEMENT le Markdown brut.\n\n'
        'Titre des notes : $noteTitle\n'
        'Contenu :\n$noteContent';

    return _service.streamChat(
      apiKey: apiKey,
      provider: provider,
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
    );
  }

  // ── Quiz JSON ──────────────────────────────────────────────────────────────

  /// Stream un quiz JSON genere a partir du contenu de la note.
  /// Format Eskolia embarque dans le prompt.
  Stream<String> streamQuiz({
    required String apiKey,
    required AiProvider provider,
    required String noteContent,
    required String noteTitle,
  }) {
    const systemPrompt =
        'Tu es expert en creation de quiz IT. Reponds UNIQUEMENT avec du JSON valide, aucun texte avant ou apres.';

    final userPrompt =
        'Genere un quiz de 5 a 8 questions a partir des notes suivantes.\n'
        'Reponds UNIQUEMENT avec un objet JSON respectant exactement ce format :\n'
        '{"quiz":{"title":"...","description":"...","author":"IA Notebook"},'
        '"questions":[{"question":"...","answer":"...","difficulty":"facile|moyen|difficile",'
        '"type":"classic","hint":"..."}]}\n\n'
        'Titre des notes : $noteTitle\n'
        'Contenu :\n$noteContent';

    return _service.streamChat(
      apiKey: apiKey,
      provider: provider,
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
    );
  }

  // ── Utilitaires statiques ──────────────────────────────────────────────────

  /// Retire les fences ```json ... ``` ou ``` ... ``` si presentes.
  static String extractJson(String text) {
    final trimmed = text.trim();

    // Essaie d'abord ```json ... ```
    final jsonFence = RegExp(r'^```json\s*\n?([\s\S]*?)\n?```\s*$', multiLine: false);
    final jsonMatch = jsonFence.firstMatch(trimmed);
    if (jsonMatch != null) return jsonMatch.group(1)!.trim();

    // Essaie ``` ... ```
    final genericFence = RegExp(r'^```[^\n]*\n?([\s\S]*?)\n?```\s*$', multiLine: false);
    final genericMatch = genericFence.firstMatch(trimmed);
    if (genericMatch != null) return genericMatch.group(1)!.trim();

    return trimmed;
  }

  /// Retire les fences ```markdown ... ``` ou ``` ... ``` si presentes.
  static String extractMarkdown(String text) {
    final trimmed = text.trim();

    final mdFence = RegExp(r'^```markdown\s*\n?([\s\S]*?)\n?```\s*$', multiLine: false);
    final mdMatch = mdFence.firstMatch(trimmed);
    if (mdMatch != null) return mdMatch.group(1)!.trim();

    final genericFence = RegExp(r'^```[^\n]*\n?([\s\S]*?)\n?```\s*$', multiLine: false);
    final genericMatch = genericFence.firstMatch(trimmed);
    if (genericMatch != null) return genericMatch.group(1)!.trim();

    return trimmed;
  }
}
