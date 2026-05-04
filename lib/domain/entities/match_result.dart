import 'dart:convert';
import 'package:equatable/equatable.dart';

class MatchResult extends Equatable {
  final String id;
  final DateTime date;
  final String winnerTeamName;
  final int winnerScore;
  final List<TeamResult> teams;

  const MatchResult({
    required this.id,
    required this.date,
    required this.winnerTeamName,
    required this.winnerScore,
    required this.teams,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'winnerTeamName': winnerTeamName,
      'winnerScore': winnerScore,
      'teams': teams.map((x) => x.toMap()).toList(),
    };
  }

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      winnerTeamName: map['winnerTeamName'] ?? '',
      winnerScore: map['winnerScore']?.toInt() ?? 0,
      teams: List<TeamResult>.from(map['teams']?.map((x) => TeamResult.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchResult.fromJson(String source) => MatchResult.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, date, winnerTeamName, winnerScore, teams];
}

class TeamResult extends Equatable {
  final String name;
  final int score;

  const TeamResult({
    required this.name,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
    };
  }

  factory TeamResult.fromMap(Map<String, dynamic> map) {
    return TeamResult(
      name: map['name'] ?? '',
      score: map['score']?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, score];
}
