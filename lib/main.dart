import 'package:flutter/material.dart';

void main() => runApp(MyApp());
List<String> list = List();

class MyApp extends StatelessWidget {
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
  int _counter = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _showAdditionDialog() {
    String saved;
    showDialog<Null>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          return new AlertDialog(
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
                    scaffoldKey.currentState
                        .showSnackBar(SnackBar(content: Text("输入内容不能为空")));
                    return;
                  }
                  list.add(saved);
                  print('$list');
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAdditionDialog,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
