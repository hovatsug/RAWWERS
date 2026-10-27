// Start-up is one dark screen: the native launch screen (iOS storyboard,
// Android launch theme) and the first Flutter frame (/launch) share the Ink
// 950 ground, in both flavors and in light and dark mode alike.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/design/brand.dart';
import 'package:rawwers/design/components/r_logo.dart';
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
        // The width the first Flutter frame draws the logo at.
        final width = RBrand.launchLogoWidth;
        expect(xml, contains('<constraint firstAttribute="width" constant="${width.toStringAsFixed(0)}"'));
        final height = RegExp(r'<constraint firstAttribute="height" constant="([\d.]+)"').firstMatch(xml)!.group(1)!;
        expect(double.parse(height), closeTo(width / RBrand.logoAspectRatio, 0.005));
      });
    }

    test('each flavor uses its storyboard', () {
      expect(File('ios/Flutter/Client.xcconfig').readAsStringSync(), contains('LAUNCH_STORYBOARD_NAME = LaunchScreenClient'));
      expect(File('ios/Flutter/Pro.xcconfig').readAsStringSync(), contains('LAUNCH_STORYBOARD_NAME = LaunchScreenPro'));
    });

    test('the launch logo at 1x, 2x and 3x', () {
      const set = 'ios/Runner/Assets.xcassets/LaunchLogo.imageset';
      final widths = [for (final k in [1, 2, 3]) Png.read('$set/LaunchLogo@${k}x.png').width];
      expect(widths, [for (final k in [1, 2, 3]) (RBrand.launchLogoWidth * k).round()]);
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
        expect(Png.read('$_res/drawable-$density/launch_logo.png').width, (RBrand.launchLogoWidth * k).round(), reason: density);
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
    setUpAll(() async => RLogo.precache());

    for (final (flavor, theme) in [('client', buildClientTheme()), ('pro', buildProTheme())]) {
      testWidgets('$flavor: /launch paints the native ground and the logo on dark, no text', (tester) async {
        await tester.pumpWidget(MaterialApp(theme: theme, home: const LaunchScreen()));
        expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, RInk.i950);
        expect(LaunchScreen.ground, RInk.i950);
        final logo = tester.widget<RLogo>(find.byType(RLogo));
        expect(logo.drawn, RLogoTone.primaryOnDark);
        expect(logo.width, RBrand.launchLogoWidth);
        expect(find.byType(Text), findsNothing, reason: 'no loading text, no title: the logo is the name');
      });
    }

    // Where the native launch screen puts the logo: its centre on the
    // screen's centre (not the safe area's), at the launch width. The first
    // Flutter frame must draw it in exactly that rectangle, on every phone,
    // whatever the insets and the text size, and the spinner under it must
    // not move it.
    for (final (name, size, padding) in [
      ('iPhone 17', const Size(402, 874), const EdgeInsets.only(top: 62, bottom: 34)),
      ('iPhone 17 Pro Max', const Size(440, 956), const EdgeInsets.only(top: 62, bottom: 34)),
      ('iPhone SE', const Size(375, 667), const EdgeInsets.only(top: 20)),
      ('a small Android phone', const Size(360, 640), const EdgeInsets.only(top: 24, bottom: 48)),
    ]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('/launch draws the logo where the native screen does: $name, text ${scale}x', (tester) async {
          tester.view.physicalSize = size * 3;
          tester.view.devicePixelRatio = 3;
          tester.view.padding = FakeViewPadding(top: padding.top * 3, bottom: padding.bottom * 3);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          await tester.pumpWidget(MaterialApp(theme: buildProTheme(), home: const LaunchScreen()));

          final native = Rect.fromCenter(
            center: size.center(Offset.zero),
            width: RBrand.launchLogoWidth,
            height: RBrand.launchLogoWidth / RBrand.logoAspectRatio,
          );
          expect(tester.getRect(find.byType(RLogo)), rectMoreOrLessEquals(native, epsilon: 1e-9));

          final spinner = tester.getRect(find.byType(CircularProgressIndicator));
          expect(spinner.top, greaterThan(native.bottom), reason: 'the spinner sits under the logo');
          expect(spinner.center.dx, moreOrLessEquals(native.center.dx, epsilon: 1e-9));
          expect(spinner.width, lessThanOrEqualTo(RIcon.control), reason: 'small');
          expect(tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).color, RAccent.meter500);
        });
      }
    }

    testWidgets('both apps decode the logo before their first frame', (tester) async {
      for (final main in ['lib/main_client.dart', 'lib/main_pro.dart']) {
        final source = File(main).readAsStringSync();
        final precache = source.indexOf('await RLogo.precache()');
        expect(precache, greaterThan(0), reason: main);
        expect(precache, lessThan(source.indexOf('runApp(')), reason: '$main: precache after runApp');
      }
    });
  });
}
