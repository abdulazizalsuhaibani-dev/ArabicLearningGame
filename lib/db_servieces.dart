import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';

class DatabaseService {
  late Database captcha_db;

  String dbName = 'game_db.db';
  bool databaseCreated = false;
  DatabaseService();

  Future<void> prepareDatabases() async {
    if (!databaseCreated) {
      await openBD(dbName);
    }
    databaseCreated = true;
  }

  Future<void> clearOldDB(String databaseName) async {
    String dbpath = join(await getDatabasesPath(), databaseName);
    var exists = await databaseExists(dbpath);
    if (exists) {
      // Delete the existing database
      await deleteDatabase(dbpath);
    }
  }

  Future<void> openBD(String databaseName) async {
    String dbpath = join(await getDatabasesPath(), databaseName);

    var exists = await databaseExists(dbpath);
    if (!exists) {
      // Create the writable database file from the bundled database file:
      ByteData data = await rootBundle.load('db/' + databaseName);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      try {
        File file = File(dbpath);
        await file.create(recursive: true);
        if (await file.exists()) {
          await file.writeAsBytes(bytes, flush: true);
        } else {
          print('database file not created');
        }
      } catch (e) {
        print('error caught: $e');
      }
    }
    captcha_db = await openDatabase(dbpath);
    print('CAPTCHA database loaded');
  }

  Future<String> getDBPath() async {
    return await getDatabasesPath();
  }

  Future<String> getUserDBPath() async {
    return join(await getDatabasesPath(), dbName);
  }

  Future<String> getZippedDBPath() async {
    return '';
  }

  Future<List<Map<String, dynamic>>> getImageInfo(int id) async {
    String dbQuery = 'select * from images where image_id = $id';
    List<Map<String, dynamic>> content = await captcha_db.rawQuery(dbQuery);
    return content;
  }

  Future<Map<String, dynamic>> getRandomImage() async {
    String imagesQuery = 'select * from images order by random() limit 1';
    List<Map<String, dynamic>> imagesContent =
        await captcha_db.rawQuery(imagesQuery);
    return imagesContent.first;
  }

  Future<void> deleteSelectedImages() async {
    String dbQuery = 'delete from selectedImages';
    int content = await captcha_db.rawDelete(dbQuery);
  }
}
