import 'dart:ffi';
import 'dart:math';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';

@Entity(indices: [
  Index(unique: true, value: ['title'])
])
class History {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(nullable: false)
  String title = "";
  String content = "";
  int ord = 0;
  bool isFinished = false;
  String createTime;
  int history = 0;

  History(this.id, this.title, this.content, this.ord, this.isFinished,
      this.createTime, this.history);

  History.init(String msg) {
    title = getHead(msg);
    content = msg;
    createTime = DateTime.now().toString();
    ord = -1;
  }

  getDate() {
    return DateTime.tryParse(createTime);
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
  @Query('SELECT * FROM History where isFinished = 0 order by ord')
  Future<List<History>> getAll();

  @Query('SELECT * FROM History where isFinished = 1 order by createTime desc')
  Future<List<History>> getHistory();

  @Query('SELECT * FROM History where isFinished = 0 order by ord limit 1')
  Future<History> getFirst();

  @insert
  Future<void> add(History person);

  @update
  Future<void> updateItem(History item);

  @update
  Future<void> updateItems(List<History> items);

  @delete
  Future<int> remove(History item);

  @Query('SELECT MAX(ord) as ord FROM History where isFinished = 0')
  Future<History> getMaxOrd();

  /// 更新数据历史记录
  @Query("update History set history = :history where id = :id")
  Future<History> updateHistory(int id, int history);

  insertItem(History item) async {
    var max = await getMaxOrd();
    max = max == null ? 0 : max;
    item.ord = max.ord + 1;
    await add(item);
  }
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

  removeAll() {
    _list.clear();
    notifyListeners();
  }

  removeAt(int index) {
    _list.removeAt(index);
    notifyListeners();
  }
}
