// Start-up is one dark screen: the native launch screen (iOS storyboard,
// Android launch theme) and the first Flutter frame (/launch) share the Ink
// 950 ground, in both flavors and in light and dark mode alike.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

import 'png_reader.dart';

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
final _ground = _hex(RInk.i950);
const _res = 'android/app/src/main/res';

/// A storyboard's view background, as a hex colour.
String _storyboardGround(String xml) {
  final m = RegExp(r'<color key="backgroundColor" red="([\d.]+)" green="([\d.]+)" blue="([\d.]+)"').firstMatch(xml)!;
  return '#${[for (var i = 1; i <= 3; i++) (double.parse(m.group(i)!) * 255).round().toRadixString(16).padLeft(2, '0')].join().toUpperCase()}';
}

void main() {
  group('iOS', () {
    for (final name in ['LaunchScreenClient', 'LaunchScreenPro']) {
      test('$name: the logo, centred, on Ink 950', () {
        final xml = File('ios/Runner/$name.storyboard').readAsStringSync();
        expect(_storyboardGround(xml), _ground);
        expect(xml, contains('image="LaunchLogo"'));
        expect(RegExp(r'firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX"').hasMatch(xml), isTrue);
        expect(RegExp(r'firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY"').hasMatch(xml), isTrue);
        expect(xml, isNot(contains('<label')), reason: 'no loading text');
      });
    }

    test('each flavor uses its storyboard', () {
      expect(File('ios/Flutter/Client.xcconfig').readAsStringSync(), contains('LAUNCH_STORYBOARD_NAME = LaunchScreenClient'));
      expect(File('ios/Flutter/Pro.xcconfig').readAsStringSync(), contains('LAUNCH_STORYBOARD_NAME = LaunchScreenPro'));
    });

    test('the launch logo at 1x, 2x and 3x', () {
      const set = 'ios/Runner/Assets.xcassets/LaunchLogo.imageset';
      final widths = [for (final k in [1, 2, 3]) Png.read('$set/LaunchLogo@${k}x.png').width];
      expect(widths, [200, 400, 600]);
    });
  });

  group('Android', () {
    test('the launch background is the logo, centred, on the launch ground', () {
      for (final dir in ['drawable', 'drawable-v21']) {
        final xml = File('$_res/$dir/launch_background.xml').readAsStringSync();
        expect(xml, contains('@color/launch_ground'), reason: dir);
        expect(xml, contains('android:gravity="center" android:src="@drawable/launch_logo"'), reason: dir);
      }
      for (final (density, k) in [('mdpi', 1.0), ('hdpi', 1.5), ('xhdpi', 2.0), ('xxhdpi', 3.0), ('xxxhdpi', 4.0)]) {
        expect(Png.read('$_res/drawable-$density/launch_logo.png').width, (200 * k).round(), reason: density);
      }
    });

    test('the launch ground is Ink 950 for both flavors', () {
      for (final flavor in ['client', 'pro']) {
        expect(File('android/app/src/$flavor/res/values/colors.xml').readAsStringSync(), contains('<color name="launch_ground">#FF${_ground.substring(1)}</color>'), reason: flavor);
      }
    });

    test('light and dark mode alike: no theme falls back to the OS background', () {
      for (final dir in ['values', 'values-night', 'values-v31', 'values-night-v31']) {
        final xml = File('$_res/$dir/styles.xml').readAsStringSync();
        expect(xml, isNot(contains('?android:colorBackground</item>')), reason: dir);
        expect(RegExp(r'<style name="NormalTheme"[^>]*>\s*(<!--[\s\S]*?-->\s*)?<item name="android:windowBackground">@color/launch_ground</item>').hasMatch(xml), isTrue, reason: '$dir NormalTheme');
      }
      for (final dir in ['values-v31', 'values-night-v31']) {
        final xml = File('$_res/$dir/styles.xml').readAsStringSync();
        expect(xml, contains('<item name="android:windowSplashScreenBackground">@color/launch_ground</item>'), reason: dir);
      }
    });
  });

  group('the first Flutter frame', () {
    for (final (flavor, theme) in [('client', buildClientTheme()), ('pro', buildProTheme())]) {
      testWidgets('$flavor: /launch paints the native ground, light text, no white', (tester) async {
        await tester.pumpWidget(MaterialApp(theme: theme, home: const LaunchScreen(title: 'RAWWERS')));
        expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, RInk.i950);
        expect(LaunchScreen.ground, RInk.i950);
        expect(tester.widget<Text>(find.text('RAWWERS')).style!.color, RInk.i050);
      });
    }
  });
}
