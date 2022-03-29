library big5;

part 'table.dart';

// only non-stream version
class Big5 {
  static int compare(String a, String b) {
    final _a = encode(a);
    final _b = encode(b);
    if (_listEquals(_a, _b)) {
      return 0;
    }
    final _aLen = _a.length;
    final _bLen = _b.length;
    if (_aLen == _bLen) {
      for (int index = 0; index < _aLen; index++) {
        final _aVal = _a[index];
        final _bVal = _b[index];
        if (_aVal == _bVal) continue;
        return _aVal.compareTo(_bVal);
      }
    }
    return _aLen.compareTo(_bLen);
  }

  static String decode(List<int> src) {
    return _big5TransformDecode(src);
  }

  static List<int> encode(String src) {
    return _big5TransformEncode(src);
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  static String _big5TransformDecode(List<int> src) {
    var r = 0;
    var size = 0;
    var nDst = '';

    void write(input) => nDst += (new String.fromCharCode(input));

    for (var nSrc = 0; nSrc < src.length; nSrc += size) {
      var c0 = src[nSrc];
      if (c0 < 0x80) {
        r = c0;
        size = 1;
      } else if (0x81 <= c0 && c0 < 0xFF) {
        if (nSrc + 1 >= src.length) {
          r = RUNE_ERROR;
          size = 1;
          write(r);
          continue;
        }
        var c1 = src[nSrc + 1];
        r = 0xfffd;
        size = 2;

        var i = c0 * 16 * 16 + c1;
        var s = _decodeMap[i];
        if (s != null) {
          write(s);
          continue;
        }
      } else {
        r = RUNE_ERROR;
        size = 1;
      }
      write(r);
      continue;
    }
    return nDst;
  }

  static List<int> _big5TransformEncode(String src) {
    final runes = Runes(src).toList();
    final runesLen = runes.length;
    int r = 0;
    int size = 0;
    final List<int> dst = [];

    void write2(int r) {
      dst.add(r >> 8);
      dst.add(r % 256);
    }

    int getValue(Map<int, int> map, int key) {
      return map[key] ?? 0;
    }

    bool isContains(int low, int value, int high) {
      return low <= value && r < high;
    }

    for (var nSrc = 0; nSrc < runesLen; nSrc += size) {
      r = runes[nSrc];

      // Decode a 1-byte rune.
      if (r < RUNE_SELF) {
        size = 1;
        dst.add(r);
        continue;
      } else {
        // Decode a multi-byte rune.
        // TODO handle some error
        size = 1;
      }

      if (r >= RUNE_SELF) {
        if (isContains(encode0Low, r, encode0High)) {
          r = getValue(_encode0, r - encode0Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode1Low, r, encode1High)) {
          r = getValue(_encode1, r - encode1Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode2Low, r, encode2High)) {
          r = getValue(_encode2, r - encode2Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode3Low, r, encode3High)) {
          r = getValue(_encode3, r - encode3Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode4Low, r, encode4High)) {
          r = getValue(_encode4, r - encode4Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode5Low, r, encode5High)) {
          r = getValue(_encode5, r - encode5Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode6Low, r, encode6High)) {
          r = getValue(_encode6, r - encode6Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        } else if (isContains(encode7Low, r, encode7High)) {
          r = getValue(_encode7, r - encode7Low);
          if (r != 0) {
            write2(r);
            continue;
          }
        }
        // TODO handle err
        break;
      }
    }
    return dst;
  }
}
