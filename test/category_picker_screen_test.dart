import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riziko/domain/entities/question.dart';
import 'package:riziko/presentation/providers/game_provider.dart';
import 'package:riziko/presentation/providers/providers.dart';
import 'package:riziko/presentation/screens/category_picker_screen.dart';
import 'package:riziko/services/settings_service.dart';

Question _q(String category, int difficulty) {
  return Question(
    id: '${category}_$difficulty',
    category: category,
    difficulty: difficulty,
    translations: const {'en': 'q', 'tr': 's'},
    answers: const ['a'],
    keywords: const ['a'],
  );
}

void main() {
  // Static bank + AI-pool style duplicates that only differ by case/whitespace,
  // the exact scenario the dedup fix in category_picker_screen guards against.
  final questions = [
    _q('Science', 1),
    _q(' science ', 2),
    _q('History', 1),
    _q('Geography', 1),
    _q('Sports', 1),
    _q('Entertainment', 1),
  ];

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const CategoryPickerScreen()),
      GoRoute(path: '/team-setup', builder: (_, _) => const Scaffold(body: Text('team-setup'))),
      GoRoute(path: '/category-selection', builder: (_, _) => const Scaffold(body: Text('category-selection'))),
    ]);

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      questionsProvider.overrideWith((ref) => Future.value(questions)),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  // Default locale (no prefs set) is 'tr', so labels render as the Turkish
  // translations, uppercased — this is what the picker actually shows.
  const labels = ['BILIM', 'TARIH', 'COĞRAFYA', 'SPOR', 'EĞLENCE'];

  testWidgets('collapses same-category entries that differ only by case/whitespace', (tester) async {
    await pumpScreen(tester);

    // 6 input questions across 5 distinct categories once "Science" and
    // " science " collapse into one — only one BILIM row should exist.
    expect(find.text('BILIM'), findsOneWidget);
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('start button stays disabled until exactly 5 categories are picked, then works', (tester) async {
    final container = await pumpScreen(tester);

    final startButtonFinder = find.widgetWithText(ElevatedButton, 'OYUNU BAŞLAT');
    expect(tester.widget<ElevatedButton>(startButtonFinder).onPressed, isNull);

    for (final label in labels) {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump();
    }

    expect(find.text('Seçilen: 5 / 5'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(startButtonFinder).onPressed, isNotNull);

    await tester.tap(startButtonFinder);
    await tester.pumpAndSettle();

    // The tile shows the Turkish translation ("BILIM"), but the value it
    // hands to the game provider is the underlying category field from the
    // Question data ("Science") — the two must not be conflated.
    final selected = container.read(gameProvider).selectedCategories.map((c) => c.toLowerCase()).toSet();
    expect(selected, {'science', 'history', 'geography', 'sports', 'entertainment'});
    expect(find.text('category-selection'), findsOneWidget);
  });

  testWidgets('re-tapping a selected category deselects it instead of exceeding the limit', (tester) async {
    await pumpScreen(tester);

    for (final label in labels) {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump();
    }
    expect(find.text('Seçilen: 5 / 5'), findsOneWidget);

    final bilimFinder = find.text('BILIM');
    await tester.ensureVisible(bilimFinder);
    await tester.pumpAndSettle();
    await tester.tap(bilimFinder);
    await tester.pump();
    expect(find.text('Seçilen: 4 / 5'), findsOneWidget);
  });
}
