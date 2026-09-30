import 'package:flutter/material.dart';
import 'package:arabic_learning_game/shared_preferences.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _resetting = false;

  Future<void> _resetGame() async {
    if (_resetting) return;
    setState(() => _resetting = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة اللعبة؟'),
        content: const Text(
          'سيتم مسح التقدم والعودة إلى المرحلة الأولى.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة التعيين'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      try {
        await GameProgress.reset();
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تمت إعادة اللعبة.')));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذرت إعادة اللعبة. حاول مرة أخرى.')),
        );
      }
    }
    if (mounted) setState(() => _resetting = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('خيارات')),
    body: Center(
      child: ElevatedButton(
        onPressed: _resetting ? null : _resetGame,
        child: const Text('إعادة اللعبة'),
      ),
    ),
  );
}
