import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/question.dart';

class GameSessionModel {
  final String id;
  final List<Team> teams;
  final int currentTeamIndex;
  final List<Question> availableQuestions;
  final DateTime createdAt;
  final String? hostDeviceId;
  final List<String> connectedDeviceIds;
  final bool isMultiplayer;
  final GameStatus status;

  const GameSessionModel({
    required this.id,
    required this.teams,
    required this.currentTeamIndex,
    required this.availableQuestions,
    required this.createdAt,
    this.hostDeviceId,
    required this.connectedDeviceIds,
    required this.isMultiplayer,
    required this.status,
  });

  GameSession fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GameSession(
      id: doc.id,
      teams: (data['teams'] as List<dynamic>?)
          ?.map((teamData) => Team.fromMap(teamData as Map<String, dynamic>))
          .toList() ?? [],
      currentTeamIndex: data['currentTeamIndex'] as int? ?? 0,
      availableQuestions: (data['availableQuestions'] as List<dynamic>?)
          ?.map((qData) => Question.fromMap(qData as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hostDeviceId: data['hostDeviceId'] as String?,
      connectedDeviceIds: List<String>.from(data['connectedDeviceIds'] as List? ?? []),
      isMultiplayer: data['isMultiplayer'] as bool? ?? false,
      status: _parseGameStatus(data['status'] as String?),
    );
  }

  GameStatus _parseGameStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return GameStatus.inProgress;
      case 'paused':
        return GameStatus.paused;
      case 'finished':
        return GameStatus.finished;
      default:
        return GameStatus.waiting;
    }
  }

  Map<String, dynamic> toFirestore(GameSession session) {
    return {
      'teams': session.teams.map((team) => team.toMap()).toList(),
      'currentTeamIndex': session.currentTeamIndex,
      'availableQuestions': session.availableQuestions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(session.createdAt),
      'hostDeviceId': session.hostDeviceId,
      'connectedDeviceIds': session.connectedDeviceIds,
      'isMultiplayer': session.isMultiplayer,
      'status': session.status.name,
    };
  }
}
