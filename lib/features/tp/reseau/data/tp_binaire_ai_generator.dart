import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../ai/data/ai_chat_service.dart';
import '../../../ai/data/ai_key_repository.dart';
import '../../../ai/data/ai_provider.dart';
import '../../../ai/presentation/ai_config_widget.dart';
import 'tp_binaire_data.dart';

class TpBinaireAiGenerator {
  TpBinaireAiGenerator({required this.service, required this.state});

  final AiChatService service;
  final AiConnectionState state;

  // ── Mapping difficulte IA -> difficulte TP ────────────────────────────────

  static TpDifficulty _tpDifficulty(AiDifficulty d) => switch (d) {
        AiDifficulty.debutant      => TpDifficulty.facile,
        AiDifficulty.intermediaire => TpDifficulty.moyen,
        AiDifficulty.avance        => TpDifficulty.difficile,
        AiDifficulty.expert        => TpDifficulty.difficile,
      };

  // ── Construction du prompt dynamique ─────────────────────────────────────

  static String _buildSystemPrompt(
    AiDifficulty difficulty,
    int questionCount,
    TpExerciseType exerciseType,
  ) {
    final diffLabel = difficulty.promptLabel;

    final exerciseInstruction = exerciseType == TpExerciseType.complet
        ? 'Repartis les $questionCount exercices harmonieusement entre les 6 sections.'
        : 'L\'utilisateur veut s\'entrainer UNIQUEMENT sur la categorie "${exerciseType.label}".\n'
            'Genere EXACTEMENT $questionCount exercices dans la section "${exerciseType.sectionName}".\n'
            'Tu DOIS renvoyer la structure JSON complete avec les 6 sections, '
            'mais laisse le tableau "questions" de toutes les autres sections completement vide ([]).';

    return '''Tu es un generateur de TPs de reseaux informatiques.
Retourne UNIQUEMENT un JSON valide (sans markdown, sans explication) respectant ce schema exact :

{
  "title": "string",
  "sections": [
    {
      "title": "string",
      "instruction": "string",
      "questions": [
        { "prompt": "string", "answer": "string", "points": 1, "hint": null }
      ]
    }
  ]
}

6 sections obligatoires dans cet ordre :
1. "Decimal vers Binaire" — convertir un octet decimal en 8 bits binaire (ex: 192 -> "11000000")
2. "Binaire vers Decimal" — convertir 8 bits binaire en decimal (ex: "11000000" -> "192")
3. "Classes IP" — identifier la classe (A, B ou C) d\'une adresse IP (ex: "192.168.1.1" -> "C")
4. "Masques par defaut" — masque par defaut d\'une classe (ex: "Classe A" -> "255.0.0.0")
5. "Notation CIDR" — convertir masque <-> prefixe (ex: "255.255.255.0" -> "/24")
6. "Subnetting" — questions avec sous-questions au format :
   {
     "prompt": "string decrivant IP/prefixe",
     "answer": "",
     "points": 4,
     "hint": null,
     "subQuestions": [
       { "label": "Adresse reseau", "answer": "x.x.x.x" },
       { "label": "Masque de sous-reseau", "answer": "255.x.x.x" },
       { "label": "Adresse broadcast", "answer": "x.x.x.x" },
       { "label": "Plage d\'hotes valides", "answer": "x.x.x.x - x.x.x.x" }
     ]
   }

REGLES ABSOLUES :
- Tu dois generer EXACTEMENT $questionCount exercices au total dans le JSON.
- $exerciseInstruction
- Le niveau requis est : $diffLabel. Adapte la complexite des scenarios en consequence.
- INTERDICTION FORMELLE de te limiter aux masques par defaut /8 /16 /24 des classes A/B/C a chaque generation. Genere des adresses IP aleatoires variees, des masques originaux et des exercices de subnetting non triviaux.
- Varie les valeurs a chaque generation — ne repete jamais les memes adresses ou masques d\'une generation a l\'autre.

Toutes les reponses mathematiques DOIVENT etre correctes. AUCUN markdown, UNIQUEMENT le JSON.''';
  }

  // ── Generation ────────────────────────────────────────────────────────────

  Future<TpBinaire> generate({
    required AiDifficulty difficulty,
    int questionCount = 10,
    TpExerciseType exerciseType = TpExerciseType.complet,
  }) async {
    // Lecture des settings Ollama si le provider est local.
    String ollamaUrl   = 'http://127.0.0.1:11434';
    String ollamaModel = 'gemma3';
    if (state.provider == AiProvider.ollama) {
      final prefs = await SharedPreferences.getInstance();
      ollamaUrl   = prefs.getString('ollama_url')   ?? ollamaUrl;
      ollamaModel = prefs.getString('ollama_model') ?? ollamaModel;
    }

    final systemPrompt = _buildSystemPrompt(difficulty, questionCount, exerciseType);

    final buf = StringBuffer();
    await for (final chunk in service.streamChat(
      apiKey: state.apiKey ?? 'ollama',
      provider: state.provider,
      systemPrompt: systemPrompt,
      messages: const [
        AiMessage(
          role: 'user',
          content: 'Genere le TP demande. Retourne uniquement le JSON.',
        ),
      ],
      maxTokens: 4096,
      temperature: 0.75,
      jsonMode: true,
      ollamaBaseUrl: ollamaUrl,
      ollamaModel: ollamaModel,
    )) {
      buf.write(chunk);
    }

    return _parse(buf.toString(), difficulty);
  }

  // ── Parsing robuste ───────────────────────────────────────────────────────

  TpBinaire _parse(String raw, AiDifficulty difficulty) {
    var text = raw.trim();

    // Retire les fences markdown si presentes.
    final md = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    if (md != null) text = md.group(1)!.trim();

    // Extrait le premier objet JSON valide si du texte parasite precede.
    final firstBrace = text.indexOf('{');
    final lastBrace  = text.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      text = text.substring(firstBrace, lastBrace + 1);
    }

    final json   = jsonDecode(text) as Map<String, dynamic>;
    final secArr = (json['sections'] as List<dynamic>?) ?? [];

    final sections = secArr.map((s) {
      final sec  = s as Map<String, dynamic>;
      // Sections vides autorisees (mode exercice cible).
      final qArr = (sec['questions'] as List<dynamic>?) ?? [];

      final qs = qArr.map((q) {
        final qm  = q as Map<String, dynamic>;
        final sub = qm['subQuestions'] as List<dynamic>?;
        return TpQuestion(
          prompt:       (qm['prompt'] as String?) ?? '',
          answer:       (qm['answer'] as String?) ?? '',
          points:       (qm['points'] as num?)?.toInt() ?? 1,
          hint:         qm['hint'] as String?,
          subQuestions: sub?.map((sq) {
            final sm = sq as Map<String, dynamic>;
            return TpSubQuestion(
              label:  (sm['label']  as String?) ?? '',
              answer: (sm['answer'] as String?) ?? '',
            );
          }).toList(),
        );
      }).toList();

      return TpSection(
        title:       (sec['title']       as String?) ?? '',
        instruction: (sec['instruction'] as String?) ?? '',
        questions:   qs,
      );
    }).toList();

    return TpBinaire(
      id:         'ai_${DateTime.now().millisecondsSinceEpoch}',
      title:      (json['title'] as String?) ?? 'TP genere par l\'IA',
      difficulty: _tpDifficulty(difficulty),
      sections:   sections,
    );
  }
}
