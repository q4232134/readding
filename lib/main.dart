import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:readding/ttsservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'model.dart';

BeanList list;

void main() async {
  AudioServiceBackground.run(() => ttsservice());
  void _add(BeanList list) async {
    var temp = await (await _getDao()).getAll();
    list.addAll(temp);
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
    BeanList list = Provider.of<BeanList>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text('播放',
                style: TextStyle(
                  fontSize: 16.0, // 文字大小
                  color: Colors.white, // 文字颜色
                )),
            onPressed: () {},
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
                      child: ListTile(
                          title: Text(list.getList()[index].content),
                          // item 前置图标
                          subtitle: Text("subtitle $index"),
                          // item 后置图标
                          isThreeLine: false,
                          // item 是否三行显示
                          dense: true,
                          // item 直观感受是整体大小
                          contentPadding: EdgeInsets.all(10.0),
                          // item 内容内边距
                          enabled: true,
                          onTap: () {
                            _showAdditionDialog(item: list.getList()[index]);
                          },
                          // item onTap 点击事件
                          onLongPress: () {
                            print('长按:$index');
                          },
                          // item onLongPress 长按事件
                          selected: false));
                });

                // item 是否选中状态
              })),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAdditionDialog,
          tooltip: 'Increment',
          child:
              GestureDetector(onLongPress: _showList, child: Icon(Icons.add))),
    );
  }

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
            content: new SingleChildScrollView(
                child: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                text: item == null ? content : item.content,
              )),
              style: TextStyle(fontSize: 16),
              onChanged: (it) => {saved = it},
              textInputAction: TextInputAction.done,
              maxLength: 99999,
              autocorrect: true,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: '复制需要朗读的文本到这里'),
            )),
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
                  } else {
                    item.content = saved;
                    item.title = item.getHead(saved);
                    await (await _getDao()).updateItem(item);
                    // ignore: invalid_use_of_protected_member
                    list.notifyListeners();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
