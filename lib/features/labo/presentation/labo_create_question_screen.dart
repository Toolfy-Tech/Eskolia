import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../economy/data/achievement_rewards.dart';
import '../data/labo_question_draft_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);

class LaboCreateQuestionScreen extends StatefulWidget {
  const LaboCreateQuestionScreen({super.key});

  @override
  State<LaboCreateQuestionScreen> createState() => _LaboCreateQuestionScreenState();
}

class _LaboCreateQuestionScreenState extends State<LaboCreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _section = TextEditingController();
  final _statement = TextEditingController();
  final _answer = TextEditingController();
  final _opt = List.generate(4, (_) => TextEditingController());
  final _explanation = TextEditingController();
  String _questionType = 'open'; // 'open' | 'qcm'
  int _correct = 0;
  String _difficulty = 'medium';
  bool _sending = false;

  @override
  void dispose() {
    _section.dispose();
    _statement.dispose();
    _answer.dispose();
    for (final c in _opt) {
      c.dispose();
    }
    _explanation.dispose();
    super.dispose();
  }

  Future<void> _preview() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Aperçu', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _statement.text.trim(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_questionType == 'open') ...[
                Text(
                  'Réponse attendue',
                  style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  _answer.text.trim(),
                  style: const TextStyle(color: Color(0xFF43E97B), fontSize: 13),
                ),
              ] else ...[
                ...List.generate(4, (i) {
                  final opts = _opt.map((c) => c.text.trim()).toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${String.fromCharCode(65 + i)}. ${opts[i]}'
                      '${i == _correct ? '  ✓' : ''}',
                      style: TextStyle(
                        color: i == _correct ? const Color(0xFF43E97B) : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour proposer une question.')),
      );
      return;
    }
    final isOpen = _questionType == 'open';
    final List<String> opts = isOpen
        ? [_answer.text.trim()]
        : _opt.map((c) => c.text.trim()).toList();
    setState(() => _sending = true);
    try {
      await LaboQuestionDraftRepository().submitDraft(
        sectionHint: _section.text.trim(),
        statement: _statement.text.trim(),
        options: opts,
        correctIndex: isOpen ? 0 : _correct,
        explanation: _explanation.text.trim(),
        difficulty: _difficulty,
      );
      await AchievementRewards().unlock(uid, 'labo_first_draft');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proposition envoyée — merci ! Elle sera revue par l'équipe."),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Nouvelle question'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  EskoliaLayout.screenPaddingH,
                  12,
                  EskoliaLayout.screenPaddingH,
                  EskoliaLayout.screenPaddingBottom,
                ),
                children: [
                  // ── Sélecteur de type ──────────────────────────────
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'open',
                        label: Text('Réponse libre'),
                        icon: Icon(Icons.edit_outlined, size: 16),
                      ),
                      ButtonSegment(
                        value: 'qcm',
                        label: Text('QCM 4 choix'),
                        icon: Icon(Icons.checklist_rounded, size: 16),
                      ),
                    ],
                    selected: {_questionType},
                    onSelectionChanged: (s) => setState(() => _questionType = s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _questionType == 'open'
                        ? 'Réponse libre : la correction est textuelle (cohérent avec le quiz principal).'
                        : 'QCM 4 choix : format à choix multiples, indique la bonne réponse.',
                    style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  // ── Champs communs ─────────────────────────────────
                  TextFormField(
                    controller: _section,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec('Section / chapitre (indicatif)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _statement,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _dec('Énoncé *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 14),
                  // ── Champs selon le type ───────────────────────────
                  if (_questionType == 'open') ...[
                    TextFormField(
                      controller: _answer,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: _dec('Réponse attendue *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                    ),
                  ] else ...[
                    Text(
                      'Choix',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextFormField(
                          controller: _opt[i],
                          style: const TextStyle(color: Colors.white),
                          decoration: _dec('Réponse ${String.fromCharCode(65 + i)} *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Bonne réponse',
                      style: TextStyle(color: _slate.withValues(alpha: 0.9), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: List.generate(4, (i) {
                        final sel = _correct == i;
                        return ChoiceChip(
                          label: Text(String.fromCharCode(65 + i)),
                          selected: sel,
                          onSelected: (_) => setState(() => _correct = i),
                          selectedColor: _violet.withValues(alpha: 0.85),
                          labelStyle: TextStyle(color: sel ? Colors.white : Colors.white70),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Difficulté',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'easy', label: Text('Facile')),
                      ButtonSegment(value: 'medium', label: Text('Moyen')),
                      ButtonSegment(value: 'hard', label: Text('Dur')),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (s) {
                      setState(() => _difficulty = s.first);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _explanation,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _dec('Explication (optionnel)'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _sending ? null : _preview,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: _violet.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Aperçu'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _sending ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _violet,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _sending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Envoyer en validation'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _slate.withValues(alpha: 0.85)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _violet),
      ),
    );
  }
}
