import 'package:uuid/uuid.dart';
import '../domain/entities/game_session.dart';
import '../domain/entities/team.dart';
import '../domain/repositories/game_session_repository.dart';
import 'qr_service.dart';

class MultiplayerService {
  final GameSessionRepository _repository;
  final QRService _qrService;
  final String _deviceId;
  
  MultiplayerService({
    required GameSessionRepository repository,
    String? deviceId,
  }) : _repository = repository,
       _qrService = QRService(),
       _deviceId = deviceId ?? const Uuid().v4();

  String get deviceId => _deviceId;

  Future<String> createMultiplayerSession({
    required List<Team> teams,
    required List<String> availableQuestions,
  }) async {
    final sessionId = _qrService.generateNewSessionId();
    
    final session = GameSession(
      id: sessionId,
      teams: teams,
      createdAt: DateTime.now(),
      hostDeviceId: _deviceId,
      isMultiplayer: true,
      status: GameStatus.waiting,
    );

    await _repository.createGameSession(session);
    return sessionId;
  }

  Future<GameSession?> joinSession(String sessionId) async {
    try {
      await _repository.joinGameSession(sessionId, _deviceId);
      return await _repository.getGameSession(sessionId);
    } catch (e) {
      throw Exception('Oyuna katılım başarısız: $e');
    }
  }

  Future<void> leaveSession(String sessionId) async {
    try {
      await _repository.leaveGameSession(sessionId, _deviceId);
    } catch (e) {
      throw Exception('Oyundan ayrılırken hata: $e');
    }
  }

  Stream<GameSession?> watchSession(String sessionId) {
    return _repository.watchGameSession(sessionId);
  }

  Future<void> startGame(String sessionId) async {
    try {
      final session = await _repository.getGameSession(sessionId);
      if (session == null) {
        throw Exception('Oyun seansı bulunamadı');
      }

      if (session.hostDeviceId != _deviceId) {
        throw Exception('Sadece oyun sahibi oyunu başlatabilir');
      }

      final updatedSession = session.copyWith(
        status: GameStatus.inProgress,
      );

      await _repository.updateGameSession(updatedSession);
    } catch (e) {
      throw Exception('Oyun başlatılamadı: $e');
    }
  }

  Future<void> updateGameState(String sessionId, GameSession updatedSession) async {
    try {
      await _repository.updateGameSession(updatedSession);
    } catch (e) {
      throw Exception('Oyun durumu güncellenemedi: $e');
    }
  }

  bool isHost(GameSession session) {
    return session.hostDeviceId == _deviceId;
  }

  bool isConnected(GameSession session) {
    return session.connectedDeviceIds.contains(_deviceId) || 
           session.hostDeviceId == _deviceId;
  }

  int getConnectedPlayerCount(GameSession session) {
    return session.connectedDeviceIds.length + 1; // +1 for host
  }
}
