import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final failedKey in ['flutter.cyberCount', 'flutter.worldCount']) {
    test(
      'completion reports a failed write to $failedKey and reloads saved progress',
      () async {
        SharedPreferences.setMockInitialValues({});
        final original = SharedPreferencesStorePlatform.instance;
        SharedPreferencesStorePlatform.instance = FailingStore(failedKey);
        try {
          await expectLater(GameProgress.completeLevel(110), throwsStateError);
          expect((await GameProgress.load()).worldCount, 110);
        } finally {
          SharedPreferencesStorePlatform.instance = original;
          SharedPreferences.resetStatic();
        }
      },
    );
  }
  test('reset reports a failed save instead of pretending to finish', () async {
    SharedPreferences.setMockInitialValues({});
    final original = SharedPreferencesStorePlatform.instance;
    SharedPreferencesStorePlatform.instance = FailingStore(
      'flutter.worldCount',
    );
    try {
      await expectLater(GameProgress.reset(), throwsStateError);
    } finally {
      SharedPreferencesStorePlatform.instance = original;
      SharedPreferences.resetStatic();
    }
  });
  test('database connection flags produce the correct true false answer', () {
    for (final flag in ['T', 'F']) {
      final row = CaptchaImage.fromRow({
        'image_id': 1,
        'image': '140_4.png',
        'word': 'باب',
        'number_of_points': 2,
        'number_of_md_letters': 1,
        'is_connected': flag,
      });
      final question = GameQuestion.generate(row, 9);
      expect(
        question.answers.singleWhere((answer) => answer.isCorrect).answer,
        flag == 'T' ? 'صح' : 'خطأ',
      );
    }
  });
  const image = CaptchaImage(
    imageId: 1,
    image: '140_4.png',
    word: 'بَاب',
    numberOfPoints: 2,
    numberOfMdLetters: 1,
    isConnected: true,
  );

  test('Arabic letter counts ignore vowel marks and spaces', () {
    expect(image.letters, ['ب', 'ا', 'ب']);
    expect(CaptchaImage.lettersOf('أ بـيّ'), ['أ', 'ب', 'ي']);
  });

  test('all nine question types have one correct answer', () {
    for (var type = 1; type <= 9; type++) {
      for (var seed = 0; seed < 40; seed++) {
        final question = GameQuestion.generate(
          image,
          type,
          random: Random(seed),
        );
        expect(question.text, isNotEmpty);
        expect(question.answers.where((a) => a.isCorrect), hasLength(1));
        expect(
          question.answers.map((a) => a.answer).toSet().length,
          question.answers.length,
        );
        expect(question.answers.length, [1, 3, 5, 7].contains(type) ? 4 : 2);
      }
    }
  });

  test('numeric choices are nonnegative even when the answer is zero', () {
    const emptyPoints = CaptchaImage(
      imageId: 2,
      image: '140_4.png',
      word: 'ا',
      numberOfPoints: 0,
      numberOfMdLetters: 0,
      isConnected: false,
    );
    for (final type in [1, 3, 5, 7]) {
      final question = GameQuestion.generate(
        emptyPoints,
        type,
        random: Random(1),
      );
      expect(question.answers.every((a) => int.parse(a.answer) >= 0), isTrue);
    }
  });

  test('letter position identifies the first occurrence starting at one', () {
    for (var seed = 0; seed < 30; seed++) {
      final question = GameQuestion.generate(image, 5, random: Random(seed));
      final correct = int.parse(
        question.answers.singleWhere((a) => a.isCorrect).answer,
      );
      final letter = image.letters[correct - 1];
      expect(question.text, contains(letter));
      expect(correct, image.letters.indexOf(letter) + 1);
    }
  });

  test('progress initializes without overwriting existing saves', () async {
    SharedPreferences.setMockInitialValues({
      'worldCount': 220,
      'cyberCount': 3,
    });
    final progress = await GameProgress.load();
    expect(progress.worldCount, 220);
    expect(progress.cyberCount, 3);
  });

  test('nine completions unlock all worlds and stop at the end', () async {
    SharedPreferences.setMockInitialValues({});
    var progress = await GameProgress.load();
    expect(progress.worldCount, 110);
    expect(progress.cyberCount, -1);
    for (final code in [110, 120, 130, 210, 220, 230, 310, 320, 330]) {
      expect(progress.worldCount, code);
      progress = await GameProgress.completeLevel(code);
    }
    expect(progress.worldCount, 410);
    expect(progress.cyberCount, 8);
    expect(progress.isComplete, isTrue);
    final repeated = await GameProgress.completeLevel(330);
    expect(repeated.cyberCount, 8);
    expect((await GameProgress.load()).worldCount, 410);
    await GameProgress.reset();
    expect((await GameProgress.load()).worldCount, 110);
    expect((await GameProgress.load()).cyberCount, -1);
  });

  test('locked levels cannot advance saved progress', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = await GameProgress.completeLevel(210);
    expect(progress.worldCount, 110);
    expect(progress.cyberCount, -1);
  });
}

class FailingStore extends InMemorySharedPreferencesStore {
  final String failedKey;
  FailingStore(this.failedKey)
    : super.withData({'flutter.worldCount': 110, 'flutter.cyberCount': -1});
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == failedKey) return false;
    return super.setValue(valueType, key, value);
  }
}
