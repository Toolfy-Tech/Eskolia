import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:eskolia/core/theme/app_theme.dart';
import 'package:eskolia/features/auth/data/auth_repository.dart';
import 'package:eskolia/features/auth/presentation/login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('LoginScreen : champs, CTA et validation', (tester) async {
    final authRepo = AuthRepository(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );

    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(authRepository: authRepo),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const Scaffold(body: Text('register')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Champ requis'), findsNWidgets(2));
  });
}
