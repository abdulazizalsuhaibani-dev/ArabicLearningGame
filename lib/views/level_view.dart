import 'package:arabic_learning_game/views/worlds_view.dart';
import 'package:flutter/material.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/classes/level_config.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabic_learning_game/classes/constants.dart' as Constants;

// Level Menu
class LevelView extends StatefulWidget {
  final int world;
  final int level;
  // Loads the image for each question; tests pass a fake instead of the DB.
  final Future<CaptchaImage> Function() loadImage;
  const LevelView(
      {super.key,
      required this.world,
      required this.level,
      this.loadImage = CaptchaImage.random});

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> {
  int questionCount = 0;
  List<CheckIcon> checkIcons = [];
  late int leveltype;
  bool get isMcq => mcqQuestionTypes.contains(leveltype);
  String? randChar;
  // The current question's image and answers, loaded once per question.
  late Future<(CaptchaImage, List<Answer>)> _question;
  int worldCount = 0, numberOffails = 0, cyberCount = 0;
  final String question1 = 'كم عدد النقاط في الصورة؟';
  final String question2 = 'هل توجد اي نقطة بالصورة؟'; //
  final String question3 = 'كم عدد الاحرف بالصورة؟';
  String question4 =
      'هل الاحرف بالصورة (يساوي - اكبر من - اصغر من)(رقم) بالصورة؟'; //
  String question5 = '';
  String question6 = 'هل يوجد حرف (يتم اختيار حرف عشوائي)؟'; //
  final String question7 = 'كم عدد حروف المد؟';
  final String question8 = ' هل يوجد حرف مد؟'; //
  final String question9 = 'هل الأحرف متصلة أو منفصلة؟'; //
  final List<String> cyberAdvice = [
    'لا تنشر صورك عبر برامج التواصل الإجتماعي',
    'لا ترسل بيانات البطاقة البنكية لأي شخص',
    'لا تزود أي شخص معلوماتك الخاصة أو عناوين اتصال',
    'لا تفتح أي مرفق في البريد الإلكتروني إلا إذا كان المرسل معروف لديك',
    'لا تستجيب لأي رسالة أو طلب إذا لم تفهم معناها وأخبر والديك عنها مباشرة',
    'اختر كلمات مرور قوية ولاتشاركها مع أحد مطلقاً',
    'في حال تعرضك للتنمر أخبر والديك فوراً',
    'لا تنشر الشائعات قد تؤذي غيرك',
    'لا تفتح الروابط غير المعروفة إلا بعد أن تتأكد من صحتها',
    'حدِّث برامج تصفح الإنترنت واطلب المساعدة من والديك لتحديثها'
  ];
  @override
  void initState() {
    super.initState();
    leveltype = pickQuestionType(widget.world, widget.level);
    _loadQuestion();
    _loadWorldCount();
    _loadCyberCount();
  }

  void _loadQuestion() {
    _question = widget.loadImage().then((image) => (
          image,
          isMcq
              ? setPossibleMultipleChoicesAnswers(image)
              : setPossibleTrueFalseAnswers(image)
        ));
  }

  void _loadWorldCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      worldCount = (prefs.getInt('worldCount') ?? 110);
    });
  }

  void _loadCyberCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cyberCount = (prefs.getInt('cyberCount') ?? 0);
    });
  }

  void _incrementLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      worldCount = (prefs.getInt('worldCount') ?? 0) + 10;

      if (worldCount % 100 == 40) {
        worldCount += 70;
      }
      prefs.setInt('worldCount', worldCount);
    });
  }

  void _incrementCyberCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cyberCount = (prefs.getInt('cyberCount') ?? 0) + 1;
      prefs.setInt('cyberCount', cyberCount);
    });
  }

  void showDialogs(bool? isCorrect) {
    List<Widget> actions;
    if (isCorrect == true) {
      if (questionCount >= 4) {
        actions = [
          Icon(
            Icons.emoji_emotions_outlined,
            color: Colors.yellowAccent,
            size: 100,
          ),
          Text(
            "!مبروك\nلقد تجاوزت المرحلة!",
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
              onPressed: () {
                _incrementLevel();
                _incrementCyberCount();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorldsView(),
                  ),
                );
                showCyberAdvice();
              },
              child: Text("إغلاق"))
        ];
      } else {
        actions = [
          Icon(
            Icons.check,
            color: Colors.green,
            size: 175,
          ),
          Text(
            "! أحسنت",
            style: TextStyle(fontSize: 30),
          ),
          ElevatedButton(
              onPressed: () {
                questionCount++;
                leveltype = pickQuestionType(widget.world, widget.level);
                _loadQuestion();
                checkIcons.add(CheckIcon());
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text("السؤال التالي"))
        ];
      }
    } else {
      actions = [
        Icon(
          Icons.cancel,
          color: Colors.red,
          size: 100,
        ),
        Text(
          "إجابة خاطئة!",
          style: TextStyle(fontSize: 20),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              numberOffails++;
            },
            child: Text("إغلاق"))
      ];
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions,
              ),
            ),
          );
        });
  }

  void showCyberAdvice() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'نصيحة',
                    style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    cyberAdvice[cyberCount],
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget decideQuestionType() {
    return FutureBuilder(
        future: _question,
        builder: (BuildContext context,
            AsyncSnapshot<(CaptchaImage, List<Answer>)> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // data is available, display it
            final answers = snapshot.data!.$2;
            if (isMcq) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                          child: ElevatedButton(
                        child: Text('${answers[0].answer}'),
                        onPressed: () {
                          showDialogs(answers[0].isCorrect);
                        },
                      )),
                      Flexible(
                          child: ElevatedButton(
                        child: Text('${answers[1].answer}'),
                        onPressed: () {
                          showDialogs(answers[1].isCorrect);
                        },
                      ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                          child: ElevatedButton(
                        child: Text('${answers[2].answer}'),
                        onPressed: () {
                          showDialogs(answers[2].isCorrect);
                        },
                      )),
                      Flexible(
                          child: ElevatedButton(
                        child: Text('${answers[3].answer}'),
                        onPressed: () {
                          showDialogs(answers[3].isCorrect);
                        },
                      ))
                    ],
                  )
                ],
              );
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        child: ElevatedButton(
                      child: Text(
                        '${answers[0].answer}',
                        style: TextStyle(color: Constants.TEXT_COLOR),
                      ),
                      onPressed: () {
                        showDialogs(answers[0].isCorrect);
                      },
                    )),
                    Flexible(
                        child: ElevatedButton(
                      child: Text(
                        '${answers[1].answer}',
                        style: TextStyle(color: Constants.TEXT_COLOR),
                      ),
                      onPressed: () {
                        showDialogs(answers[1].isCorrect);
                      },
                    ))
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // an error occurred while fetching the data, display an error message
            return Text('Error: ${snapshot.error}');
          } else {
            // data is not yet available, display a loading indicator
            return CircularProgressIndicator();
          }
        });
  }

  String getQuestion() {
    switch (leveltype) {
      case 1:
        return question1;
      case 2:
        return question2;
      case 3:
        return question3;
      case 4:
        return question4;
      case 5:
        return question5;
      case 6:
        return question6;
      case 7:
        return question7;
      case 8:
        return question8;
      case 9:
        return question9;
    }
    return '';
  }

  String getRandomCharacter() {
    List<String> arLetters = [
      'ا',
      'ب',
      'ت',
      'ث',
      'ج',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ن',
      'ه',
      'و',
      'ي'
    ];
    return arLetters[Random().nextInt(27)];
  }

  List<Answer> setPossibleMultipleChoicesAnswers(CaptchaImage image) {
    String correctAnswer = '';
    int ans2 = 0, ans3 = 0, ans4 = 0;
    List<Answer> possibleAnswers = [];
    switch (leveltype) {
      case 1:
        correctAnswer = '${image.numberOfPoints}';
        break;
      case 3:
        correctAnswer = image.word.length.toString();
        break;
      case 5:
        String word = image.word;
        randChar = word[Random().nextInt(word.length - 1)];
        correctAnswer = word.indexOf(randChar!).toString();
        break;
      case 7:
        correctAnswer = '${image.numberOfMdLetters}';
    }
    // convert the correct answer to intger
    int correctAnswerNum = int.parse(correctAnswer);
    possibleAnswers.add(Answer(correctAnswer, true));
    //here we check if the correct answer is 0, 1 or 2 so we can avoid nigative numbers in the answers
    if (correctAnswerNum <=
        2) //then make random answers equal to near the correct answer
    {
      ans2 = correctAnswerNum + 1;
      possibleAnswers.add(Answer(ans2.toString(), false));
      ans3 = ans2 + 1;
      possibleAnswers.add(Answer(ans3.toString(), false));

      if (correctAnswerNum == 2) {
        ans4 = correctAnswerNum - 1;
        possibleAnswers.add(Answer(ans4.toString(), false));
      } else {
        ans4 = ans3 + 1;
        possibleAnswers.add(Answer(ans4.toString(), false));
      }
    } else {
      ans2 = correctAnswerNum + 1;
      possibleAnswers.add(Answer(ans2.toString(), false));
      ans3 = correctAnswerNum - 1;
      possibleAnswers.add(Answer(ans3.toString(), false));

      if (Random().nextInt(2) == 0) {
        ans4 = ans2 + 1;
        possibleAnswers.add(Answer(ans4.toString(), false));
      } else {
        ans4 = ans3 - 1;
        possibleAnswers.add(Answer(ans4.toString(), false));
      }
    }
    possibleAnswers.shuffle();
    return possibleAnswers;
  }

  List<Answer> setPossibleTrueFalseAnswers(CaptchaImage image) {
    bool value = false;
    List<Answer> possibleAnswers = [];
    switch (leveltype) {
      case 2:
        value = image.numberOfPoints != 0;
        break;
      case 4:
        //correctAnswer = await CaptchaImage.getWord();
        //correctAnswer = correctAnswer.length.toString();
        break;
      case 6:
        randChar = getRandomCharacter();
        value = image.word.contains(randChar!);
        break;
      case 8:
        value = image.numberOfMdLetters != 0;
        break;
      case 9:
        value = image.isConnected != 'منفصلة';
    }
    if (value) {
      possibleAnswers.add(Answer('خطأ', false));
      possibleAnswers.add(Answer('صح', true));
    } else {
      possibleAnswers.add(Answer('خطأ', true));
      possibleAnswers.add(Answer('صح', false));
    }
    return possibleAnswers;
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF40B4B7),
        textStyle: const TextStyle(fontSize: 40),
        fixedSize: Size(224, 77));
    randChar = getRandomCharacter();
    String question5 = 'ما ترتيب الحرف $randChar ؟';
    return Scaffold(
        appBar: AppBar(
          title: Text(
            ('مرحلة ${widget.level} - سؤال ${questionCount + 1}'),
            style: TextStyle(fontSize: 30, color: Constants.TEXT_COLOR),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${getQuestion()}',
                style: TextStyle(fontSize: 32),
              ),
              Container(
                  child: FutureBuilder(
                      future: _question,
                      builder: (BuildContext context,
                          AsyncSnapshot<(CaptchaImage, List<Answer>)>
                              snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          // data is available, display it
                          return Image.asset(
                              'assets/images/${snapshot.data!.$1.image}');
                        } else if (snapshot.hasError) {
                          // an error occurred while fetching the data, display an error message
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // data is not yet available, display a loading indicator
                          return CircularProgressIndicator();
                        }
                      })),
              Container(child: decideQuestionType()),
              Container(
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: checkIcons),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        QuestionContainer(
                          qNum: 1,
                        ),
                        QuestionContainer(
                          qNum: 2,
                        ),
                        QuestionContainer(
                          qNum: 3,
                        ),
                        QuestionContainer(
                          qNum: 4,
                        ),
                        QuestionContainer(
                          qNum: 5,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}

class QuestionContainer extends StatelessWidget {
  final int qNum;
  const QuestionContainer({super.key, this.qNum = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ' ${qNum} ',
            style: TextStyle(fontSize: 30),
          ),
          Icon(Icons.done)
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 2.0),
      ),
    );
  }
}

class CheckIcon extends StatefulWidget {
  const CheckIcon({super.key});

  @override
  State<CheckIcon> createState() => _CheckIconState();
}

class _CheckIconState extends State<CheckIcon> {
  bool isChecked = false;

  void _toggle() {
    isChecked = true;
  }

  @override
  Widget build(BuildContext context) {
    return isChecked
        ? Icon(
            Icons.check,
            color: Colors.greenAccent,
          )
        : Icon(Icons.check);
  }
}
