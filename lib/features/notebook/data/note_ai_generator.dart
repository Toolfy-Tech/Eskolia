import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/ai/data/ai_chat_service.dart';
import '../../../features/ai/data/ai_provider.dart';

/// Generateur IA pour les notes — mini-cours Markdown et quiz JSON.
class NoteAiGenerator {
  NoteAiGenerator({AiChatService? service})
      : _service = service ?? AiChatService();

  final AiChatService _service;

  /// Lit les parametres Ollama depuis SharedPreferences.
  Future<({String url, String model})> _ollamaConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      url:   prefs.getString('ollama_url')   ?? 'http://localhost:11434',
      model: prefs.getString('ollama_model') ?? 'gemma3',
    );
  }

  /// Retourne un Stream vers streamChat en injectant les params Ollama si besoin.
  Stream<String> _chat({
    required String apiKey,
    required AiProvider provider,
    required Future<({String url, String model})> ollamaCfg,
    required List<AiMessage> messages,
    String? systemPrompt,
    int maxTokens = 4096,
    double temperature = 0.7,
    bool jsonMode = false,
  }) async* {
    final cfg = provider == AiProvider.ollama ? await ollamaCfg : (url: '', model: '');
    yield* _service.streamChat(
      apiKey: apiKey,
      provider: provider,
      messages: messages,
      systemPrompt: systemPrompt,
      maxTokens: maxTokens,
      temperature: temperature,
      jsonMode: jsonMode,
      ollamaBaseUrl: cfg.url,
      ollamaModel: cfg.model,
    );
  }

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

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
      temperature: 0.5,
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
        '- diagnostic_indices : question avec 2-4 indices du plus vague au plus precis — champ "indices" OBLIGATOIRE (tableau de 2-4 chaines). Si tu ne fournis pas "indices", utilise "classic" a la place.\n'
        '- sequence : elements a remettre dans le bon ordre — champ "items" OBLIGATOIRE (tableau de 3-6 chaines dans l\'ordre correct), "answer" = phrase decrivant l\'ordre. INTERDIT d\'utiliser "sequence" sans fournir le champ "items".\n\n'
        'REGLES DE QUALITE :\n'
        '- Utilise au moins 2 types differents si le contenu le permet\n'
        '- difficulty "facile" = definition/acronyme, "moyen" = procedure/comparaison, "difficile" = diagnostic/cas complexe\n'
        '- Les reponses doivent etre concises (1-3 phrases max) et directement issues du contenu\n'
        '- Le hint doit vraiment expliquer le pourquoi, pas repeter la reponse\n'
        '- Pour sequence : 3 items minimum, 6 items maximum — chaque item est une etape/element court (1-5 mots)\n'
        '- Pour diagnostic_indices : 2 indices minimum, 4 maximum (du plus vague au plus precis)\n\n'
        'Titre des notes : $noteTitle\n'
        'Contenu :\n$noteContent';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
      temperature: 0.3,
      jsonMode: true,
    );
  }

  // ── Multi-sujets combiné ──────────────────────────────────────────────────

  /// Génère en un seul appel cours + quiz pour chaque sujet détecté.
  /// Format retourné : [{subject, course, quiz: [{question, answer, type, difficulty, hint}]}]
  Stream<String> streamCombined({
    required String apiKey,
    required AiProvider provider,
    required String allNotesContent,
  }) {
    const systemPrompt =
        'Tu es formateur IT senior ET expert en pedagogie. '
        'L\'utilisateur a ecrit des notes sur plusieurs sujets distincts. '
        'Pour chaque sujet detecte, genere : '
        '1) un mini-cours structure en Markdown, '
        '2) un quiz de 4 a 8 questions variees (Q&R, sequence, diagnostic). '
        'Reponds UNIQUEMENT en JSON valide. Aucun texte avant ou apres le JSON.';

    final userPrompt =
        'Voici les notes de l\'utilisateur :\n\n'
        '$allNotesContent\n\n'
        'Pour chaque sujet detecte, genere un cours ET un quiz. '
        'Reponds UNIQUEMENT avec ce tableau JSON :\n'
        '[{\n'
        '  "subject": "Titre du sujet",\n'
        '  "course": "# Titre\\n\\nContenu Markdown...",\n'
        '  "quiz": [\n'
        '    {"question": "...", "answer": "...", '
        '"type": "classic|sequence|diagnostic_indices|ticket", '
        '"difficulty": "facile|moyen|difficile", "hint": "...", '
        '"items": ["item1","item2","item3"], '
        '"indices": ["indice vague","indice precis"]}\n'
        '  ]\n'
        '}]\n'
        'IMPORTANT: si type=sequence, le champ items est OBLIGATOIRE. Si type=diagnostic_indices, le champ indices est OBLIGATOIRE. Sinon utilise classic.';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 10000,
      temperature: 0.4,
      jsonMode: true,
    );
  }

  // ── Multi-sujets separes ──────────────────────────────────────────────────

  /// Multi-subject course generation.
  /// Returns a JSON stream: [{subject: string, course: string}]
  Stream<String> streamMultiCourse({
    required String apiKey,
    required AiProvider provider,
    required String allNotesContent,
  }) {
    const systemPrompt =
        'Tu es formateur IT senior pour techniciens et apprentis (reseaux, systemes, securite, cloud, scripting). '
        'L\'utilisateur a ecrit plusieurs notes sur des sujets differents. '
        'Identifie les sujets distincts et genere UN mini-cours structure en Markdown par sujet detecte. '
        'Reponds UNIQUEMENT en JSON valide. Aucun texte avant ou apres le JSON.';

    final userPrompt =
        'Voici les notes de l\'utilisateur :\n\n'
        '$allNotesContent\n\n'
        'Identifie les sujets distincts et genere un mini-cours par sujet. '
        'Reponds UNIQUEMENT avec un tableau JSON :\n'
        '[{"subject": "Titre court du sujet", "course": "# Titre\\n\\nContenu Markdown du cours..."}]';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 8192,
      temperature: 0.5,
      jsonMode: true,
    );
  }

  /// Multi-subject quiz generation.
  /// Returns a JSON stream: [{subject: string, questions: [...]}]
  Stream<String> streamMultiQuiz({
    required String apiKey,
    required AiProvider provider,
    required String allNotesContent,
  }) {
    const systemPrompt =
        'Tu es un expert en pedagogie IT (reseaux, systemes, securite, cloud, scripting). '
        'L\'utilisateur a ecrit des notes sur plusieurs sujets distincts. '
        'Identifie chaque sujet et genere UN quiz de 4 a 8 questions par sujet. '
        'Reponds UNIQUEMENT en JSON valide. Aucun texte avant ou apres le JSON.';

    final userPrompt =
        'Voici les notes de l\'utilisateur :\n\n'
        '$allNotesContent\n\n'
        'Genere UN quiz de 4 a 8 questions par sujet detecte. '
        'Reponds avec un tableau JSON — chaque element a ce format :\n'
        '[{"subject": "Titre du sujet", "questions": ['
        '{"question": "...", "answer": "...", "difficulty": "facile|moyen|difficile", '
        '"type": "classic|sequence|diagnostic_indices|ticket", "hint": "...", '
        '"items": ["item1","item2","item3"], "indices": ["indice vague","indice precis"]}'
        ']}]\n'
        'IMPORTANT: si type=sequence, items OBLIGATOIRE. Si type=diagnostic_indices, indices OBLIGATOIRE. Sinon utilise classic.';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 8192,
      temperature: 0.3,
      jsonMode: true,
    );
  }

  // ── Flashcards ─────────────────────────────────────────────────────────────

  /// Genere des flashcards terme/definition a partir du contenu de la note.
  /// Retourne un JSON {quiz:{}, questions:[{type:'classic', question, answer, ...}]}.
  Stream<String> streamFlashcards({
    required String apiKey,
    required AiProvider provider,
    required String noteContent,
    required String noteTitle,
  }) {
    const systemPrompt =
        'Tu es formateur IT. Tu extrais les termes cles et definitions importantes '
        'de notes pour creer des flashcards. '
        'Reponds UNIQUEMENT avec du JSON valide. Aucun texte avant ou apres le JSON.';

    final userPrompt =
        'Extrait les termes et concepts cles des notes suivantes et genere des flashcards.\n'
        'Reponds UNIQUEMENT avec ce JSON :\n\n'
        '{\n'
        '  "quiz": {\n'
        '    "title": "Flashcards : $noteTitle",\n'
        '    "description": "Flashcards generees depuis les notes",\n'
        '    "author": "IA Notebook"\n'
        '  },\n'
        '  "questions": [\n'
        '    {\n'
        '      "type": "classic",\n'
        '      "question": "Definis ce terme : [terme]",\n'
        '      "answer": "[definition complete et claire]",\n'
        '      "difficulty": "facile",\n'
        '      "context": "[domaine ex: Reseau, Securite, Systeme]",\n'
        '      "hint": "[exemple concret ou mnémotechnique si utile]"\n'
        '    }\n'
        '  ]\n'
        '}\n\n'
        'REGLES :\n'
        '- Genere entre 6 et 20 flashcards selon la richesse du contenu\n'
        '- Une flashcard = un terme ou concept cle identifie dans les notes\n'
        '- "answer" = definition claire en 1-3 phrases\n'
        '- "difficulty" = toujours "facile"\n'
        '- "context" = domaine IT court (Reseau, Securite, AD, Cloud...)\n'
        '- Reste fide au contenu des notes, ne fabrique pas de termes\n\n'
        'Titre des notes : $noteTitle\n'
        'Contenu :\n$noteContent';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
      temperature: 0.3,
      jsonMode: true,
    );
  }

  // ── Quiz depuis un theme libre ─────────────────────────────────────────────

  /// Genere un quiz JSON a partir d'un theme IT libre (pour lobbies multijoueur).
  /// Format identique a streamQuiz(), compatible CustomQuizData.fromJsonString().
  Stream<String> streamQuizFromTheme({
    required String apiKey,
    required AiProvider provider,
    required String theme,
    required int questionCount,
    required String difficulty,
  }) {
    const systemPrompt =
        'Tu es un expert en pedagogie IT (reseaux, systemes, securite, cloud, scripting). '
        'Tu crees des quiz de qualite professionnelle pour des techniciens en formation. '
        'Reponds UNIQUEMENT avec du JSON valide. Aucun texte, commentaire ou fence avant ou apres.';

    final diffNote = difficulty == 'mixte'
        ? 'Mix equitable de facile, moyen et difficile'
        : 'Priorite a la difficulte "$difficulty"';

    final userPrompt =
        'Genere un quiz de $questionCount questions sur le theme : "$theme".\n'
        'Niveau : $diffNote.\n'
        'Reponds UNIQUEMENT avec ce JSON :\n\n'
        '{\n'
        '  "quiz": {\n'
        '    "title": "$theme",\n'
        '    "description": "Quiz IA sur $theme",\n'
        '    "author": "IA Eskolia"\n'
        '  },\n'
        '  "questions": [\n'
        '    {\n'
        '      "question": "...",\n'
        '      "answer": "...",\n'
        '      "difficulty": "facile|moyen|difficile",\n'
        '      "type": "classic|ticket|diagnostic_indices|sequence",\n'
        '      "hint": "...",\n'
        '      "context": "...",\n'
        '      "indices": ["indice vague", "indice precis"],\n'
        '      "items": ["element1", "element2"]\n'
        '    }\n'
        '  ]\n'
        '}\n\n'
        'REGLES :\n'
        '- diagnostic_indices : champ "indices" OBLIGATOIRE (2-4 chaines)\n'
        '- sequence : champ "items" OBLIGATOIRE (3-6 elements dans l\'ordre correct)\n'
        '- Utilise 2-3 types differents pour varier\n'
        '- Contenu IT reel, precis et pedagogique';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 6000,
      temperature: 0.4,
      jsonMode: true,
    );
  }

  // ── Recap IA des bilans ────────────────────────────────────────────────────

  /// Analyse une liste de bilans de quiz et identifie les lacunes recurrentes.
  /// [bilansJson] : JSON encode d'une liste d'objets bilan (format Eskolia Bilans/).
  Stream<String> streamBilanRecap({
    required String apiKey,
    required AiProvider provider,
    required String bilansJson,
  }) {
    const systemPrompt =
        'Tu es formateur IT senior. Tu analyses les resultats de quiz d\'un eleve '
        'pour identifier ses lacunes recurrentes et lui proposer un plan de revision personnalise. '
        'Reponds en Markdown structure, en francais, de facon encourageante et pedagogique. '
        'Genere UNIQUEMENT du Markdown brut, sans fence, sans commentaire.';

    final userPrompt =
        'Voici les bilans de quiz de l\'eleve (format JSON) :\n\n'
        '$bilansJson\n\n'
        'Analyse ces resultats et redige un rapport de lacunes en Markdown avec cette structure exacte :\n\n'
        '# Recap de tes quiz\n'
        '> Phrase d\'intro personnalisee selon les resultats globaux (encourageante)\n\n'
        '## Synthese\n'
        '- Nombre de quiz analyses\n'
        '- Score moyen global\n'
        '- Progression eventuelle si plusieurs quiz sur le meme theme\n\n'
        '## Tes principales lacunes\n'
        'Pour chaque lacune identifiee (max 5) :\n'
        '### [Nom du theme/concept]\n'
        '- **Pourquoi c\'est une lacune** : questions ratees sur ce theme\n'
        '- **Ce que tu dois revoir** : notions precises a maitriser\n'
        '- **Conseil** : astuce concrete pour progresser\n\n'
        '## Points positifs\n'
        '- Ce que l\'eleve maitrise bien (basé sur les bonnes reponses)\n\n'
        '## Plan de revision recommande\n'
        'Liste ordonnee de 3 a 5 actions concretes a faire en priorite.\n\n'
        'REGLES :\n'
        '- Base-toi uniquement sur les donnees fournies, ne fabrique pas de resultats\n'
        '- Si une question est "wrong" ou "partial" sur plusieurs quiz, c\'est une lacune prioritaire\n'
        '- Tone encourageant : valorise les efforts, pas que les erreurs\n'
        '- Sois precis sur les notions IT (noms de protocoles, commandes, concepts reels)\n'
        '- Si un seul bilan est fourni, adapte le discours en consequence';

    return _chat(
      apiKey: apiKey,
      provider: provider,
      ollamaCfg: _ollamaConfig(),
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 4096,
      temperature: 0.5,
    );
  }

  // ── Utilitaires statiques ──────────────────────────────────────────────────

  /// Extrait le JSON brut d'une reponse IA (retire fences, texte parasite).
  /// Gere les tableaux JSON ([...]) et les objets ({...}).
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

    final firstBracket = trimmed.indexOf('[');
    final lastBracket  = trimmed.lastIndexOf(']');
    final firstBrace   = trimmed.indexOf('{');
    final lastBrace    = trimmed.lastIndexOf('}');

    // 3. Tableau JSON : [ vient avant { (ou pas d'objet racine)
    if (firstBracket != -1 && lastBracket > firstBracket &&
        (firstBrace == -1 || firstBracket < firstBrace)) {
      return trimmed.substring(firstBracket, lastBracket + 1).trim();
    }

    // 4. Objet JSON : premier { jusqu'au dernier }
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
