import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/team_setup_screen.dart';
import '../../presentation/screens/category_selection_screen.dart';
import '../../presentation/screens/custom_question_screen.dart';
import '../../presentation/screens/difficulty_selection_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/leaderboard_screen.dart';
import '../../presentation/screens/question_screen.dart';
import '../../presentation/screens/scoreboard_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';
import '../../presentation/screens/qr_display_screen.dart';
import '../../presentation/screens/multiplayer_lobby_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
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
        final args = state.extra as Map<String, dynamic>;
        return QuestionScreen(
          category: args['category'] as String,
          difficulty: args['difficulty'] as int,
        );
      },
    ),
    GoRoute(
      path: '/scoreboard',
      builder: (context, state) => const ScoreboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/custom-question',
      builder: (context, state) => const CustomQuestionScreen(),
    ),
    GoRoute(
      path: '/multiplayer/scan',
      builder: (context, state) => const QRScannerScreen(),
    ),
    GoRoute(
      path: '/multiplayer/qr/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return QRDisplayScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/multiplayer/lobby/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return MultiplayerLobbyScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/multiplayer/join/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return MultiplayerLobbyScreen(sessionId: sessionId);
      },
    ),
  ],
);
