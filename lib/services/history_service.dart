import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/leaderboard_entry.dart';
import '../domain/entities/match_result.dart';
import 'settings_service.dart';

class HistoryService {
  static const String _matchHistoryKey = 'history_matches';
  static const String _leaderboardKey = 'history_leaderboard';

  final SharedPreferences _prefs;

  HistoryService(this._prefs);

  // --- Match History ---
  List<MatchResult> getMatchHistory() {
    final List<String>? historyJson = _prefs.getStringList(_matchHistoryKey);
    if (historyJson == null) return [];

    return historyJson.map((jsonStr) => MatchResult.fromJson(jsonStr)).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }

  Future<void> saveMatchResult(MatchResult result) async {
    final history = getMatchHistory();
    history.add(result);
    // Keep only last 50 matches to avoid bloat
    if (history.length > 50) {
      history.sort((a, b) => b.date.compareTo(a.date));
      history.removeRange(50, history.length);
    }
    
    final List<String> historyJson = history.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_matchHistoryKey, historyJson);
  }

  // --- Leaderboard ---
  List<LeaderboardEntry> getLeaderboard() {
    final List<String>? leaderboardJson = _prefs.getStringList(_leaderboardKey);
    if (leaderboardJson == null) return [];

    return leaderboardJson.map((jsonStr) => LeaderboardEntry.fromJson(jsonStr)).toList()
      ..sort((a, b) => b.score.compareTo(a.score)); // Highest score first
  }

  Future<void> saveLeaderboardEntries(List<LeaderboardEntry> newEntries) async {
    final leaderboard = getLeaderboard();
    
    // Add new entries
    for (var newEntry in newEntries) {
      // Check if team already exists and update if new score is higher
      final existingIndex = leaderboard.indexWhere((e) => e.teamName.toLowerCase() == newEntry.teamName.toLowerCase());
      
      if (existingIndex >= 0) {
        if (newEntry.score > leaderboard[existingIndex].score) {
          leaderboard[existingIndex] = newEntry; // Update existing with new high score
        }
      } else {
        leaderboard.add(newEntry);
      }
    }

    // Sort and keep top 20
    leaderboard.sort((a, b) => b.score.compareTo(a.score));
    if (leaderboard.length > 20) {
      leaderboard.removeRange(20, leaderboard.length);
    }

    final List<String> leaderboardJson = leaderboard.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_leaderboardKey, leaderboardJson);
  }
}

final historyServiceProvider = Provider<HistoryService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HistoryService(prefs);
});
