import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_game/classes/level_config.dart';

void main() {
  // Question types whose question text and answer generation are complete.
  const readyTypes = {1, 3, 7, 8};

  test('every world has three levels using only ready question types', () {
    for (final world in [1, 2, 3]) {
      final levels = levelQuestionTypes[world]!;
      expect(levels, hasLength(3), reason: 'world $world');
      for (final types in levels) {
        expect(types, isNotEmpty, reason: 'world $world');
        expect(
          readyTypes.containsAll(types),
          isTrue,
          reason: 'world $world uses $types',
        );
      }
    }
  });

  test('levels do not all ask the same question type', () {
    final allTypes = levelQuestionTypes.values
        .expand((l) => l)
        .expand((t) => t);
    expect(allTypes.toSet(), readyTypes);
  });

  test('pickQuestionType only returns types listed for that level', () {
    final random = Random(0);
    for (final world in [1, 2, 3]) {
      for (final level in [1, 2, 3]) {
        final allowed = levelQuestionTypes[world]![level - 1];
        for (var i = 0; i < 20; i++) {
          expect(allowed, contains(pickQuestionType(world, level, random)));
        }
      }
    }
  });

  test('pickQuestionType falls back to type 1 for an unknown level', () {
    expect(pickQuestionType(9, 1), 1);
  });
}
