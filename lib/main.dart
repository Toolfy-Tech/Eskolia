import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/constants/eskolia_tokens.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_palette_provider.dart';
import 'core/theme/text_scale_provider.dart';

Future<void> main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    await FirebaseService.initialize();
  } on StateError catch (e) {
    if (kDebugMode && e.message.contains('Firebase non configuré')) {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: SelectableText(
                    '${e.message}\n\n'
                    'Web : vérifie aussi les domaines autorisés (Auth) et '
                    '« flutter build web » + déploiement avec firebase.json.',
                    style: const TextStyle(height: 1.45),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }
    rethrow;
  }

  await AuthRepository.restoreWebAuthPersistenceIfNeeded();

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: EskoliaTokens.bgBase,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: EskoliaTokens.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    kDebugMode
                        ? details.exceptionAsString()
                        : 'Une erreur d’affichage est survenue.',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  runApp(
    const ProviderScope(
      child: EskoliaApp(),
    ),
  );
}

class EskoliaApp extends ConsumerWidget {
  const EskoliaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themePaletteProvider);
    final textScale = ref.watch(textScaleProvider);

    return MaterialApp.router(
      title: 'Eskolia',
      theme: AppTheme.fromPalette(palette),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const EskoliaScrollBehavior(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
