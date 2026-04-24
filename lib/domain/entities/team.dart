import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String name;
  final int score;
  final Map<String, bool> availableJokers;

  const Team({
    required this.id,
    required this.name,
    this.score = 0,
    this.availableJokers = const {
      'time_freeze': true,
      'double_risk': true,
      'pass': true,
    },
  });

  Team copyWith({
    String? id,
    String? name,
    int? score,
    Map<String, bool>? availableJokers,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      availableJokers: availableJokers ?? this.availableJokers,
    );
  }

  @override
  List<Object?> get props => [id, name, score, availableJokers];
}
