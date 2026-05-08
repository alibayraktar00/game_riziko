import '../entities/game_session.dart';

abstract class GameSessionRepository {
  Future<GameSession> createGameSession(GameSession session);
  Future<GameSession?> getGameSession(String sessionId);
  Future<void> updateGameSession(GameSession session);
  Stream<GameSession?> watchGameSession(String sessionId);
  Future<void> deleteGameSession(String sessionId);
  Future<List<GameSession>> getActiveGameSessions();
  Future<void> joinGameSession(String sessionId, String deviceId);
  Future<void> leaveGameSession(String sessionId, String deviceId);
}
