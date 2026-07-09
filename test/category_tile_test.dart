import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riziko/presentation/widgets/category_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders title and icon, and reports taps', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(wrap(CategoryTile(
      icon: Icons.science_rounded,
      accentColor: const Color(0xFF00E5FF),
      title: 'BİLİM',
      selected: false,
      onTap: () => tapCount++,
    )));

    expect(find.text('BİLİM'), findsOneWidget);
    expect(find.byIcon(Icons.science_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget); // present but faded/scaled to 0

    await tester.tap(find.byType(InkWell));
    expect(tapCount, 1);
  });

  testWidgets('selected tile shows a fully opaque check badge', (tester) async {
    await tester.pumpWidget(wrap(CategoryTile(
      icon: Icons.public_rounded,
      accentColor: const Color(0xFF00E676),
      title: 'COĞRAFYA',
      selected: true,
      onTap: () {},
    )));
    await tester.pumpAndSettle();

    final opacityWidget = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacityWidget.opacity, 1.0);
  });

  testWidgets('unselected tile keeps the check badge hidden', (tester) async {
    await tester.pumpWidget(wrap(CategoryTile(
      icon: Icons.public_rounded,
      accentColor: const Color(0xFF00E676),
      title: 'COĞRAFYA',
      selected: false,
      onTap: () {},
    )));
    await tester.pumpAndSettle();

    final opacityWidget = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacityWidget.opacity, 0.0);
  });
}
