import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:readding/ttsservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'model.dart';

BeanList list;
FlutterTts flutterTts;
var isPlaying = false;

void main() async {
  AudioServiceBackground.run(() => ttsservice());
  void _add(BeanList list) async {
    var temp = await (await _getDao()).getAll();
    list.addAll(temp);
    flutterTts = FlutterTts();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        list = BeanList();
        _add(list);
        return list;
      },
      child: MyApp(),
    ),
  );
}

Future<HistoryDao> _getDao() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('database.db').build();
  return database.historyDao;
}

class MyApp extends StatelessWidget {
  SharedPreferences prefs;

  _getPrefs() async {
    if (prefs == null) prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '语音阅读',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '语音阅读'),
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

  void _showList() async {
    (await (await _getDao()).getAll()).forEach((it) => print(it));
  }

  @override
  Widget build(BuildContext context) {
    Future _startTTS() async {
      var result = await flutterTts.speak("Hello World");
      if (result == 1) setState(() => {isPlaying = true});
    }

    Future _stopTTS() async {
      var result = await flutterTts.stop();
      if (result == 1) setState(() => {isPlaying = false});
    }

    BeanList list = Provider.of<BeanList>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text(isPlaying ? '暂停' : '播放',
                style: TextStyle(
                  fontSize: 16.0, // 文字大小
                  color: Colors.white, // 文字颜色
                )),
            onPressed: () {
              if (isPlaying) {
                _stopTTS();
              } else {
                _startTTS();
              }
            },
          )
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
                        await (await _getDao()).remove(list.getList()[index]);
                        list.removeAt(index);
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
                                  onLongPress: () {
                                    print('长按:$index');
                                  },
                                  selected: false))));
                });
                // item 是否选中状态
              })),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAdditionDialog,
          tooltip: 'Increment',
          child: GestureDetector(
              onLongPress: () async {
                var data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data.text == null) return;
                var temp = History.init(data.text);
                list.add(temp);
                await (await _getDao()).add(temp);
                Fluttertoast.showToast(msg: "添加条目成功");
              },
              child: Icon(Icons.add))),
    );
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
                    list.add(temp);
                    await (await _getDao()).add(temp);
                    Fluttertoast.showToast(msg: "添加条目成功");
                  } else {
                    item.content = saved;
                    item.title = item.getHead(saved);
                    await (await _getDao()).updateItem(item);
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
