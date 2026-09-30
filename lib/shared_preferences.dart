import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static const levelCodes = [110, 120, 130, 210, 220, 230, 310, 320, 330];
  static const completedCode = 410;
  final int worldCount;
  final int cyberCount;
  const GameProgress(this.worldCount, this.cyberCount);
  bool get isComplete => worldCount == completedCode;

  static Future<GameProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('worldCount')) {
      await _saveInt(prefs, 'worldCount', 110);
    }
    if (!prefs.containsKey('cyberCount')) {
      await _saveInt(prefs, 'cyberCount', -1);
    }
    return GameProgress(
      prefs.getInt('worldCount')!,
      prefs.getInt('cyberCount')!,
    );
  }

  static Future<GameProgress> completeLevel(int levelCode) async {
    final current = await load();
    if (current.worldCount != levelCode || !levelCodes.contains(levelCode)) {
      return current;
    }
    final index = levelCodes.indexOf(levelCode);
    final next = index == levelCodes.length - 1
        ? completedCode
        : levelCodes[index + 1];
    final prefs = await SharedPreferences.getInstance();
    // The tip follows the completed level, including installs with legacy counters.
    await _saveInt(prefs, 'cyberCount', index);
    await _saveInt(prefs, 'worldCount', next);
    return GameProgress(next, index);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveInt(prefs, 'cyberCount', -1);
    await _saveInt(prefs, 'worldCount', 110);
  }

  static Future<void> _saveInt(
    SharedPreferences prefs,
    String key,
    int value,
  ) async {
    try {
      if (!await prefs.setInt(key, value)) {
        throw StateError('Could not save $key');
      }
    } catch (_) {
      // Legacy SharedPreferences updates its cache before the platform write.
      // Reload after failure so a retry reads the value actually saved on disk.
      await prefs.reload();
      rethrow;
    }
  }
}
