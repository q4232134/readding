import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterttsfull/flutterttsfull.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readding/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/src/exception.dart';
import 'package:path/path.dart' as pp;

import 'database.dart';
import 'model.dart';

Flutterttsfull tts;
BeanList list;
bool isPlaying = false;

class mainpage extends StatelessWidget {
  SharedPreferences prefs;

  _getPrefs() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    void _add(BeanList list) async {
      var temp = await (dao).getAll();
      list.addAll(temp);
      tts = Flutterttsfull();
//      tts.onNext = (tag) {
//          dao.getFirst()
//      }
    }

    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) {
          var temps = BeanList();
          _add(temps);
          return temps;
        },
        child: MyHomePage(title: '语音阅读'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var mDialog = Key('dialog');

  Future _play() async {
    var temp = await (await getDao()).getFirst();
    if (temp == null) Fluttertoast.showToast(msg: "全部播放完成");
    await tts.proper("${temp.id}", temp.content, temp.history);
    await tts.start();
    var flag = await tts.isPlaying();
    setState(() {
      isPlaying = flag;
    });
  }

  /// 初始化tts回调
  initTTs() {
    tts.onPlaying = (String tag, String content, int index) {
      dao.updateHistory(int.parse(tag), index);
      print('onPlaying');
    };
    tts.onFinish = (tag) async {
      var temp = (await dao.get(int.parse(tag)));
      temp.isFinished = true;
      await dao.updateItem(temp);
      print('onFinish');
    };
    tts.onPause = (tag) async {
      var flag = await tts.isPlaying();
      setState(() async {
        isPlaying = flag;
      });
      print('onPause');
    };
  }

  @override
  void deactivate() async {
    list.removeAll();
    var temp = await (dao).getAll();
    list.addAll(temp);
  }

  @override
  Widget build(BuildContext context) {
    list = Provider.of<BeanList>(context);
    var style = TextStyle(
      fontSize: 12.0, // 文字大小
      color: Colors.white, // 文字颜色
    );

    Future _stop() async {
      await tts.stop();
      var flag = await tts.isPlaying();
      setState(() {
        isPlaying = flag;
      });
    }

    initTTs();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Container(
              width: 80.0,
              child: FlatButton(
                child: Text(
                  '历史记录',
                  style: style,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/history');
                },
              )),
          Container(
              width: 60.0,
              child: FlatButton(
                child: Text(isPlaying ? '暂停' : '播放', style: style),
                onPressed: () {
                  if (isPlaying) {
                    _stop();
                  } else {
                    _play();
                  }
                },
              ))
        ],
      ),
      body: Center(
          child: DragAndDropList<History>(
        list.getList(),
        itemBuilder: (BuildContext context, item) {
          return Dismissible(
              key: Key(item.title),
              direction: DismissDirection.horizontal,
              onDismissed: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) {
                  var temp = item;
                  _stop();
                  await dao.remove(temp);
                  list.remove(item);
                } else {
                  var temp = item;
                  temp.isFinished = true;
                  tts.stop();
                  await dao.updateItem(temp);
                  list.remove(item);
                }
              },
              child: Card(
                  margin: EdgeInsets.only(left: 8, right: 8, top: 5),
                  child: ListTile(
                      title: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              formatDate(
                                  item.getDate(), [yyyy, "-", mm, "-", dd]),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12))),
                      subtitle: Text(
                        item.content,
                        maxLines: 5,
                        style: TextStyle(height: 1.1),
                      ),
                      isThreeLine: false,
                      dense: true,
                      enabled: true,
                      onTap: () {
                        _showAdditionDialog(item: item);
                      },
                      selected: false)));

          // item 是否选中状态
        },
        onDragFinish: (before, after) async {
          if (before != after) {
            var temp = list.getList()[before];
            list.remove(temp);
            list.getList().insert(after, temp);
            int i = 0;
            list.getList().forEach((it) {
              it.ord = i;
              i++;
            });
            await (await getDao()).updateItems(list.getList());
          }
        },
        canBeDraggedTo: (int oldIndex, int newIndex) => true,
      )),
      floatingActionButton: GestureDetector(
          onLongPress: () async {
            var data = await Clipboard.getData(Clipboard.kTextPlain);
            if (data.text == null) return;
            var temp = History.init(data.text);
            if (!await _addItem(temp)) return;
            list.add(temp);
            Fluttertoast.showToast(msg: "添加条目成功");
          },
          child: FloatingActionButton(
              onPressed: _showAdditionDialog, child: Icon(Icons.add))),
    );
  }

  _addItem(var item) async {
    try {
      await dao.insertItem(item);
    } on DatabaseException {
      Fluttertoast.showToast(msg: "条目已存在");
      return false;
    }
    return true;
  }

  /// 弹出添加对话框
  // ignore: avoid_init_to_null
  void _showAdditionDialog({History item = null, String content = ''}) {
    String saved;
    showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          var list = Provider.of<BeanList>(context);
          return new AlertDialog(
            key: mDialog,
            title: new Text('添加条目'),
            //可滑动
            content: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                text: item == null ? content : item.content,
              )),
              style: TextStyle(fontSize: 16),
              onChanged: (it) => {saved = it},
              maxLengthEnforced: false,
              minLines: 5,
              maxLines: 22,
              maxLength: 99999,
              autocorrect: true,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: '复制需要朗读的文本到这里'),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text(item == null ? '添加' : '修改'),
                onPressed: () async {
                  if (saved == null || saved.length == 0) {
                    Fluttertoast.showToast(msg: "输入内容不能为空");
                    return;
                  }
                  if (item == null) {
                    var temp = History.init(saved);
                    if (!await _addItem(temp)) return;
                    list.add(temp);
                    Fluttertoast.showToast(msg: "添加条目成功");
                  } else {
                    item.content = saved;
                    item.title = item.getHead(saved);
                    dao.updateItem(item);
                    // ignore: invalid_use_of_protected_member
                    list.notifyListeners();
                    Fluttertoast.showToast(msg: "修改条目成功");
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
