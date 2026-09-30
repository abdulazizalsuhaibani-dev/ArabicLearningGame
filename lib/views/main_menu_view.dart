import 'package:flutter/material.dart';
import 'package:arabic_learning_game/views/worlds_view.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/views/settings_dialog.dart';
import 'package:arabic_learning_game/classes/constants.dart' as constants;

class MyApp extends StatelessWidget {
  final Future<CaptchaImage> Function()? loadImage;
  const MyApp({super.key, this.loadImage});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: false,
      fontFamily: 'NotoKufi',
      primarySwatch: constants.primary,
      scaffoldBackgroundColor: constants.FORTH_COLOR,
      dialogTheme: const DialogThemeData(
        backgroundColor: constants.THIRD_COLOR,
      ),
    );
    return MaterialApp(
      title: 'تعلم العربية',
      // Keep Material 2 typography: M3 fixed line heights squeeze Arabic glyphs.
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: MyHomePage(title: 'تعلم العربية', loadImage: loadImage),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final Future<CaptchaImage> Function()? loadImage;
  const MyHomePage({super.key, required this.title, this.loadImage});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: constants.SECOND_COLOR,
      foregroundColor: Colors.black87,
      textStyle: const TextStyle(fontSize: 32),
      minimumSize: const Size(224, 77),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorldsView(loadImage: loadImage),
                  ),
                ),
                child: const Text('ابدأ'),
              ),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsDialog(),
                    fullscreenDialog: true,
                  ),
                ),
                child: const Text('خيارات'),
              ),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('عن اللعبة'),
                    content: const Text(
                      'تعلم الأحرف العربية من خلال صور الكلمات. أجب عن خمس أسئلة بشكل صحيح لفتح المرحلة التالية، واحصل على نصيحة للأمان على الإنترنت. تتضمن اللعبة ثلاثة عوالم وتسع مراحل.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                ),
                child: const Text('عن اللعبة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
