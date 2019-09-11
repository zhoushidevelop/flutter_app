import 'dart:async';

import 'package:sqflite/sqflite.dart';

class Provider {
  static Database db;

  static const String RAWTABLESQL =
      'select name from sqlite_master where type = "table"';

  Future<List> getTables() async {
    if (db == null) {
      return new Future.value([]);
    }
    List tables = await db.rawQuery(RAWTABLESQL);
    List<String> targetList = [];
    tables.forEach((item) {
      targetList.add(item['name']);
    });
    return targetList;
  }

  // 检查数据库中, 表是否完整, 在部份android中, 会出现表丢失的情况
  Future checkTableIsRight() async {
    List<String> expectTables = ['cat', 'widget', 'collection'];
    List<String> tables = await getTables();
//    for (int i = 0, i < expectTables.length, i++>) {
//
//    }
  }
}
