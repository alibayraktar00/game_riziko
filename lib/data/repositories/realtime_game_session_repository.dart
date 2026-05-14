import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/game_session_repository.dart';

class RealtimeGameSessionRepository implements GameSessionRepository {
  final FirebaseDatabase _database;
  
  RealtimeGameSessionRepository({FirebaseDatabase? database}) 
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Future<GameSession> createGameSession(GameSession session) async {
    final ref = _database.ref('games/${session.id}');
    await ref.set({
      'status': session.status.name,
      'createdAt': ServerValue.timestamp,
      'hostDeviceId': session.hostDeviceId,
      'isMultiplayer': session.isMultiplayer,
      'playerCount': 0,
    });
    return session;
  }

  @override
  Future<GameSession?> getGameSession(String sessionId) async {
    final snapshot = await _database.ref('games/$sessionId').get();
    if (!snapshot.exists) return null;
    
    // Simplification for brevity in optimization phase
    return null; // Implementation would map snapshot to GameSession
  }

  @override
  Future<void> updateGameSession(GameSession session) async {
    await _database.ref('games/${session.id}').update({
      'status': session.status.name,
    });
  }

  @override
  Stream<GameSession?> watchGameSession(String sessionId) {
    return _database.ref('games/$sessionId').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      // Map to GameSession
      return null; 
    });
  }

  @override
  Future<void> deleteGameSession(String sessionId) async {
    await _database.ref('games/$sessionId').remove();
  }

  @override
  Future<List<GameSession>> getActiveGameSessions() async {
    return [];
  }

  @override
  Future<void> joinGameSession(String sessionId, String deviceId) async {
    // Already handled in NicknameScreen for now
  }

  @override
  Future<void> leaveGameSession(String sessionId, String deviceId) async {
    // Already handled in WaitingScreen/AdminScreen for now
  }
}
