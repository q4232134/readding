import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:readding/historypage.dart';

import 'database.dart';
import 'mainpage.dart';
import 'model.dart';

HistoryDao dao;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dao = await getDao();
  runApp(router.initApp());
}

class router {
  static Map<String, WidgetBuilder> routes;

//初始化App
  static Widget initApp() {
    return MaterialApp(
      initialRoute: '/',
      routes: router.initRoutes(),
    );
  }

//初始化路由
  static initRoutes() {
    routes = {
      '/': (context) => mainpage(),
      '/history': (context) => historypage(),
    };
    return routes;
  }
}

Future<HistoryDao> getDao() async {
  if (dao == null) {
    final database =
        await $FloorAppDatabase.databaseBuilder('database.db').build();
    dao = database.historyDao;
  }
  return dao;
}
