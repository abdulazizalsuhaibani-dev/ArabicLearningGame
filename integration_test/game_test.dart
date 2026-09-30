import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:arabic_learning_game/db_servieces.dart';
import 'package:arabic_learning_game/shared_preferences.dart';
import 'package:arabic_learning_game/views/main_menu_view.dart';

// Uses a local database service on Android; never touches main's global service.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native database supports a single image and an empty table', (
    tester,
  ) async {
    final memory = await openDatabase(inMemoryDatabasePath);
    final service = DatabaseService()..captchaDb = memory;
    try {
      await memory.execute(
        'CREATE TABLE images (image_id INTEGER, image TEXT, word TEXT, number_of_points INTEGER, number_of_md_letters INTEGER, is_connected TEXT)',
      );
      await expectLater(service.getRandomImage(), throwsStateError);
      await memory.insert('images', {
        'image_id': 40,
        'image': '888_4.png',
        'word': 'زغشنة',
        'number_of_points': 8,
        'number_of_md_letters': 0,
        'is_connected': 'F',
      });
      expect((await service.getRandomImage()).imageId, 40);
    } finally {
      await memory.close();
    }
  });

  testWidgets('all nine levels save progress and show rewards on Android', (
    tester,
  ) async {
    final service = DatabaseService();
    await service.prepareDatabases();
    final rows = await service.captchaDb.query('images');
    final byImage = {for (final row in rows) row['image'] as String: row};
    expect(rows, hasLength(40));
    // Check every bundled row points to a decodable image.
    for (final filename in byImage.keys) {
      final data = await rootBundle.load('assets/images/$filename');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      codec.dispose();
    }
    await GameProgress.reset();
    await tester.pumpWidget(MyApp(loadImage: service.getRandomImage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();

    for (var type = 1; type <= 9; type++) {
      final current = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed != null,
      );
      expect(current, findsOneWidget);
      await tester.ensureVisible(current);
      await tester.tap(current);
      await tester.pumpAndSettle();
      for (var question = 1; question <= 5; question++) {
        final image = tester.widget<Image>(find.byType(Image));
        final filename = (image.image as AssetImage).assetName.split('/').last;
        final row = byImage[filename]!;
        final questionText = tester
            .widget<Text>(
              find.byWidgetPredicate(
                (widget) => widget is Text && widget.style?.fontSize == 26,
              ),
            )
            .data!;
        final answer = correctAnswer(type, questionText, row);
        if (type == 1 && question == 1) {
          final wrong = find.byWidgetPredicate(
            (widget) =>
                widget is ElevatedButton &&
                (widget.child as Text).data != answer,
          );
          await tester.tap(wrong.first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('حاول مرة أخرى'));
          await tester.pumpAndSettle();
          expect(
            (tester.widget<Image>(find.byType(Image)).image as AssetImage)
                .assetName,
            'assets/images/$filename',
          );
          expect((await GameProgress.load()).worldCount, 110);
        }
        await tester.tap(find.widgetWithText(ElevatedButton, answer));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(question == 5 ? 'إكمال المرحلة' : 'السؤال التالي'),
        );
        await tester.pumpAndSettle();
      }
      final progress = await GameProgress.load();
      expect(
        progress.worldCount,
        [120, 130, 210, 220, 230, 310, 320, 330, 410][type - 1],
      );
      expect(progress.cyberCount, type - 1);
      expect(find.byType(AlertDialog), findsOneWidget);
      if (type == 1) {
        expect(
          find.text('لا تنشر صورك عبر برامج التواصل الاجتماعي'),
          findsOneWidget,
        );
      }
      if (type == 9) {
        expect(find.text('مبروك! أكملت جميع العوالم'), findsOneWidget);
      }
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();
    }
    // Recreate the widget tree to verify saved completion is loaded.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(MyApp(loadImage: service.getRandomImage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();
    expect(find.text('أحسنت! أكملت جميع المراحل.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('خيارات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إعادة اللعبة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إعادة التعيين'));
    await tester.pumpAndSettle();
    expect((await GameProgress.load()).worldCount, 110);
    expect((await GameProgress.load()).cyberCount, -1);
    await service.captchaDb.close();
  });
}

String correctAnswer(int type, String question, Map<String, Object?> row) {
  final word = row['word'] as String;
  switch (type) {
    case 1:
      return '${row['number_of_points']}';
    case 2:
      return (row['number_of_points'] as int) > 0 ? 'صح' : 'خطأ';
    case 3:
      return '${word.length}';
    case 4:
      final target = int.parse(RegExp(r'\d+').firstMatch(question)!.group(0)!);
      final matches = question.contains('أكبر من')
          ? word.length > target
          : question.contains('أصغر من')
          ? word.length < target
          : word.length == target;
      return matches ? 'صح' : 'خطأ';
    case 5:
      final letter = RegExp(r'للحرف (.)').firstMatch(question)!.group(1)!;
      return '${word.indexOf(letter) + 1}';
    case 6:
      final letter = RegExp(r'حرف (.) في').firstMatch(question)!.group(1)!;
      return word.contains(letter) ? 'صح' : 'خطأ';
    case 7:
      return '${row['number_of_md_letters']}';
    case 8:
      return (row['number_of_md_letters'] as int) > 0 ? 'صح' : 'خطأ';
    case 9:
      return row['is_connected'] == 'T' ? 'صح' : 'خطأ';
    default:
      throw ArgumentError.value(type);
  }
}
