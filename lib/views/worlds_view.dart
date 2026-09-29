import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:arabic_learning_game/views/level_view.dart';
import 'package:arabic_learning_game/classes/constants.dart' as Constants;

// Worlds menu view
class WorldsView extends StatefulWidget {
  const WorldsView({super.key});

  @override
  State<WorldsView> createState() => _WorldsViewState();
}

class _WorldsViewState extends State<WorldsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'قائمة العوالم',
            style: TextStyle(
                color: Constants.TEXT_COLOR,
                fontFamily: 'Notokufi',
                fontSize: 30),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              WorldContainer(
                text: 'العالم الأول',
                worldNum: 1,
              ),
              WorldContainer(
                text: 'العالم الثاني',
                worldNum: 2,
              ),
              WorldContainer(
                text: 'العالم الثالث',
                worldNum: 3,
              ),
            ],
          )),
        ));
  }
}

class WorldContainer extends StatefulWidget {
  final int worldNum;
  final String text;
  const WorldContainer({Key? key, this.worldNum = 0, this.text = 'null'})
      : super(key: key);

  @override
  _WorldContainerState createState() => _WorldContainerState();
}

class _WorldContainerState extends State<WorldContainer> {
  bool _isEnabled = false;
  TextStyle _textStyle = TextStyle(
      fontSize: 27, color: Constants.TEXT_COLOR, fontFamily: 'Notokufi');
  BoxDecoration _containerDecoration = BoxDecoration(
    color: Constants.THIRD_COLOR,
    borderRadius: BorderRadius.circular(10.0),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _containerDecoration,
      child: Column(
        children: [
          Text(
            widget.text,
            style: _textStyle,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                LevelButton(
                  levelNum: 10,
                  worldNum: widget.worldNum,
                ),
                LevelButton(
                  levelNum: 20,
                  worldNum: widget.worldNum,
                ),
                LevelButton(
                  levelNum: 30,
                  worldNum: widget.worldNum,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LevelButton extends StatefulWidget {
  final int levelNum;
  final int worldNum;
  const LevelButton({Key? key, this.levelNum = 0, this.worldNum = 0})
      : super(key: key);

  @override
  _LevelButtonState createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> {
  int _buttonState = 0;
  bool _isActive = false;
  int worldCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWorldCount();
  }

  void _loadWorldCount() async {
    final prefs = await SharedPreferences.getInstance();
    worldCount = (prefs.getInt('worldCount') ?? 0);
    if (worldCount % 100 == widget.levelNum &&
        worldCount ~/ 100 == widget.worldNum) {
      _buttonState = 1;
      _isActive = true;
    } else if (worldCount ~/ 100 > widget.worldNum) {
      _isActive = true;
      _buttonState = 2;
    } else if (worldCount % 100 > widget.levelNum &&
        worldCount ~/ 100 >= widget.worldNum) {
      _isActive = true;
      _buttonState = 2;
    }
    setState(() {});
  }

  dynamic getColors() {
    switch (_buttonState) {
      case 1:
        return Constants.SECOND_COLOR;
      case 2:
        return Colors.yellow.shade300;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: _isActive
            ? () {
                if (_buttonState == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LevelView(
                        world: widget.worldNum,
                        level: widget.levelNum ~/ 10,
                      ),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: getColors(), fixedSize: Size(40, 40)),
        child: _buttonState == 2
            ? Icon(
                Icons.done,
                color: Constants.TEXT_COLOR,
              )
            : Text(
                '${widget.levelNum ~/ 10}',
                style: TextStyle(
                    color: Constants.TEXT_COLOR, fontFamily: 'Notokufi'),
              ));
  }
}
