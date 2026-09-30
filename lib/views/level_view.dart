import 'package:flutter/material.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';

import 'dart:ui' as ui;

import 'package:arabic_learning_game/classes/constants.dart' as constants;
import 'package:arabic_learning_game/main.dart';
import 'package:arabic_learning_game/shared_preferences.dart';

class LevelView extends StatefulWidget {
  final int levelCode;
  final Future<CaptchaImage> Function()? loadImage;
  const LevelView({super.key, required this.levelCode, this.loadImage});

  @override
  State<LevelView> createState() => _LevelViewState();
}

class _LevelViewState extends State<LevelView> {
  GameQuestion? _question;
  bool _loading = true;
  bool _loadFailed = false;
  bool _answering = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final image =
          await (widget.loadImage ?? databaseService.getRandomImage)();
      if (!mounted) return;
      final data = await DefaultAssetBundle.of(context)
          .load('assets/images/${image.image}');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      final type = GameProgress.levelCodes.indexOf(widget.levelCode) + 1;
      final question = GameQuestion.generate(image, type);
      if (!mounted) return;
      setState(() {
        _question = question;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
    }
  }

  Future<void> _answer(Answer answer) async {
    if (_answering || _loading) return;
    setState(() => _answering = true);
    final finishing = answer.isCorrect && _correctCount == 4;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(
            answer.isCorrect
                ? (finishing ? 'مبروك! لقد تجاوزت المرحلة!' : 'أحسنت!')
                : 'إجابة خاطئة!',
          ),
          content: Icon(
            answer.isCorrect ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: answer.isCorrect ? Colors.green : Colors.red,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                answer.isCorrect
                    ? (finishing ? 'إكمال المرحلة' : 'السؤال التالي')
                    : 'حاول مرة أخرى',
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (proceed != true || !answer.isCorrect) {
      setState(() => _answering = false);
      return;
    }
    if (finishing) {
      try {
        final progress = await GameProgress.completeLevel(widget.levelCode);
        if (!mounted) return;
        Navigator.pop(context, progress.cyberCount);
      } catch (_) {
        if (!mounted) return;
        setState(() => _answering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ التقدم. حاول مرة أخرى.')),
        );
      }
      return;
    }
    setState(() {
      _correctCount++;
      _answering = false;
    });
    await _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'العالم ${widget.levelCode ~/ 100} - مرحلة ${widget.levelCode % 100 ~/ 10} - سؤال ${_correctCount + 1}',
          style: const TextStyle(fontSize: 18, color: constants.TEXT_COLOR),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _loadFailed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('تعذر تحميل السؤال. حاول مرة أخرى.'),
                    ElevatedButton(
                      onPressed: _loadQuestion,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        question!.text,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 28),
                      Image.asset(
                        'assets/images/${question.image.image}',
                        height: 160,
                        errorBuilder: (context, error, stack) => Column(
                          children: [
                            const Text('تعذر عرض الصورة.'),
                            TextButton(
                              onPressed: _loadQuestion,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: question.answers
                            .map(
                              (answer) => ElevatedButton(
                                onPressed: _answering
                                    ? null
                                    : () => _answer(answer),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(110, 60),
                                ),
                                child: Text(
                                  answer.answer,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          5,
                          (index) => Column(
                            children: [
                              Text('${index + 1}'),
                              Icon(
                                index < _correctCount
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: index < _correctCount
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ],
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
