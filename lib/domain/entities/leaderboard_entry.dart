import 'dart:convert';
import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final String teamName;
  final int score;
  final DateTime date;

  const LeaderboardEntry({
    required this.teamName,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamName': teamName,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      teamName: map['teamName'] ?? '',
      score: map['score']?.toInt() ?? 0,
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LeaderboardEntry.fromJson(String source) => LeaderboardEntry.fromMap(json.decode(source));

  @override
  List<Object?> get props => [teamName, score, date];
}
