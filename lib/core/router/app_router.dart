import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/admin_screen.dart';
import '../../presentation/screens/qr_scan_screen.dart';
import '../../presentation/screens/nickname_screen.dart';
import '../../presentation/screens/waiting_screen.dart';
import '../../presentation/screens/game_mode_selection_screen.dart';
import '../../presentation/screens/team_setup_screen.dart';
import '../../presentation/screens/category_selection_screen.dart';
import '../../presentation/screens/difficulty_selection_screen.dart';
import '../../presentation/screens/question_screen.dart';
import '../../presentation/screens/scoreboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/mode-selection',
      builder: (context, state) => const GameModeSelectionScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const QRScanScreen(),
    ),
    GoRoute(
      path: '/nickname',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'] ?? '';
        return NicknameScreen(gameCode: code);
      },
    ),
    GoRoute(
      path: '/waiting',
      builder: (context, state) {
        final uri = state.uri;
        final code = uri.queryParameters['code'] ?? '';
        final playerId = uri.queryParameters['playerId'] ?? '';
        return WaitingScreen(
          gameCode: code,
          playerId: playerId,
        );
      },
    ),
    GoRoute(
      path: '/team-setup',
      builder: (context, state) => const TeamSetupScreen(),
    ),
    GoRoute(
      path: '/category-selection',
      builder: (context, state) => const CategorySelectionScreen(),
    ),
    GoRoute(
      path: '/difficulty-selection',
      builder: (context, state) {
        final category = state.extra as String;
        return DifficultySelectionScreen(category: category);
      },
    ),
    GoRoute(
      path: '/question',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return QuestionScreen(
          category: extra['category'] as String,
          difficulty: extra['difficulty'] as int,
        );
      },
    ),
    GoRoute(
      path: '/scoreboard',
      builder: (context, state) => const ScoreboardScreen(),
    ),
    GoRoute(
      path: '/game/:gameCode',
      builder: (context, state) {
        // TODO: Create GameScreen
        return const Scaffold(
          body: Center(
            child: Text('Game Screen - Coming Soon'),
          ),
        );
      },
    ),
  ],
);
