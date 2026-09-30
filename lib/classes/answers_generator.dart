import 'dart:math';

class CaptchaImage {
  final int imageId;
  final String image;
  final String word;
  final int numberOfPoints;
  final int numberOfMdLetters;
  final bool isConnected;

  const CaptchaImage({
    required this.imageId,
    required this.image,
    required this.word,
    required this.numberOfPoints,
    required this.numberOfMdLetters,
    required this.isConnected,
  });

  factory CaptchaImage.fromRow(Map<String, dynamic> row) => CaptchaImage(
    imageId: row['image_id'] as int,
    image: row['image'] as String,
    word: row['word'] as String,
    numberOfPoints: row['number_of_points'] as int,
    numberOfMdLetters: row['number_of_md_letters'] as int,
    isConnected: (row['is_connected'] as String).trim().toUpperCase() == 'T',
  );

  // Ignore spaces, tashkeel and tatweel when counting or locating letters.
  static List<String> lettersOf(String word) =>
      RegExp(r'[\u0621-\u063A\u0641-\u064A]')
          .allMatches(word)
          .map((match) => match.group(0)!)
          .toList();
  List<String> get letters => lettersOf(word);
}

class Answer {
  final String answer;
  final bool isCorrect;
  const Answer(this.answer, this.isCorrect);
}

class GameQuestion {
  final CaptchaImage image;
  final String text;
  final List<Answer> answers;
  GameQuestion._(this.image, this.text, List<Answer> answers)
    : answers = List.unmodifiable(answers);

  static GameQuestion generate(CaptchaImage image, int type, {Random? random}) {
    final rng = random ?? Random();
    final letters = image.letters;
    if (letters.isEmpty) {
      throw const FormatException('CAPTCHA has no Arabic letters');
    }
    String text;
    int? number;
    bool? value;
    switch (type) {
      case 1:
        text = 'كم عدد النقاط في الصورة؟';
        number = image.numberOfPoints;
      case 2:
        text = 'هل توجد أي نقطة في الصورة؟';
        value = image.numberOfPoints > 0;
      case 3:
        text = 'كم عدد الأحرف في الصورة؟';
        number = letters.length;
      case 4:
        final target = rng.nextInt(letters.length + 3) + 1;
        final comparison = rng.nextInt(3);
        final label = ['يساوي', 'أكبر من', 'أصغر من'][comparison];
        text = 'هل عدد الأحرف في الصورة $label $target؟';
        value = switch (comparison) {
          0 => letters.length == target,
          1 => letters.length > target,
          _ => letters.length < target,
        };
      case 5:
        final letter = letters[rng.nextInt(letters.length)];
        text = 'ما ترتيب أول ظهور للحرف $letter؟ (ابدأ من 1)';
        number = letters.indexOf(letter) + 1;
      case 6:
        const alphabet = 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي';
        final letter = rng.nextBool()
            ? letters[rng.nextInt(letters.length)]
            : alphabet[rng.nextInt(alphabet.length)];
        text = 'هل يوجد حرف $letter في الصورة؟';
        value = letters.contains(letter);
      case 7:
        text = 'كم عدد حروف المد في الصورة؟';
        number = image.numberOfMdLetters;
      case 8:
        text = 'هل يوجد حرف مد في الصورة؟';
        value = image.numberOfMdLetters > 0;
      case 9:
        text = 'هل الأحرف في الصورة متصلة؟';
        value = image.isConnected;
      default:
        throw ArgumentError.value(
          type,
          'type',
          'Expected a question type from 1 to 9',
        );
    }
    if (number == null) {
      return GameQuestion._(image, text, [
        Answer('صح', value!),
        Answer('خطأ', !value),
      ]);
    }
    final choices = <int>{number};
    for (var distance = 1; choices.length < 4; distance++) {
      final candidates = [number + distance, number - distance]..shuffle(rng);
      for (final candidate in candidates) {
        if (candidate >= 0 && choices.length < 4) choices.add(candidate);
      }
    }
    final answers = choices.map((n) => Answer('$n', n == number)).toList()
      ..shuffle(rng);
    return GameQuestion._(image, text, answers);
  }
}
