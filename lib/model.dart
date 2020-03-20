import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:readding/main.dart';

class Bean {
  int id;
  var title = "";
  var content = "";
  var ord = 0;
  var isFinished = false;
  var createTime = DateTime.now();
  var history = 0;

  Bean(String msg) {
    title = getHead(msg);
    content = msg;
    ord = -1;
  }

  getHead(String msg) => msg
      .substring(0, min(msg.length - 1, 100))
      .toString()
      .replaceAll("\n", " ");
}

class BeanList with ChangeNotifier {
  List<Bean> _list = List();

  List<Bean> getList() {
    return _list;
  }

  add(Bean t) {
    _list.add(t);
    notifyListeners();
  }

  remove(Bean t) {
    _list.remove(t);
    notifyListeners();
  }

  removeAt(int index){
    _list.removeAt(index);
    notifyListeners();

  }
}
