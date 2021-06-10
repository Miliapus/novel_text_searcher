import 'dart:convert';
import 'dart:io';

import 'package:novel_text_searcher/model.dart';

abstract class NovelManagerDelegate {
  void onOnceSearchFinish(Novel novel, List<String> results);
}

class NovelManager {
  NovelManagerDelegate? delegate;
  List<Novel> novels = [];

  load() async {
    Directory dir = Directory("/storage/emulated/0/小说/其他小说");
    assert(await dir.exists() == true);
    final list = dir.listSync(recursive: true, followLinks: true);
    list.removeWhere((element) => element is Directory);
    novels = list.map((e) => Novel(e as File)).toList();
  }

  search(String key) async {
    novels.forEach((element) {
      onceSearch(element, key);
    });
  }

  onceSearch(Novel novel, String key) async {
    final results = await novel.search(key);
    delegate!.onOnceSearchFinish(novel, results);
  }
}
