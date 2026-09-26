import 'package:arabic_learning_game/views/worlds_view.dart';
import 'package:flutter/material.dart';
import 'package:arabic_learning_game/views/settings_dialog.dart';
import 'package:arabic_learning_game/main.dart';
import 'package:arabic_learning_game/classes/constants.dart' as Constants;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'NotoKufi',
        primarySwatch: Constants.primary,
        scaffoldBackgroundColor: Constants.FORTH_COLOR,
        dialogTheme:
            const DialogThemeData(backgroundColor: Constants.THIRD_COLOR),
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black87,
            displayColor: Colors.black87,
            fontFamily: 'NotoKufi'),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: Constants.SECOND_COLOR,
        textStyle: const TextStyle(fontSize: 40, color: Constants.FORTH_COLOR),
        fixedSize: Size(224, 77));
    void _openSettingsDialog() {
      Navigator.of(context).push(MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return SettingsDialog();
          },
          fullscreenDialog: true));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  flex: 10,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () async {
                      await databaseService.getImageInfo(5);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WorldsView()));
                    },
                    child: const Text(
                      'ابدأ',
                      style: TextStyle(
                          color: Constants.TEXT_COLOR, fontFamily: 'Notokufi'),
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      _openSettingsDialog();
                    },
                    child: const Text(
                      'خيارات',
                      style: TextStyle(
                          color: Constants.TEXT_COLOR, fontFamily: 'Notokufi'),
                    ),
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {},
                    child: const Text(
                      'عن اللعبة',
                      style: TextStyle(
                          color: Constants.TEXT_COLOR, fontFamily: 'Notokufi'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
