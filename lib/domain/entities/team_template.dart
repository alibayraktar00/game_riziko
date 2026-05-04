import 'dart:convert';
import 'package:equatable/equatable.dart';

class TeamTemplate extends Equatable {
  final String id;
  final String templateName;
  final List<TeamPreset> teams;

  const TeamTemplate({
    required this.id,
    required this.templateName,
    required this.teams,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateName': templateName,
      'teams': teams.map((x) => x.toMap()).toList(),
    };
  }

  factory TeamTemplate.fromMap(Map<String, dynamic> map) {
    return TeamTemplate(
      id: map['id'] ?? '',
      templateName: map['templateName'] ?? '',
      teams: List<TeamPreset>.from(map['teams']?.map((x) => TeamPreset.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory TeamTemplate.fromJson(String source) => TeamTemplate.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, templateName, teams];
}

class TeamPreset extends Equatable {
  final String name;
  final String? emojiIcon;

  const TeamPreset({
    required this.name,
    this.emojiIcon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emojiIcon': emojiIcon,
    };
  }

  factory TeamPreset.fromMap(Map<String, dynamic> map) {
    return TeamPreset(
      name: map['name'] ?? '',
      emojiIcon: map['emojiIcon'],
    );
  }

  @override
  List<Object?> get props => [name, emojiIcon];
}
