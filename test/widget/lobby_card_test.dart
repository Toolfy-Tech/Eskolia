import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eskolia/features/lobby/data/lobby_repository.dart';
import 'package:eskolia/features/lobby/presentation/lobbys_screen.dart';

void main() {
  testWidgets('LobbyCard affiche titre, pill statut et onTap', (tester) async {
    var tapped = false;
    final lobby = LobbyModel(
      id: 'test_lobby',
      title: 'Duel Réseau',
      subject: 'tcp',
      hostName: 'Alex',
      hostAvatar: '\u{1F9EE}',
      currentPlayers: 1,
      maxPlayers: 2,
      status: 'waiting',
      difficulty: 'moyen',
      quizId: 'demo',
      createdAt: DateTime(2024, 6, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LobbyCard(
            lobby: lobby,
            index: 0,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Duel Réseau'), findsOneWidget);
    expect(find.text('Ouvert'), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    expect(tapped, true);
  });
}
