// The generated app icons (tools/brand): every file the platforms need, at
// its exact size, iOS without an alpha channel, Android's adaptive artwork
// inside the safe circle, and the two flavors told apart.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';

/// Just enough PNG to check an icon: 8-bit RGB or RGBA, not interlaced -
/// what the generator writes.
class _Png {
  _Png._(this.width, this.height, this.hasAlpha, this._pixels);

  factory _Png.read(String path) {
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
    return _Png._(width, height, colourType == 6, out);
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

const _ios = 'ios/Runner/Assets.xcassets';
const _android = 'android/app/src';
const _densities = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

String _token(String name) {
  final match = RegExp('static const $name = Color\\(0xFF([0-9A-Fa-f]{6})\\)').firstMatch(File('lib/design/tokens.dart').readAsStringSync());
  return '#${match!.group(1)!.toUpperCase()}';
}

void main() {
  // What iOS asks of an app icon set, independent of the generator's list.
  const iosSizes = {
    'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40, 'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29, 'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80, 'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120, 'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76, 'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167, 'Icon-App-1024x1024@1x.png': 1024,
  };

  for (final flavor in ['client', 'pro']) {
    group('$flavor icon', () {
      final ground = flavor == 'client' ? _token('i950') : _token('paper');

      test('iOS: every size, exact, no alpha channel, square corners on the ground', () {
        final set = '$_ios/AppIcon-$flavor.appiconset';
        final contents = File('$set/Contents.json').readAsStringSync();
        for (final MapEntry(key: name, value: px) in iosSizes.entries) {
          expect(contents, contains('"$name"'), reason: 'Contents.json lists $name');
          final png = _Png.read('$set/$name');
          expect((png.width, png.height), (px, px), reason: name);
          expect(png.hasAlpha, isFalse, reason: '$name: the App Store rejects an icon with alpha');
        }
        final master = _Png.read('$set/Icon-App-1024x1024@1x.png');
        for (final (x, y) in [(0, 0), (1023, 0), (0, 1023), (1023, 1023), (512, 4)]) {
          expect(master.hexAt(x, y), ground, reason: 'not pre-rounded: the corner ($x, $y) is the ground');
        }
      });

      test('Android: adaptive layers and a legacy icon at every density', () {
        final res = '$_android/$flavor/res';
        for (final MapEntry(key: density, value: k) in _densities.entries) {
          for (final (name, dp) in [('ic_launcher', 48), ('ic_launcher_foreground', 108), ('ic_launcher_monochrome', 108)]) {
            final png = _Png.read('$res/mipmap-$density/$name.png');
            expect((png.width, png.height), ((dp * k).round(), (dp * k).round()), reason: '$density/$name');
          }
        }
        final xml = File('$res/mipmap-anydpi-v26/ic_launcher.xml').readAsStringSync();
        for (final layer in ['background', 'foreground', 'monochrome']) {
          expect(xml, contains('<$layer '), reason: layer);
        }
        expect(File('$res/values/ic_launcher_background.xml').readAsStringSync(), contains('>$ground<'));
      });

      test('Android: the foreground and monochrome artwork sit inside the 66dp safe circle', () {
        for (final layer in ['ic_launcher_foreground', 'ic_launcher_monochrome']) {
          final png = _Png.read('$_android/$flavor/res/mipmap-xxxhdpi/$layer.png');
          expect(png.hasAlpha, isTrue, reason: '$layer: a transparent layer');
          final radius = png.width * 33 / 108;
          final centre = png.width / 2;
          var inked = 0;
          for (var y = 0; y < png.height; y++) {
            for (var x = 0; x < png.width; x++) {
              if (png.alphaAt(x, y) == 0) continue;
              inked++;
              final distance = math.sqrt(math.pow(x + 0.5 - centre, 2) + math.pow(y + 0.5 - centre, 2));
              expect(distance, lessThanOrEqualTo(radius), reason: '$layer: ink at ($x, $y) is outside the safe circle');
            }
          }
          expect(inked, greaterThan(0), reason: '$layer has artwork');
        }
      });
    });
  }

  test('the two flavors are told apart: no icon is byte-identical across them', () {
    for (final path in [
      '$_ios/AppIcon-%s.appiconset/Icon-App-1024x1024@1x.png',
      '$_ios/AppIcon-%s.appiconset/Icon-App-60x60@3x.png',
      '$_android/%s/res/mipmap-xxxhdpi/ic_launcher.png',
      '$_android/%s/res/mipmap-xxxhdpi/ic_launcher_foreground.png',
    ]) {
      final client = File(path.replaceAll('%s', 'client')).readAsBytesSync();
      final pro = File(path.replaceAll('%s', 'pro')).readAsBytesSync();
      expect(listEquals(client, pro), isFalse, reason: path);
    }
  });

  test('the pro icon is on paper, the client icon on ink', () {
    expect(_Png.read('$_ios/AppIcon-pro.appiconset/Icon-App-1024x1024@1x.png').hexAt(8, 8), _token('paper'));
    expect(_Png.read('$_ios/AppIcon-client.appiconset/Icon-App-1024x1024@1x.png').hexAt(8, 8), _token('i950'));
    expect(_Png.read('$_android/pro/res/mipmap-xxxhdpi/ic_launcher.png').hexAt(8, 8), _token('paper'));
  });

  test('each flavor builds with its own set: the xcconfigs choose, the project does not override', () {
    expect(File('ios/Flutter/Client.xcconfig').readAsStringSync(), contains('ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-client'));
    expect(File('ios/Flutter/Pro.xcconfig').readAsStringSync(), contains('ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-pro'));
    expect(File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(), isNot(contains('ASSETCATALOG_COMPILER_APPICON_NAME')));
    expect(Directory('$_ios/AppIcon.appiconset').existsSync(), isFalse, reason: 'the Flutter template set is gone');
    for (final density in _densities.keys) {
      expect(File('$_android/main/res/mipmap-$density/ic_launcher.png').existsSync(), isFalse, reason: 'template icon in main/');
    }
    expect(File('$_android/main/AndroidManifest.xml').readAsStringSync(), contains('android:icon="@mipmap/ic_launcher"'));
  });

  test('web: favicons and the manifest icons, at their sizes, in brand colours', () {
    for (final (path, px) in [
      ('../web/app/icon.png', 32),
      ('../web/app/apple-icon.png', 180),
      ('../web/public/icons/icon-192.png', 192),
      ('../web/public/icons/icon-512.png', 512),
    ]) {
      final png = _Png.read(path);
      expect((png.width, png.height), (px, px), reason: path);
    }
    expect(File('../web/app/icon.svg').existsSync(), isTrue);
    final manifest = File('../web/public/manifest.webmanifest').readAsStringSync();
    for (final icon in ['/icons/icon-192.png', '/icons/icon-512.png']) {
      expect(manifest, contains('"$icon"'));
    }
    expect(manifest, contains('"background_color": "${_token('i950')}"'));
    expect(manifest, isNot(contains('#0ea5e9')), reason: 'the old off-brand blue');
  });
}
