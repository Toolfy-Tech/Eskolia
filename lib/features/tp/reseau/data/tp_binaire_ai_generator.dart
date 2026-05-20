import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../ai/data/ai_chat_service.dart';
import '../../../ai/data/ai_key_repository.dart';
import '../../../ai/data/ai_provider.dart';
import 'tp_binaire_data.dart';

class TpBinaireAiGenerator {
  TpBinaireAiGenerator({required this.service, required this.state});

  final AiChatService service;
  final AiConnectionState state;

  static const _system = r'''
Tu es un générateur de TPs de réseaux informatiques.
Retourne UNIQUEMENT un JSON valide (sans markdown, sans explication) respectant ce schéma exact :

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
1. "Décimal vers Binaire" — 5 questions : convertir un octet décimal en 8 bits binaire (ex: 192 → "11000000")
2. "Binaire vers Décimal" — 5 questions : convertir 8 bits binaire en décimal (ex: "11000000" → "192")
3. "Classes IP" — 4 questions : identifier la classe (A, B ou C) d'une adresse IP complète (ex: "192.168.1.1" → "C")
4. "Masques par défaut" — 3 questions : donner le masque par défaut d'une classe (ex: "Classe A" → "255.0.0.0")
5. "Notation CIDR" — 4 questions : convertir masque↔préfixe (ex: "255.255.255.0" → "/24" ou "/24" → "255.255.255.0")
6. "Subnetting" — 2 questions avec sous-questions au format :
   {
     "prompt": "string décrivant IP/préfixe",
     "answer": "",
     "points": 4,
     "hint": null,
     "subQuestions": [
       { "label": "Adresse réseau", "answer": "x.x.x.x" },
       { "label": "Masque de sous-réseau", "answer": "255.x.x.x" },
       { "label": "Adresse broadcast", "answer": "x.x.x.x" },
       { "label": "Plage d'hotes valides", "answer": "x.x.x.x - x.x.x.x" }
     ]
   }

Niveaux :
- facile : octets ronds (0, 128, 192, 224, 255), classes A/B/C évidentes, masques /8 /16 /24
- moyen  : valeurs variées, masques /25 /26 /22 /28, classes mixtes
- difficile : valeurs complexes, masques /19 /21 /27 /29, subnetting non trivial

Toutes les réponses mathématiques DOIVENT être correctes. AUCUN markdown, UNIQUEMENT le JSON.
''';

  Future<TpBinaire> generate(TpDifficulty difficulty) async {
    final diffLabel = switch (difficulty) {
      TpDifficulty.facile    => 'facile',
      TpDifficulty.moyen     => 'moyen',
      TpDifficulty.difficile => 'difficile',
    };

    // Lecture des settings Ollama si le provider est local.
    String ollamaUrl   = 'http://localhost:11434';
    String ollamaModel = 'gemma3';
    if (state.provider == AiProvider.ollama) {
      final prefs = await SharedPreferences.getInstance();
      ollamaUrl   = prefs.getString('ollama_url')   ?? ollamaUrl;
      ollamaModel = prefs.getString('ollama_model') ?? ollamaModel;
    }

    final buf = StringBuffer();
    await for (final chunk in service.streamChat(
      apiKey: state.apiKey ?? 'ollama',
      provider: state.provider,
      systemPrompt: _system,
      messages: [
        AiMessage(
          role: 'user',
          content: 'Genere un TP de niveau "$diffLabel". Retourne uniquement le JSON.',
        ),
      ],
      maxTokens: 4096,
      temperature: 0.25,
      jsonMode: true,
      ollamaBaseUrl: ollamaUrl,
      ollamaModel: ollamaModel,
    )) {
      buf.write(chunk);
    }

    return _parse(buf.toString(), difficulty);
  }

  TpBinaire _parse(String raw, TpDifficulty difficulty) {
    var text = raw.trim();
    final md = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    if (md != null) text = md.group(1)!.trim();

    final json   = jsonDecode(text) as Map<String, dynamic>;
    final secArr = json['sections'] as List<dynamic>;

    final sections = secArr.map((s) {
      final sec  = s as Map<String, dynamic>;
      final qs   = (sec['questions'] as List<dynamic>).map((q) {
        final qm  = q as Map<String, dynamic>;
        final sub = qm['subQuestions'] as List<dynamic>?;
        return TpQuestion(
          prompt:       qm['prompt'] as String,
          answer:       (qm['answer'] as String?) ?? '',
          points:       (qm['points'] as num?)?.toInt() ?? 1,
          hint:         qm['hint'] as String?,
          subQuestions: sub?.map((sq) {
            final sm = sq as Map<String, dynamic>;
            return TpSubQuestion(
              label:  sm['label']  as String,
              answer: sm['answer'] as String,
            );
          }).toList(),
        );
      }).toList();
      return TpSection(
        title:       sec['title']       as String,
        instruction: (sec['instruction'] as String?) ?? '',
        questions:   qs,
      );
    }).toList();

    return TpBinaire(
      id:         'ai_${DateTime.now().millisecondsSinceEpoch}',
      title:      (json['title'] as String?) ?? 'TP genere par l\'IA',
      difficulty: difficulty,
      sections:   sections,
    );
  }
}
