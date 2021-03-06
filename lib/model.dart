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
  @ignore
  bool isPlaying = false;
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

abstract class BaseDao<T> {
  @insert
  Future<void> add(T person);

  @update
  Future<void> updateItem(T item);

  @update
  Future<void> updateItems(List<T> items);

  @delete
  Future<int> remove(T item);
}

@dao
abstract class HistoryDao extends BaseDao<History> {
  @Query('SELECT * FROM History where id = :id limit 1')
  Future<History> get(int id);

  @Query('SELECT * FROM History where isFinished = 0 order by ord')
  Future<List<History>> getAll();

  @Query('SELECT * FROM History where isFinished = 1 order by createTime desc')
  Future<List<History>> getHistory();

  @Query('SELECT * FROM History where isFinished = 0 order by ord limit 1')
  Future<History> getFirst();

  @Query('SELECT MAX(ord) as ord FROM History where isFinished = 0')
  Future<History> getMaxOrd();

  /// 更新数据历史记录
  @Query("update History set history = :history where id = :id")
  Future<History> updateHistory(int id, int history);

  insertItem(History item) async {
    var max = await getMaxOrd();
    int temp = max.ord == null ? 0 : max.ord;
    item.ord = temp + 1;
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

  removeByTag(String tag) {
    _list.where((element) => element.id.toString() == tag);
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

  removeById(int id) {
    History temp = _list.firstWhere((it) => it.id == id);
    remove(temp);
  }
}
