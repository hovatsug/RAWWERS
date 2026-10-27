// A small PNG reader for the brand tests: dimensions, the alpha channel and
// pixel colours, without adding an image package to the app.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Just enough PNG to check an icon: 8-bit RGB or RGBA, not interlaced -
/// what the generator writes.
class Png {
  Png._(this.width, this.height, this.hasAlpha, this._pixels);

  factory Png.read(String path) {
    final bytes = File(path).readAsBytesSync();
    final data = ByteData.sublistView(bytes);
    var offset = 8;
    late int width, height, colourType;
    final idat = BytesBuilder();
    while (offset < bytes.length) {
      final length = data.getUint32(offset);
      final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
      final body = bytes.sublist(offset + 8, offset + 8 + length);
      if (type == 'IHDR') {
        final h = ByteData.sublistView(body);
        width = h.getUint32(0);
        height = h.getUint32(4);
        expect(body[8], 8, reason: '$path: 8-bit');
        colourType = body[9];
        expect(body[12], 0, reason: '$path: not interlaced');
      } else if (type == 'IDAT') {
        idat.add(body);
      }
      offset += 12 + length;
    }
    expect(colourType, anyOf(2, 6), reason: '$path: RGB or RGBA');
    final channels = colourType == 6 ? 4 : 3;
    final raw = ZLibCodec().decode(idat.takeBytes());
    final stride = width * channels;
    final out = Uint8List(height * stride);
    for (var y = 0; y < height; y++) {
      final filter = raw[y * (stride + 1)];
      for (var x = 0; x < stride; x++) {
        final v = raw[y * (stride + 1) + 1 + x];
        final a = x >= channels ? out[y * stride + x - channels] : 0;
        final b = y > 0 ? out[(y - 1) * stride + x] : 0;
        final c = x >= channels && y > 0 ? out[(y - 1) * stride + x - channels] : 0;
        final p = a + b - c;
        final pa = (p - a).abs(), pb = (p - b).abs(), pc = (p - c).abs();
        final paeth = pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
        out[y * stride + x] = switch (filter) {
          0 => v,
          1 => v + a,
          2 => v + b,
          3 => v + ((a + b) >> 1),
          4 => v + paeth,
          _ => throw StateError('$path: filter $filter'),
        } & 0xFF;
      }
    }
    return Png._(width, height, colourType == 6, out);
  }

  final int width;
  final int height;
  final bool hasAlpha;
  final Uint8List _pixels;

  int get _channels => hasAlpha ? 4 : 3;

  String hexAt(int x, int y) {
    final i = (y * width + x) * _channels;
    return '#${[for (var k = 0; k < 3; k++) _pixels[i + k].toRadixString(16).padLeft(2, '0')].join().toUpperCase()}';
  }

  int alphaAt(int x, int y) => hasAlpha ? _pixels[(y * width + x) * 4 + 3] : 255;
}

