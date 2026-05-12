import 'package:flutter_test/flutter_test.dart';

import 'package:eskolia/features/lobby/data/lobby_repository.dart';

extension LobbyModelJoin on LobbyModel {
  bool get canJoin => status == 'waiting' && !isFull;
}

const _battlePhaseOrder = [
  'waiting',
  'countdown',
  'question',
  'result',
  'finished',
];

BattleState _stateForPhase(String phase) {
  return BattleState(
    lobbyId: 'lobby_test',
    players: const [],
    currentQuestion: 0,
    totalQuestions: 3,
    phase: phase,
  );
}

final _t0 = DateTime(2024);

void main() {
  group('LobbyModel', () {
    test('isFull quand currentPlayers == maxPlayers', () {
      final lobby = LobbyModel(
        id: '1',
        title: 'T',
        subject: 's',
        hostName: 'h',
        hostAvatar: 'a',
        currentPlayers: 4,
        maxPlayers: 4,
        status: 'waiting',
        difficulty: 'moyen',
        quizId: 'q',
        createdAt: _t0,
      );
      expect(lobby.isFull, true);
    });

    test('canJoin quand status waiting et non plein', () {
      final open = LobbyModel(
        id: '1',
        title: 'T',
        subject: 's',
        hostName: 'h',
        hostAvatar: 'a',
        currentPlayers: 1,
        maxPlayers: 4,
        status: 'waiting',
        difficulty: 'moyen',
        quizId: 'q',
        createdAt: _t0,
      );
      expect(open.canJoin, true);

      final full = LobbyModel(
        id: '2',
        title: 'T',
        subject: 's',
        hostName: 'h',
        hostAvatar: 'a',
        currentPlayers: 2,
        maxPlayers: 2,
        status: 'waiting',
        difficulty: 'moyen',
        quizId: 'q',
        createdAt: _t0,
      );
      expect(full.canJoin, false);

      final inProgress = LobbyModel(
        id: '3',
        title: 'T',
        subject: 's',
        hostName: 'h',
        hostAvatar: 'a',
        currentPlayers: 1,
        maxPlayers: 4,
        status: 'in_progress',
        difficulty: 'moyen',
        quizId: 'q',
        createdAt: _t0,
      );
      expect(inProgress.canJoin, false);
    });
  });

  group('BattleState — enchaînement des phases', () {
    test('waiting → countdown → question → result → finished', () {
      final states =
          _battlePhaseOrder.map(_stateForPhase).toList(growable: false);
      for (var i = 0; i < states.length - 1; i++) {
        final from = states[i].phase;
        final to = states[i + 1].phase;
        final iFrom = _battlePhaseOrder.indexOf(from);
        final iTo = _battlePhaseOrder.indexOf(to);
        expect(iTo, iFrom + 1, reason: '$from doit précéder $to');
      }
    });
  });
}
