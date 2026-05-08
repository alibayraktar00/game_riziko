import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/team.dart';

class GameNotifier extends Notifier<GameSession> {
  final _uuid = const Uuid();

  @override
  GameSession build() {
    return GameSession(
      id: _uuid.v4(), 
      teams: const [],
      createdAt: DateTime.now(),
    );
  }

  void addTeam(String name) {
    final newTeam = Team(id: _uuid.v4(), name: name);
    state = state.copyWith(teams: [...state.teams, newTeam]);
  }

  void removeTeam(String id) {
    state = state.copyWith(teams: state.teams.where((t) => t.id != id).toList());
  }

  void setQuestions(List<Question> questions) {
    state = state.copyWith(availableQuestions: questions);
  }

  void nextTurn() {
    int nextIndex = (state.currentTeamIndex + 1) % state.teams.length;
    state = state.copyWith(currentTeamIndex: nextIndex);
  }

  void addScoreToCurrentTeam(int points) {
    final updatedTeams = List<Team>.from(state.teams);
    final currentTeam = state.currentTeam;
    updatedTeams[state.currentTeamIndex] = currentTeam.copyWith(score: currentTeam.score + points);
    state = state.copyWith(teams: updatedTeams);
  }

  void resetGame() {
    state = GameSession(
      id: _uuid.v4(), 
      teams: state.teams.map((t) => t.copyWith(score: 0)).toList(),
      createdAt: DateTime.now(),
    );
  }

  void removeQuestion(String id) {
    state = state.copyWith(
      availableQuestions: state.availableQuestions.where((q) => q.id != id).toList()
    );
  }

  void useJoker(String jokerKey) {
    final updatedTeams = List<Team>.from(state.teams);
    final currentTeam = state.currentTeam;
    
    final newJokers = Map<String, bool>.from(currentTeam.availableJokers);
    newJokers[jokerKey] = false;
    
    updatedTeams[state.currentTeamIndex] = currentTeam.copyWith(availableJokers: newJokers);
    state = state.copyWith(teams: updatedTeams);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameSession>(() {
  return GameNotifier();
});
