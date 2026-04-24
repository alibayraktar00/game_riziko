import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
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
  ],
);
