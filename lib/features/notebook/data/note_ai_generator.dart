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
        'Tu es formateur IT senior pour techniciens et apprentis (reseaux, systemes, securite, cloud, scripting). '
        'Tu rediges des mini-cours clairs, structures et pedagogiques en francais. '
        'Genere UNIQUEMENT du Markdown brut, sans fence, sans commentaire.';

    final userPrompt =
        'A partir des notes suivantes, genere un mini-cours structure en Markdown.\n\n'
        'Structure attendue :\n'
        '# Titre du cours\n'
        '> Introduction courte (2-3 phrases)\n\n'
        '## Section 1\n'
        'Contenu explicatif + exemples concrets\n\n'
        '## Section 2\n'
        '...\n\n'
        '## Points cles\n'
        'Liste a puces des notions essentielles\n\n'
        'REGLES :\n'
        '- Utilise des tableaux Markdown quand c\'est pertinent (comparaisons, commandes, acronymes)\n'
        '- Ajoute des exemples concrets issus du monde IT reel\n'
        '- Si des commandes ou du code sont mentionnes, utilise des blocs ` code `\n'
        '- Reste fide au contenu des notes, ne fabrique pas d\'informations\n'
        '- Longueur cible : 300-600 mots\n\n'
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
  /// Format Eskolia complet embarque dans le prompt.
  Stream<String> streamQuiz({
    required String apiKey,
    required AiProvider provider,
    required String noteContent,
    required String noteTitle,
  }) {
    const systemPrompt =
        'Tu es un expert en pedagogie IT (reseaux, systemes, securite, cloud, scripting). '
        'Tu crees des quiz de qualite professionnelle pour des techniciens et apprentis en formation. '
        'Reponds UNIQUEMENT avec du JSON valide et bien forme. '
        'Aucun texte, commentaire ou fence markdown avant ou apres le JSON.';

    final userPrompt =
        'Genere un quiz de 6 a 8 questions a partir des notes suivantes.\n'
        'Reponds UNIQUEMENT avec un objet JSON respectant EXACTEMENT ce schema :\n\n'
        '{\n'
        '  "quiz": {\n'
        '    "title": "Titre court et precis (max 60 chars)",\n'
        '    "description": "Une phrase decrivant le theme et le niveau",\n'
        '    "author": "IA Notebook"\n'
        '  },\n'
        '  "questions": [\n'
        '    {\n'
        '      "question": "Texte de la question (obligatoire)",\n'
        '      "answer": "Reponse complete attendue (obligatoire)",\n'
        '      "difficulty": "facile | moyen | difficile (obligatoire)",\n'
        '      "type": "classic | ticket | diagnostic_indices | sequence",\n'
        '      "hint": "Explication pedagogique affichee apres correction (recommande)",\n'
        '      "context": "Contexte optionnel ex: \'Reseau > Couche 3\'",\n'
        '      "indices": ["indice vague", "indice precis"],\n'
        '      "items": ["element 1 dans l\'ordre correct", "element 2", "element 3"]\n'
        '    }\n'
        '  ]\n'
        '}\n\n'
        'REGLES SUR LES TYPES :\n'
        '- classic : question ouverte standard (reutilise pour la majorite)\n'
        '- ticket : question presentee comme un ticket d\'incident reseau/systeme (utilise si pertinent)\n'
        '- diagnostic_indices : question avec 2-4 indices du plus vague au plus precis — "indices" requis (utilise pour 1-2 questions de diagnostic)\n'
        '- sequence : elements a remettre dans le bon ordre — "items" requis dans l\'ordre correct, "answer" = description de l\'ordre (utilise si les notes contiennent une procedure ou des etapes)\n\n'
        'REGLES DE QUALITE :\n'
        '- Utilise au moins 2 types differents si le contenu le permet\n'
        '- difficulty "facile" = definition/acronyme, "moyen" = procedure/comparaison, "difficile" = diagnostic/cas complexe\n'
        '- Les reponses doivent etre concises (1-3 phrases max) et directement issues du contenu\n'
        '- Le hint doit vraiment expliquer le pourquoi, pas repeter la reponse\n'
        '- Pour sequence : mini 3 items, maxi 6 items\n'
        '- Pour diagnostic_indices : 2 indices minimum (du plus vague au plus precis)\n\n'
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

  /// Extrait le JSON brut d'une reponse IA (retire fences, texte parasite).
  static String extractJson(String text) {
    final trimmed = text.trim();

    // 1. Fence ```json ... ```
    final jsonFence = RegExp(r'```json\s*\n?([\s\S]*?)\n?```', multiLine: false);
    final jsonMatch = jsonFence.firstMatch(trimmed);
    if (jsonMatch != null) return jsonMatch.group(1)!.trim();

    // 2. Fence generique ``` ... ```
    final genericFence = RegExp(r'```[^\n]*\n?([\s\S]*?)\n?```', multiLine: false);
    final genericMatch = genericFence.firstMatch(trimmed);
    if (genericMatch != null) return genericMatch.group(1)!.trim();

    // 3. Extraction par accolades : premier { jusqu'au dernier }
    final firstBrace = trimmed.indexOf('{');
    final lastBrace  = trimmed.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      return trimmed.substring(firstBrace, lastBrace + 1).trim();
    }

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
