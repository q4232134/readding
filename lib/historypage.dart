import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readding/router.dart';

import 'model.dart';

BeanList list;
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    BeanList list = Provider.of<BeanList>(context);
    return Center(
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
                      await dao.remove(list.getList()[index]);
                      list.removeAt(index);
                    } else {
                      var temp = list.getList()[index];
                      temp.isFinished = false;
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
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 3),
                              isThreeLine: false,
                              dense: true,
                              enabled: true,
                              selected: false))));
            });
            // item 是否选中状态
          }),
    );
  }
}

class historypage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
      fontSize: 12.0, // 文字大小
      color: Colors.white, // 文字颜色
    );

    _add(BeanList list) async {
      var temp = await (dao).getHistory();
      list.addAll(temp);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('历史'),
        ),
        body: ChangeNotifierProvider(
            create: (context) {
              list = BeanList();
              _add(list);
              return list;
            },
            child: MyHomePage(title: '历史')));
  }
}
