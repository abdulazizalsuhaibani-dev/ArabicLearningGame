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
}
