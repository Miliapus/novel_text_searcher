import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:utf_convert/utf_convert.dart';
import 'package:fast_gbk/fast_gbk.dart';

typedef IsMatchFunction = bool Function(Uint8List data);
typedef ReadFunction = String Function(Uint8List data);

abstract class Reader {
  const Reader(this.isMatch, this.read);

  final IsMatchFunction isMatch;
  final ReadFunction read;
}

class PrefixReader extends Reader {
  PrefixReader(List<int> preFix, ReadFunction read)
      : super((data) => data.isMatch(preFix), read);
}

class EncodingPrefixReader extends PrefixReader {
  EncodingPrefixReader(List<int> preFix, Encoding encoding)
      : super(preFix, (data) => encoding.decode(data));
}

extension match on Uint8List {
  bool isMatch(List<int> target) {
    int size = target.length;
    for (int i = 0; i < size; ++i) {
      if (this[i] != target[i]) {
        return false;
      }
    }
    return true;
  }
}

Reader utf8Reader = EncodingPrefixReader([0xEF, 0xBB, 0xBF], utf8);
Reader utf16leReader =
    PrefixReader([0xFF, 0xFE], (data) => decodeUtf16le(data));
Reader gbkReader = EncodingPrefixReader([], gbk);

extension load on File {
  Future<String> readUTF16LE() async {
    final bytes = await readAsBytes();
    return decodeUtf16le(bytes);
  }

  Future<String> readByReaders(List<Reader> readers) async {
    final bytes = await readAsBytes();
    final reader = readers.iterator;
    while (reader.moveNext()) {
      if (reader.current.isMatch(bytes)) {
        try {
          return reader.current.read(bytes);
        } catch(e){
          print(e.toString());
        }
      }
      print("not match $path");
    }
    throw Exception("no correct reader method");
  }

  Future<String> read() async {
    try{
      return readByReaders([
        utf8Reader,
        utf16leReader,
        gbkReader,
      ]);
    } catch (e) {
      return readBy([
        utf8,
        gbk,
        readUTF16LE,
      ]);
    }
  }

  Future<String> readBy(List<dynamic> methods, {int from = 0}) async {
    String re;
    try {
      final now = methods[from];
      if (now is Encoding) {
        re = await readAsString(encoding: now);
      } else if (now is Future<String> Function(File file)) {
        re = await now(this);
      } else if (now is Future<String> Function()) {
        re = await now();
      } else {
        print("unknown method ${now.runtimeType}");
        throw Exception("unknown method");
      }
    } catch (e) {
      if (from + 1 < methods.length) {
        re = await readBy(methods, from: from + 1);
      } else {
        throw Exception("no correct method with $path");
      }
    }
    return re;
  }
}
