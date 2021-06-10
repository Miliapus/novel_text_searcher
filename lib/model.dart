import 'dart:async';
import 'dart:io';
import 'package:novel_text_searcher/load.dart';
class Novel {
  Novel(this.file);

  File file;
  String? _cache;

  FutureOr<String> _getCache() async {
    if (_cache == null) {
      _cache = await file.read();
    }
    return _cache!;
  }

  FutureOr<List<String>> search(String key) async {
    final data = await _getCache();
    print(data);
    final re = data.search(key, 20);
    return re;
  }
}

extension seach on String {
  List<String> search(String key, int targetLength) {
    final matches = key.allMatches(this);
    final list = matches.toList();
    if (list.isEmpty) {
      return [];
    } else {
      final eaten = list.iterator;
      eaten.moveNext();
      final finish = [[eaten.current.start,eaten.current.end]];
      while (eaten.moveNext()) {
        var needEat = false;
        if (eaten.current.end - finish.last.first <= targetLength) {
          needEat = true;
          for (int i = finish.last.first; i < eaten.current.end; ++i) {
            if (this[i] == '\n') {
              needEat = false;
              break;
            }
          }
        }
        if (needEat) {
          finish.last.last = eaten.current.end;
        } else {
          finish.add([eaten.current.start,eaten.current.end]);
        }
      }
      return finish.map((e) => cut(e.first,e.last,targetLength)).toList();
    }
  }

  String cut(int start, int end, int targetLength) {
    var tryStartFirst = true,
        changed = true;
    while (end - start < targetLength && changed) {
      tryStartFirst = !tryStartFirst;
      if (tryStartFirst) {
        if (start > 0 && this[start - 1] != '\n') {
          --start;
        } else if ((end < length && this[end] != '\n') ||
            end == length) {
          ++end;
        } else {
          changed = false;
        }
      } else {
        if ((end < length && this[end] != '\n') || end == length) {
          ++end;
        } else if (start > 0 && this[start - 1] != '\n') {
          --start;
        } else {
          changed = false;
        }
      }
    }
    return substring(start, end);
  }
}
