import 'dart:math';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';

@entity
class History {
  @PrimaryKey(autoGenerate: true)
  int id;
  String title = "";
  String content = "";
  int ord = 0;
  bool isFinished = false;
  int createTime = 0;
  int history = 0;

  History(this.id, this.title, this.content, this.ord, this.isFinished,
      this.createTime, this.history);

  History.init(String msg) {
    title = getHead(msg);
    content = msg;
    ord = -1;
  }

  getHead(String msg) => msg
      .substring(0, min(msg.length - 1, 100))
      .toString()
      .replaceAll("\n", " ");

  @override
  String toString() {
    return content;
  }
}

@dao
abstract class HistoryDao {
  @Query('SELECT * FROM History')
  Future<List<History>> getAll();

  @Query('SELECT * FROM History')
  Stream<List<History>> getAllAsStream();

  @insert
  Future<void> add(History person);

  @delete
  Future<int> remove(History item);
}

class BeanList with ChangeNotifier {
  List<History> _list = List();

  List<History> getList() {
    return _list;
  }

  add(History t) {
    _list.add(t);
    notifyListeners();
  }

  addAll(List<History> t) {
    _list.addAll(t);
    notifyListeners();
  }

  remove(History t) {
    _list.remove(t);
    notifyListeners();
  }

  removeAt(int index) {
    _list.removeAt(index);
    notifyListeners();
  }
}
