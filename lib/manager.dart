import 'dart:convert';
import 'dart:io';

import 'package:novel_text_searcher/model.dart';

abstract class NovelManagerDelegate {
void onOnceSearchFinish(Novel novel,List<String> results);
}
class NovelManager {
  NovelManagerDelegate? delegate;
  List<Novel> novels = [];
  load() async {
    Directory dir = Directory("/storage/emulated/0/小说/其他小说");
    assert(await dir.exists() == true);
    //输出绝对路径
    print("Path: ${dir.absolute.path}");
    final list = dir.listSync(recursive: true, followLinks: true);
    print("list size ${list.length}");
    list.removeWhere((element) => element is Directory);
    novels = list.map((e) => Novel(e as File)).toList();
    print("novels size ${novels.length}");
  }
  search(String key) async {
    print("$key search ${novels.length}");
    var now = novels.iterator;
    while(now.moveNext()) {
      print("$key search");
      onceSearch(now.current,key);
    }
  }
  onceSearch(Novel novel,String key) async {
    print(novel.file.path);
    final results = await novel.search(key);
    delegate!.onOnceSearchFinish(novel, results);
  }
}
