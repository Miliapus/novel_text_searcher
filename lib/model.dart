import 'dart:io';

class Novel {
  Novel(this.file);

  File file;
  String?  _cache ;
  String _getCache() {
    if (_cache != null) {
      _cache = file.readAsStringSync();
    }
    return _cache!;
  }
  List<String> search(String key) {
    final cache = _getCache();
    return cache.allMatches(key).map((e) => cache.substring(e.start,e.end)).toList();
  }
}
