import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/labo_question_draft_repository.dart';

class LaboContribCardBody extends ConsumerStatefulWidget {
  const LaboContribCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<LaboContribCardBody> createState() => _LaboContribCardBodyState();
}

class _LaboContribCardBodyState extends ConsumerState<LaboContribCardBody> {
  final _statementCtrl = TextEditingController();
  final _correctCtrl = TextEditingController();
  final _wrongCtrl = TextEditingController();
  String _selectedSection = 'TRN01';
  bool _submitting = false;

  final List<Map<String, String>> _sections = [
    {'id': 'TRN01', 'title': 'Hardware & Architecture'},
    {'id': 'TRN02', 'title': 'Windows & Support'},
    {'id': 'TRN03', 'title': 'Réseaux'},
    {'id': 'TRN04', 'title': 'Cybersécurité'},
    {'id': 'TRN06', 'title': 'Cloud & Infrastructure'},
    {'id': 'TRN07', 'title': 'Linux & Serveurs'},
    {'id': 'TRN08', 'title': 'Virtualisation'},
  ];

  @override
  void dispose() {
    _statementCtrl.dispose();
    _correctCtrl.dispose();
    _wrongCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final statement = _statementCtrl.text.trim();
    final correct = _correctCtrl.text.trim();
    final wrong = _wrongCtrl.text.trim();

    if (statement.isEmpty || correct.isEmpty || wrong.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final authorName = FirebaseAuth.instance.currentUser?.displayName ?? 'Contributeur';
      
      await LaboQuestionDraftRepository().submitDraft(
        sectionHint: _selectedSection,
        statement: statement,
        options: [correct, wrong, 'Option vide C', 'Option vide D'],
        correctIndex: 0,
        authorName: authorName,
        difficulty: 'medium',
        explanation: 'Soumis via l\'accueil modulaire',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question suggérée avec succès pour vérification !')),
        );
        _statementCtrl.clear();
        _correctCtrl.clear();
        _wrongCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:labo_contrib']?.isCollapsed ?? false);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const SizedBox.shrink();

    final repo = LaboQuestionDraftRepository();

    if (isCollapsed) {
      return StreamBuilder(
        stream: repo.watchRecentDrafts(),
        builder: (context, snapshot) {
          final drafts = snapshot.data ?? [];
          final myDrafts = drafts.where((d) => d.authorId == uid).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science_rounded, color: Colors.tealAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        myDrafts.isEmpty
                            ? 'Aucune question soumise pour le moment'
                            : myDrafts.length == 1
                                ? '1 question soumise au Labo'
                                : '${myDrafts.length} questions soumises au Labo',
                        style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/labo'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Ouvrir Labo', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/labo/create-question'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Formulaire complet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    // Extended Mode: Mini creation form
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Statement
        const Text('Enoncé de la question :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _statementCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: const InputDecoration(
              hintText: 'Ex: Qu\'est-ce que le port 80 ?',
              hintStyle: TextStyle(color: Colors.white30, fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Correct Answer
        const Text('Bonne réponse :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _correctCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: const InputDecoration(
              hintText: 'Ex: Le protocole HTTP',
              hintStyle: TextStyle(color: Colors.white30, fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Wrong Answer
        const Text('Mauvaise réponse (leurre) :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5)),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: _wrongCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: const InputDecoration(
              hintText: 'Ex: Le protocole HTTPS sécurisé',
              hintStyle: TextStyle(color: Colors.white30, fontSize: 11),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Section dropdown
        const Text('Thème concerné :', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSection,
              dropdownColor: EskoliaTokens.surface1,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: _sections.map((sect) {
                return DropdownMenuItem<String>(
                  value: sect['id'],
                  child: Text(sect['title']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedSection = val);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/labo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Annuler', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: _submitting
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.send_rounded, size: 14),
                label: const Text('Soumettre', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
