import 'dart:typed_data';

class Lz4Dart {
  Uint8List uncompress(List<int> data, int uncompressedLength) {
    final dest = Uint8List(uncompressedLength);
    for (var op = 0, ip = 0;;) {
      final token = data[ip++];
      var length = token >> 4;
      if (length == 15) {
        do {
          length += data[ip];
        } while (data[ip++] == 255);
      }
      while (--length >= 0) {
        dest[op++] = data[ip++];
      }
      if (ip >= data.length) break;
      final offset = data[ip++] + (data[ip++] << 8);
      assert(offset != 0);
      var matchp = op - offset;
      var matchlength = (token & 15) + 4;
      if (matchlength == 19) {
        do {
          matchlength += data[ip];
        } while (data[ip++] == 255);
      }
      while (--matchlength >= 0) {
        dest[op++] = dest[matchp++];
      }
    }
    return dest;
  }
}