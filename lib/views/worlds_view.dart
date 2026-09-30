import 'package:flutter/material.dart';
import 'package:arabic_learning_game/views/level_view.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';
import 'package:arabic_learning_game/classes/constants.dart' as constants;
import 'package:arabic_learning_game/shared_preferences.dart';

class WorldsView extends StatefulWidget {
  final Future<CaptchaImage> Function()? loadImage;
  const WorldsView({super.key, this.loadImage});
  @override
  State<WorldsView> createState() => _WorldsViewState();
}

class _WorldsViewState extends State<WorldsView> {
  GameProgress? _progress;
  bool _failed = false;
  bool _openingLevel = false;
  static const _advice = [
    'لا تنشر صورك عبر برامج التواصل الاجتماعي',
    'لا ترسل بيانات البطاقة البنكية لأي شخص',
    'لا تزود أي شخص بمعلوماتك الخاصة أو عناوين اتصالك',
    'لا تفتح أي مرفق في البريد الإلكتروني إلا إذا كان المرسل معروفاً لديك',
    'لا تستجب لأي رسالة أو طلب إذا لم تفهم معناها وأخبر والديك عنها مباشرة',
    'اختر كلمات مرور قوية ولا تشاركها مع أحد مطلقاً',
    'في حال تعرضك للتنمر أخبر والديك فوراً',
    'لا تنشر الشائعات فقد تؤذي غيرك',
    'لا تفتح الروابط غير المعروفة إلا بعد أن تتأكد من صحتها',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await GameProgress.load();
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _openLevel(int code) async {
    if (_openingLevel) return;
    setState(() => _openingLevel = true);
    try {
      final tip = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LevelView(levelCode: code, loadImage: widget.loadImage),
        ),
      );
      if (!mounted) return;
      await _loadProgress();
      if (!mounted || tip == null || tip < 0 || tip >= _advice.length) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            _progress!.isComplete ? 'مبروك! أكملت جميع العوالم' : 'نصيحة',
          ),
          content: Text(_advice[tip], textDirection: TextDirection.rtl),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _openingLevel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة العوالم'), centerTitle: true),
      body: SafeArea(
        child: _failed
            ? Center(
                child: ElevatedButton(
                  onPressed: _loadProgress,
                  child: const Text('إعادة المحاولة'),
                ),
              )
            : progress == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (progress.isComplete)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'أحسنت! أكملت جميع المراحل.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (var world = 1; world <= 3; world++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: constants.THIRD_COLOR,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            [
                              'العالم الأول',
                              'العالم الثاني',
                              'العالم الثالث',
                            ][world - 1],
                            style: const TextStyle(fontSize: 27),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var level = 1; level <= 3; level++)
                                ElevatedButton(
                                  onPressed:
                                      !_openingLevel &&
                                          progress.worldCount ==
                                              world * 100 + level * 10
                                      ? () =>
                                            _openLevel(world * 100 + level * 10)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.SECOND_COLOR,
                                    disabledBackgroundColor:
                                        progress.worldCount >
                                            world * 100 + level * 10
                                        ? Colors.yellow.shade300
                                        : Colors.grey.shade300,
                                    minimumSize: const Size(64, 48),
                                  ),
                                  child:
                                      progress.worldCount >
                                          world * 100 + level * 10
                                      ? const Icon(
                                          Icons.done,
                                          color: Colors.black87,
                                        )
                                      : Text('$level'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
