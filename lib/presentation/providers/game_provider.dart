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

  /// Kategori adları veri kaynağına göre büyük/küçük harf veya boşluk
  /// farkı gösterebiliyor (statik banka, Firestore havuzu, özel sorular).
  /// Tüm kategori karşılaştırmaları bu normalize form üzerinden yapılır —
  /// aksi hâlde ör. "science" seçilince "Science" soruları filtreye
  /// takılıyor ve o kategoride hiç soru yokmuş gibi görünüyordu.
  static String _normalizeCategory(String category) => category.trim().toLowerCase();

  void startGame(List<Question> questions) {
    // Filter questions to keep only one per (category, difficulty) pair
    final Map<String, Question> uniqueQuestions = {};
    for (var q in questions) {
      final key = '${_normalizeCategory(q.category)}_${q.difficulty}';
      if (!uniqueQuestions.containsKey(key)) {
        uniqueQuestions[key] = q;
      }
    }

    state = state.copyWith(
      availableQuestions: uniqueQuestions.values.toList(),
      hasStarted: true,
      status: GameStatus.inProgress,
    );
  }

  void startGameWithCategories(List<Question> questions, List<String> categories) {
    // Filter questions by selected categories and then keep only one per (category, difficulty) pair
    final selected = categories.map(_normalizeCategory).toSet();
    final Map<String, Question> uniqueQuestions = {};
    for (var q in questions) {
      if (selected.contains(_normalizeCategory(q.category))) {
        final key = '${_normalizeCategory(q.category)}_${q.difficulty}';
        if (!uniqueQuestions.containsKey(key)) {
          uniqueQuestions[key] = q;
        }
      }
    }

    state = state.copyWith(
      availableQuestions: uniqueQuestions.values.toList(),
      selectedCategories: categories,
      hasStarted: true,
      status: GameStatus.inProgress,
    );
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

  void setMultipleChoice(bool value) {
    state = state.copyWith(isMultipleChoice: value);
  }

  void resetGame() {
    state = GameSession(
      id: _uuid.v4(), 
      teams: state.teams.map((t) => t.copyWith(score: 0)).toList(),
      createdAt: DateTime.now(),
      hasStarted: false,
      isMultipleChoice: state.isMultipleChoice,
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
