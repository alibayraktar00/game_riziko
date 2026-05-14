import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/realtime_game_session_repository.dart';
import '../../services/multiplayer_service.dart';

final multiplayerRepositoryProvider = Provider((ref) => RealtimeGameSessionRepository());

final multiplayerServiceProvider = Provider((ref) {
  final repository = ref.watch(multiplayerRepositoryProvider);
  return MultiplayerService(repository: repository);
});

// Mock providers for multiplayer functionality (legacy support)
final gameCodeProvider = Provider<String>((ref) => '');
final playerListProvider = Provider<List<Map<String, dynamic>>>((ref) => []);
final isGameStartedProvider = Provider<bool>((ref) => false);
final playerCountProvider = Provider<int>((ref) => 0);
