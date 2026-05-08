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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'availableJokers': availableJokers,
    };
  }

  static Team fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      name: map['name'] as String,
      score: map['score'] as int? ?? 0,
      availableJokers: Map<String, bool>.from(map['availableJokers'] as Map? ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, name, score, availableJokers];
}
