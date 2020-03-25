import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'model.dart';

BeanList list;

void main() {
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
        actions: <Widget>[],
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
                            print('点击:$index');
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

  void _insert(History temp) async {
    await (await _getDao()).add(temp);
  }

  void _showAdditionDialog() {
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
              style: TextStyle(fontSize: 16),
              onChanged: (it) => {saved = it},
              textInputAction: TextInputAction.done,
              maxLength: 99999,
              autocorrect: true,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: '复制需要朗读的文本到这里'),
            )),
            actions: <Widget>[
              new FlatButton(
                child: new Text('添加'),
                onPressed: () {
                  if (saved == null || saved.length == 0) {
                    Fluttertoast.showToast(msg: "输入内容不能为空");
                    return;
                  }
                  var temp = History.init(saved);
                  _insert(temp);
                  list.add(temp);
                  list.getList().forEach((it) => print(it.content));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
