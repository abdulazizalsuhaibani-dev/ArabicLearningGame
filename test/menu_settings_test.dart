import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabic_learning_game/views/main_menu_view.dart';
import 'package:arabic_learning_game/views/level_view.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'helpers/settle.dart';

void main() {
  testWidgets('duplicate level-open callbacks cannot stack game routes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MyApp(
        loadImage: () async => const CaptchaImage(
          imageId: 1,
          image: '140_4.png',
          word: 'باب',
          numberOfPoints: 2,
          numberOfMdLetters: 1,
          isConnected: true,
        ),
      ),
    );
    await tester.tap(find.text('ابدأ'));
    await settle(tester);
    final current = tester.widget<ElevatedButton>(
      find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed != null,
      ),
    );
    current.onPressed!();
    current.onPressed!();
    await settle(tester);
    expect(find.byType(LevelView, skipOffstage: false), findsOneWidget);
  });
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'worldCount': 220,
      'cyberCount': 3,
    }),
  );

  testWidgets('about button explains the game', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('عن اللعبة'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('خمس'), findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('reset requires confirmation and persists the starting state', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('خيارات'));
    await settle(tester);
    await tester.tap(find.text('إعادة اللعبة'));
    await settle(tester);
    await tester.tap(find.text('إلغاء'));
    await settle(tester);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('worldCount'), 220);
    await tester.tap(find.text('إعادة اللعبة'));
    await settle(tester);
    await tester.tap(find.text('إعادة التعيين'));
    await settle(tester);
    expect(prefs.getInt('worldCount'), 110);
    expect(prefs.getInt('cyberCount'), -1);
    expect(find.text('تمت إعادة اللعبة.'), findsOneWidget);
  });

  testWidgets('start opens worlds without accessing the global database', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('ابدأ'));
    await settle(tester);
    expect(find.text('قائمة العوالم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
