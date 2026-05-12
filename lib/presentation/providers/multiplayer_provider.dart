import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock providers for multiplayer functionality
final gameCodeProvider = Provider<String>((ref) => '');

final playerListProvider = Provider<List<Map<String, dynamic>>>((ref) => []);

final isGameStartedProvider = Provider<bool>((ref) => false);

final playerCountProvider = Provider<int>((ref) => 0);
