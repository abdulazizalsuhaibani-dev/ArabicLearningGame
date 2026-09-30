import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:arabic_learning_game/classes/answers_generator.dart';

class DatabaseService {
  late Database captchaDb;
  final String dbName = 'game_db.db';
  bool databaseCreated = false;

  Future<void> prepareDatabases() async {
    if (databaseCreated) return;
    final dbPath = join(await getDatabasesPath(), dbName);
    if (!await databaseExists(dbPath)) {
      final data = await rootBundle.load('db/$dbName');
      final file = File(dbPath);
      await file.create(recursive: true);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    captchaDb = await openDatabase(dbPath);
    databaseCreated = true;
  }

  Future<CaptchaImage> getRandomImage() async {
    // LIMIT 1 includes every row and avoids loading the whole database.
    final rows = await captchaDb.rawQuery(
      'SELECT * FROM images ORDER BY RANDOM() LIMIT 1',
    );
    if (rows.isEmpty) throw StateError('No CAPTCHA images in database');
    return CaptchaImage.fromRow(rows.single);
  }
}
