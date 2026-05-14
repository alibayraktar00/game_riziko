import 'package:equatable/equatable.dart';
import 'team.dart';
import 'question.dart';

enum GameStatus {
  waiting,
  inProgress,
  paused,
  finished,
}

class GameSession extends Equatable {
  final String id;
  final List<Team> teams;
  final int currentTeamIndex;
  final List<Question> availableQuestions;
  final List<String> selectedCategories;
  final DateTime createdAt;
  final String? hostDeviceId;
  final List<String> connectedDeviceIds;
  final bool isMultiplayer;
  final GameStatus status;
  final bool hasStarted;

  const GameSession({
    required this.id,
    required this.teams,
    this.currentTeamIndex = 0,
    this.availableQuestions = const [],
    this.selectedCategories = const [],
    required this.createdAt,
    this.hostDeviceId,
    this.connectedDeviceIds = const [],
    this.isMultiplayer = false,
    this.status = GameStatus.waiting,
    this.hasStarted = false,
  });

  Team get currentTeam => teams[currentTeamIndex];

  GameSession copyWith({
    String? id,
    List<Team>? teams,
    int? currentTeamIndex,
    List<Question>? availableQuestions,
    List<String>? selectedCategories,
    DateTime? createdAt,
    String? hostDeviceId,
    List<String>? connectedDeviceIds,
    bool? isMultiplayer,
    GameStatus? status,
    bool? hasStarted,
  }) {
    return GameSession(
      id: id ?? this.id,
      teams: teams ?? this.teams,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      availableQuestions: availableQuestions ?? this.availableQuestions,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      createdAt: createdAt ?? this.createdAt,
      hostDeviceId: hostDeviceId ?? this.hostDeviceId,
      connectedDeviceIds: connectedDeviceIds ?? this.connectedDeviceIds,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      status: status ?? this.status,
      hasStarted: hasStarted ?? this.hasStarted,
    );
  }

  @override
  List<Object?> get props => [
        id, 
        teams, 
        currentTeamIndex, 
        availableQuestions, 
        selectedCategories,
        createdAt, 
        hostDeviceId, 
        connectedDeviceIds, 
        isMultiplayer, 
        status,
        hasStarted,
      ];
}
