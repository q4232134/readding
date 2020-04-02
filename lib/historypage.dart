import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class historypage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('历史'), actions: <Widget>[
          Container(
              width: 60.0,
              child: FlatButton(
                child: Text(
                  '完成',
                  style: style,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ]),
        body: Text('history'));
  }
}

var style = TextStyle(
  fontSize: 12.0, // 文字大小
  color: Colors.white, // 文字颜色
);
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//  final String title;
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: AppBar(title: Text('历史'), actions: <Widget>[
//          Container(
//              width: 60.0,
//              child: FlatButton(
//                child: Text(
//                  '完成',
//                  style: style,
//                ),
//                onPressed: () {
//                  Navigator.pop(context);
//                },
//              )),
//        ]),
//        body: Text('history'));
//  }
//}
