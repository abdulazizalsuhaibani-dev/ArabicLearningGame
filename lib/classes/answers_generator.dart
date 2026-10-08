import 'package:arabic_learning_game/main.dart';

// One row of the `images` table: a CAPTCHA picture and the facts the
// questions ask about.
class CaptchaImage {
  final String image;
  final String word;
  final int numberOfPoints;
  final int numberOfMdLetters;
  final String isConnected;

  const CaptchaImage({
    required this.image,
    required this.word,
    required this.numberOfPoints,
    required this.numberOfMdLetters,
    required this.isConnected,
  });

  CaptchaImage.fromRow(Map<String, dynamic> row)
    : image = row['image'],
      word = row['word'],
      numberOfPoints = row['number_of_points'],
      numberOfMdLetters = row['number_of_md_letters'],
      isConnected = row['is_connected'];

  // Loads a random image from the bundled database.
  static Future<CaptchaImage> random() async =>
      CaptchaImage.fromRow(await databaseService.getRandomImage());
}

class Answer {
  String? answer;
  bool? isCorrect;
  Answer(String answer, bool isCorrect) {
    this.answer = answer;
    this.isCorrect = isCorrect;
  }
}
/*
 static Future<void> setPossibleAnswers() async {
    _correctAnswer = imageQuery!['number_of_points'];
    _possibleAnswers.add(Answer(_correctAnswer, true));
    for (var i = 0; i < 3; i++) {
      int wrongAnswer = Random().nextInt(10);
      _possibleAnswers.add(Answer(wrongAnswer.toString(), false));
    }
    print(_possibleAnswers);
    _possibleAnswers.shuffle();
  }

  static Future<List<Answer>> getPossibleAnswers() async {
    return _possibleAnswers;
  }
}
*/
