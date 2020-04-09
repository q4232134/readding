import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readding/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/src/exception.dart';
import 'package:path/path.dart' as pp;

import 'database.dart';
import 'model.dart';

FlutterTts flutterTts;
var isPlaying = false;
AudioPlayer audioPlayer = AudioPlayer();

BeanList list;

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
      flutterTts = FlutterTts();
    }

    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) {
          list = BeanList();
          _add(list);
          return list;
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

/// 根据id获取文件
_getFileById(var id) async {
  var name = '$id.wav';
  final dir = await getExternalStorageDirectory();
  return File(dir.path + '/' + name);
}

///根据id删除文件
_deleteFile({int id, File file}) async {
  File temp = file == null ? await _getFileById(id) : file;
  await temp.delete();
  print('${pp.basename(file.path)}已删除');
}

class _MyHomePageState extends State<MyHomePage> {
  var mDialog = Key('dialog');

  @override
  void deactivate() async {
    list.removeAll();
    var temp = await (dao).getAll();
    list.addAll(temp);
  }

  @override
  Widget build(BuildContext context) {
    BeanList list = Provider.of<BeanList>(context);
    var style = TextStyle(
      fontSize: 12.0, // 文字大小
      color: Colors.white, // 文字颜色
    );

    _play(History model) async {
      var file = await _getFileById(model.id);
      await audioPlayer.play(file.path, isLocal: true);
      audioPlayer.onPlayerStateChanged.listen((s) {
        var flag;
        switch (s) {
          case AudioPlayerState.PLAYING:
            flag = true;
            break;
          case AudioPlayerState.COMPLETED:
            _deleteFile(id: model.id);
            list.remove(model);
            flag = false;
            break;
          case AudioPlayerState.PAUSED:
          case AudioPlayerState.STOPPED:
            flag = false;
        }
        setState(() => {isPlaying = flag});
      }, onError: (msg) {
        setState(() {
          isPlaying = false;
          Fluttertoast.showToast(msg: msg);
        });
      });
    }

    Future _createTTS() async {
      var temp = await (await getDao()).getFirst();
      final file = await _getFileById(temp.id);
      print(file.path);
      var flag = await file.exists();
      print(flag);
      if (!flag) {
        flutterTts.setLanguage('zh-CN');
        int result = await flutterTts.synthesizeToFile(
            temp.content, pp.basename(file.path));
        if (!(result == 1)) {
          Fluttertoast.showToast(msg: "生成语音文件失败！");
          return;
        }
      }
      _play(temp);
    }

    Future _stopTTS() async {
      audioPlayer.pause();
    }

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
                    _stopTTS();
                  } else {
                    _createTTS();
                  }
                },
              ))
        ],
      ),
      body: Center(
          child: ListView.builder(
              itemCount: list.getList().length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final item = list.getList()[index];
                return Consumer<BeanList>(builder: (context, list, child) {
                  return Dismissible(
                      key: Key(item.title),
                      direction: DismissDirection.horizontal,
                      onDismissed: (DismissDirection direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          var temp = list.getList()[index];
                          audioPlayer.stop();
                          _deleteFile(id: temp.id);
                          await dao.remove(temp);
                          list.removeAt(index);
                        } else {
                          var temp = list.getList()[index];
                          temp.isFinished = true;
                          audioPlayer.stop();
                          _deleteFile(id: temp.id);
                          await dao.updateItem(temp);
                          list.removeAt(index);
                        }
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: 8, right: 8, top: 2),
                          child: Card(
                              child: ListTile(
                                  title: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          formatDate(
                                              list.getList()[index].getDate(),
                                              [yyyy, "-", mm, "-", dd]),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 12))),
                                  subtitle: Text(list.getList()[index].content,
                                      maxLines: 3),
                                  isThreeLine: false,
                                  dense: true,
                                  enabled: true,
                                  onTap: () {
                                    _showAdditionDialog(
                                        item: list.getList()[index]);
                                  },
                                  selected: false))));
                });
                // item 是否选中状态
              })),
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
      dao.add(item);
    } on SqfliteDatabaseException {
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
