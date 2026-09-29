import 'dart:math';

// Question types (see LevelView.getQuestion):
// 1 = count the dots, 3 = count the letters, 7 = count the madd letters,
// 8 = is there a madd letter? (true/false).
// Types 2, 4, 5, 6 and 9 are not ready yet and must not be listed here.
const Map<int, List<List<int>>> levelQuestionTypes = {
  // World 1 introduces one question type per level.
  1: [
    [1],
    [3],
    [8],
  ],
  // World 2 adds madd counting and starts mixing types.
  2: [
    [7],
    [1, 3],
    [7, 8],
  ],
  // World 3 mixes everything.
  3: [
    [1, 7],
    [3, 8],
    [1, 3, 7, 8],
  ],
};

// Multiple-choice types; every other type is answered with true/false.
const Set<int> mcqQuestionTypes = {1, 3, 5, 7};

// Picks the question type for the next question of [level] (1-3) in [world].
int pickQuestionType(int world, int level, [Random? random]) {
  final types = levelQuestionTypes[world]?[level - 1] ?? const [1];
  return types[(random ?? Random()).nextInt(types.length)];
}
