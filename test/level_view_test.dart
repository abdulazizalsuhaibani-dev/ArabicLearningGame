import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/views/level_view.dart';

// A row from db/game_db.db, so the image asset exists.
const testImage = CaptchaImage(
  image: '301_4.png',
  word: 'اسجث',
  numberOfPoints: 4,
  numberOfMdLetters: 1,
  isConnected: 'F',
);

void main() {
  var loads = 0;

  setUp(() {
    loads = 0;
    SharedPreferences.setMockInitialValues({'worldCount': 110});
  });

  Widget levelApp(int world, int level) => MaterialApp(
    home: LevelView(
      world: world,
      level: level,
      loadImage: () async {
        loads++;
        return testImage;
      },
    ),
  );

  Future<void> pumpLevel(WidgetTester tester, int world, int level) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(levelApp(world, level));
    await tester.pumpAndSettle();
    expect(find.textContaining('Error'), findsNothing);
  }

  testWidgets('first question shows its image and answers without errors', (
    WidgetTester tester,
  ) async {
    // World 1, level 3 asks "is there a madd letter?" (type 8).
    await pumpLevel(tester, 1, 3);

    expect(find.text(' هل يوجد حرف مد؟'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('صح'), findsOneWidget);
    expect(find.text('خطأ'), findsOneWidget);
    expect(loads, 1);
  });

  testWidgets('multiple-choice answers come from the loaded image', (
    WidgetTester tester,
  ) async {
    // World 1, level 1 asks how many dots (type 1); the image has 4.
    await pumpLevel(tester, 1, 1);

    expect(find.text('كم عدد النقاط في الصورة؟'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(4));
  });

  testWidgets('rebuilding does not load a new image', (
    WidgetTester tester,
  ) async {
    await pumpLevel(tester, 1, 3);

    // Pumping a new widget configuration runs build() again.
    await tester.pumpWidget(levelApp(1, 3));
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text('صح'), findsOneWidget);
  });

  testWidgets('the next question loads a new image', (
    WidgetTester tester,
  ) async {
    await pumpLevel(tester, 1, 3);

    // The test image has a madd letter, so "صح" is correct.
    await tester.tap(find.text('صح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('السؤال التالي'));
    await tester.pumpAndSettle();

    expect(loads, 2);
    expect(find.text('مرحلة 3 - سؤال 2'), findsOneWidget);
    expect(find.text('صح'), findsOneWidget);
    expect(find.textContaining('Error'), findsNothing);
  });
}
