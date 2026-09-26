import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_game/views/main_menu_view.dart';

void main() {
  testWidgets('Main menu shows start, options and about buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ابدأ'), findsOneWidget);
    expect(find.text('خيارات'), findsOneWidget);
    expect(find.text('عن اللعبة'), findsOneWidget);
  });

  testWidgets('Theme uses Material 2 typography', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final theme = Theme.of(tester.element(find.text('ابدأ')));

    expect(theme.useMaterial3, isFalse);
    // Material 3 text styles force a fixed line height and letter spacing,
    // which squeezes NotoKufi's Arabic glyphs; Material 2 leaves height unset.
    expect(theme.textTheme.bodyMedium!.height, isNull);
    expect(theme.textTheme.bodyMedium!.letterSpacing, isNot(0.25));
    expect(theme.textTheme.bodyMedium!.fontFamily, 'NotoKufi');
    expect(theme.textTheme.bodyMedium!.color, Colors.black87);
  });
}
