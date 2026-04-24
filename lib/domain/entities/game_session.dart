import 'package:equatable/equatable.dart';
import 'team.dart';
import 'question.dart';

class GameSession extends Equatable {
  final String id;
  final List<Team> teams;
  final int currentTeamIndex;
  final List<Question> availableQuestions;

  const GameSession({
    required this.id,
    required this.teams,
    this.currentTeamIndex = 0,
    this.availableQuestions = const [],
  });

  Team get currentTeam => teams[currentTeamIndex];

  GameSession copyWith({
    String? id,
    List<Team>? teams,
    int? currentTeamIndex,
    List<Question>? availableQuestions,
  }) {
    return GameSession(
      id: id ?? this.id,
      teams: teams ?? this.teams,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      availableQuestions: availableQuestions ?? this.availableQuestions,
    );
  }

  @override
  List<Object?> get props => [id, teams, currentTeamIndex, availableQuestions];
}
