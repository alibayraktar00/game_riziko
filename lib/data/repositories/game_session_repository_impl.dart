import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../models/game_session_model.dart';

class GameSessionRepositoryImpl implements GameSessionRepository {
  final FirebaseFirestore _firestore;
  final GameSessionModel _model;

  GameSessionRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _model = GameSessionModel(
         id: '',
         teams: [],
         currentTeamIndex: 0,
         availableQuestions: [],
         createdAt: DateTime.now(),
         connectedDeviceIds: [],
         isMultiplayer: false,
         status: GameStatus.waiting,
       );

  @override
  Future<GameSession> createGameSession(GameSession session) async {
    final docRef = _firestore.collection('game_sessions').doc(session.id);
    await docRef.set(_model.toFirestore(session));
    return session;
  }

  @override
  Future<GameSession?> getGameSession(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) return null;
    
    return _model.fromFirestore(docSnapshot);
  }

  @override
  Future<void> updateGameSession(GameSession session) async {
    final docRef = _firestore.collection('game_sessions').doc(session.id);
    await docRef.update(_model.toFirestore(session));
  }

  @override
  Stream<GameSession?> watchGameSession(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snapshot) => snapshot.exists 
            ? _model.fromFirestore(snapshot) 
            : null);
  }

  @override
  Future<void> deleteGameSession(String sessionId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    await docRef.delete();
  }

  @override
  Future<List<GameSession>> getActiveGameSessions() async {
    final querySnapshot = await _firestore
        .collection('game_sessions')
        .where('status', whereIn: ['waiting', 'inProgress'])
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return querySnapshot.docs
        .map((doc) => _model.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> joinGameSession(String sessionId, String deviceId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      
      if (!docSnapshot.exists) {
        throw Exception('Game session not found');
      }

      final session = _model.fromFirestore(docSnapshot);
      final updatedDeviceIds = [...session.connectedDeviceIds, deviceId];
      
      transaction.update(docRef, {
        'connectedDeviceIds': updatedDeviceIds,
      });
    });
  }

  @override
  Future<void> leaveGameSession(String sessionId, String deviceId) async {
    final docRef = _firestore.collection('game_sessions').doc(sessionId);
    
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      
      if (!docSnapshot.exists) return;

      final session = _model.fromFirestore(docSnapshot);
      final updatedDeviceIds = session.connectedDeviceIds
          .where((id) => id != deviceId)
          .toList();
      
      transaction.update(docRef, {
        'connectedDeviceIds': updatedDeviceIds,
      });
    });
  }
}
