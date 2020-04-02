import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'model.dart';

part 'database.g.dart'; // the generated code will be there

//flutter packages pub run build_runner watch
/*

D:
cd D:\work\flutter\readding
flutter packages pub run build_runner watch


 */
@Database(version: 1, entities: [History])
abstract class AppDatabase extends FloorDatabase {
  HistoryDao get historyDao;
}
