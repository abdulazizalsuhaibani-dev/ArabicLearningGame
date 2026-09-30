import 'package:flutter/material.dart';
import 'package:arabic_learning_game/views/main_menu_view.dart';
import 'package:arabic_learning_game/db_servieces.dart';
import 'package:arabic_learning_game/shared_preferences.dart';

late DatabaseService databaseService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  databaseService = DatabaseService();
  await databaseService.prepareDatabases();
  await setInitialWorldValue();
  runApp(const MyApp());
}

Future<void> setInitialWorldValue() async {
  await GameProgress.load();
}
