import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../services/quiz_repository.dart';

/// Charge l’épreuve finale puis remplace par [QuizScreen] via `/quiz/run`.
class GrandFinaleTipScreen extends StatefulWidget {
  const GrandFinaleTipScreen({super.key});

  @override
  State<GrandFinaleTipScreen> createState() => _GrandFinaleTipScreenState();
}

class _GrandFinaleTipScreenState extends State<GrandFinaleTipScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final session = await QuizRepository().buildGrandFinaleSession();
      if (!mounted) return;
      context.pushReplacement('/quiz/run', extra: session);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(EskoliaLayout.screenPaddingH),
                child: _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Impossible de préparer l’épreuve finale.\n$_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Retour'),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFFB74D)),
                        SizedBox(height: 20),
                        Text(
                          'Préparation de l’épreuve finale TIP (parcours Optimus)…',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
