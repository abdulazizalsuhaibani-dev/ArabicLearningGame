import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/views/level_view.dart';
import 'helpers/settle.dart';

const sample = CaptchaImage(
  imageId: 1,
  image: '140_4.png',
  word: 'باب',
  numberOfPoints: 2,
  numberOfMdLetters: 1,
  isConnected: true,
);

void main() {
  testWidgets('corrupt image bytes cannot present answer buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: CorruptAssetBundle(),
        child: MaterialApp(
          home: LevelView(
            levelCode: 110,
            loadImage: () async => const CaptchaImage(
              imageId: 2,
              image: 'corrupt.png',
              word: 'باب',
              numberOfPoints: 2,
              numberOfMdLetters: 1,
              isConnected: false,
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('تعذر تحميل السؤال. حاول مرة أخرى.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '2'), findsNothing);
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'waits for an image and keeps the question stable on wrong answers',
    (tester) async {
      final pending = Completer<CaptchaImage>();
      var loads = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LevelView(
            levelCode: 110,
            loadImage: () {
              loads++;
              return pending.future;
            },
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete(sample);
      await settle(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, '3'));
      await settle(tester);
      expect(find.text('إجابة خاطئة!'), findsOneWidget);
      await tester.tap(find.text('حاول مرة أخرى'));
      await settle(tester);
      expect(find.text('العالم 1 - مرحلة 1 - سؤال 1'), findsOneWidget);
      expect(loads, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('five correct answers save progress before returning the tip', (
    tester,
  ) async {
    int? tip;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                tip = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelView(
                      levelCode: 110,
                      loadImage: () async => sample,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.widgetWithText(ElevatedButton, '2'));
      await settle(tester);
      await tester.tap(find.text(i == 4 ? 'إكمال المرحلة' : 'السؤال التالي'));
      await settle(tester);
    }
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('worldCount'), 120);
    expect(prefs.getInt('cyberCount'), 0);
    expect(tip, 0);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('failed image load offers a working retry', (tester) async {
    var loads = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LevelView(
          levelCode: 110,
          loadImage: () async {
            if (loads++ == 0) throw StateError('empty database');
            return sample;
          },
        ),
      ),
    );
    await settle(tester);
    expect(find.text('تعذر تحميل السؤال. حاول مرة أخرى.'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await settle(tester);
    expect(find.text('كم عدد النقاط في الصورة؟'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing during loading does not update a removed screen', (
    tester,
  ) async {
    final pending = Completer<CaptchaImage>();
    await tester.pumpWidget(
      MaterialApp(
        home: LevelView(levelCode: 110, loadImage: () => pending.future),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    pending.complete(sample);
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing image asset cannot present answer buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LevelView(
          levelCode: 110,
          loadImage: () async => const CaptchaImage(
            imageId: 2,
            image: 'missing.png',
            word: 'باب',
            numberOfPoints: 2,
            numberOfMdLetters: 1,
            isConnected: false,
          ),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('تعذر تحميل السؤال. حاول مرة أخرى.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '2'), findsNothing);
  });
}

class CorruptAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/images/corrupt.png') {
      return ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
    }
    return rootBundle.load(key);
  }
}
