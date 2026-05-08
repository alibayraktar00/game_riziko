import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/game_session_repository_impl.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../../services/multiplayer_service.dart';
import '../../services/qr_service.dart';

// Firebase Firestore Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Game Session Repository Provider
final gameSessionRepositoryProvider = Provider<GameSessionRepository>((ref) {
  return GameSessionRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

// QR Service Provider
final qrServiceProvider = Provider<QRService>((ref) {
  return QRService();
});

// Multiplayer Service Provider
final multiplayerServiceProvider = Provider<MultiplayerService>((ref) {
  return MultiplayerService(
    repository: ref.watch(gameSessionRepositoryProvider),
  );
});
