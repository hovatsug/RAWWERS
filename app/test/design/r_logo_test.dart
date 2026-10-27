// RLogo: the generated SVG files, at their own proportions, one-colour under
// the minimum width, read as "RAWWERS", and painted in the first frame once
// precached.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/brand.dart';
import 'package:rawwers/design/components/r_logo.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  test('the app and the admin draw the very files design/brand holds', () {
    for (final name in ['logo-primary-on-dark', 'logo-primary-on-light', 'logo-mono-ink', 'logo-mono-white']) {
      final source = File('../design/brand/$name.svg').readAsBytesSync();
      for (final copy in ['assets/brand/$name.svg', '../web/public/brand/$name.svg']) {
        expect(listEquals(File(copy).readAsBytesSync(), source), isTrue, reason: '$copy is not design/brand/$name.svg: run make brand');
      }
    }
    expect(RLogo.assetFor(RLogoTone.primaryOnDark), 'assets/brand/logo-primary-on-dark.svg');
    expect(RLogo.assetFor(RLogoTone.monoWhite), 'assets/brand/logo-mono-white.svg');
  });

  test('the proportions are the files\' own', () {
    for (final tone in RLogoTone.values) {
      final svg = File(RLogo.assetFor(tone)).readAsStringSync();
      final m = RegExp(r'viewBox="0 0 ([\d.]+) ([\d.]+)"').firstMatch(svg)!;
      expect(RBrand.logoAspectRatio, closeTo(double.parse(m.group(1)!) / double.parse(m.group(2)!), 1e-9), reason: '$tone');
    }
  });

  testWidgets('the width sets the size; the height follows', (tester) async {
    for (final width in [80.0, 120.0, 200.0, 320.0]) {
      await tester.pumpWidget(_host(RLogo(tone: RLogoTone.primaryOnLight, width: width)));
      expect(tester.getSize(find.byType(RLogo)), Size(width, width / RBrand.logoAspectRatio));
    }
  });

  test('under the minimum width the two-colour logo gives way to the mono one', () {
    final min = RBrand.logoMinPrimaryWidth;
    expect(RLogo(tone: RLogoTone.primaryOnDark, width: min).drawn, RLogoTone.primaryOnDark);
    expect(RLogo(tone: RLogoTone.primaryOnLight, width: min).drawn, RLogoTone.primaryOnLight);
    expect(RLogo(tone: RLogoTone.primaryOnDark, width: min - 1).drawn, RLogoTone.monoWhite);
    expect(RLogo(tone: RLogoTone.primaryOnLight, width: min - 1).drawn, RLogoTone.monoInk);
    expect(RLogo(tone: RLogoTone.monoInk, width: 400).drawn, RLogoTone.monoInk);
    expect(RLogo(tone: RLogoTone.monoWhite, width: 40).drawn, RLogoTone.monoWhite);
  });

  test('RLogo.on picks the two-colour logo for the ground', () {
    expect(RLogo.on(Brightness.dark, width: 200).tone, RLogoTone.primaryOnDark);
    expect(RLogo.on(Brightness.light, width: 200).tone, RLogoTone.primaryOnLight);
  });

  testWidgets('a screen reader hears "RAWWERS", once, as an image', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(RLogo(tone: RLogoTone.primaryOnDark, width: 200)));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('RAWWERS'), findsOneWidget);
    expect(tester.getSemantics(find.byType(RLogo)), matchesSemantics(label: 'RAWWERS', isImage: true));
    handle.dispose();
  });

  testWidgets('precached, the logo paints in the frame it first appears in', (tester) async {
    await tester.runAsync(RLogo.precache);
    for (final tone in RLogoTone.values) {
      expect(RLogo.isPrecached(tone), isTrue, reason: '$tone');
    }
    await tester.pumpWidget(_host(RLogo(tone: RLogoTone.primaryOnDark, width: 200)));
    // One frame, no settling: the picture must be there already, not a
    // placeholder waiting for an asynchronous decode.
    expect(find.byType(SvgPicture), findsNothing, reason: 'fell back to the asynchronous loader');
    final paint = tester.widget<CustomPaint>(find.descendant(of: find.byType(RLogo), matching: find.byType(CustomPaint)));
    expect(paint.painter, isNotNull);
    final box = tester.renderObject<RenderCustomPaint>(find.descendant(of: find.byType(RLogo), matching: find.byType(CustomPaint)));
    expect(box.size, Size(200, 200 / RBrand.logoAspectRatio));
  });

  test('the admin sizes the logo from the same generated geometry', () {
    final ts = File('../web/lib/brand.ts').readAsStringSync();
    final aspect = RegExp(r'logoAspectRatio: ([\d.]+) / ([\d.]+),').firstMatch(ts)!;
    expect(double.parse(aspect.group(1)!) / double.parse(aspect.group(2)!), closeTo(RBrand.logoAspectRatio, 1e-12));
    expect(ts, contains('logoMinPrimaryWidth: ${RBrand.logoMinPrimaryWidth.round()},'));
    expect(ts, contains('signInLogoWidth: ${RBrand.signInLogoWidth.round()},'));
  });

  test('the admin sidebar and the web login draw the logo, not the name typed out', () {
    final layout = File('../web/app/admin/layout.tsx').readAsStringSync();
    expect(layout, contains('<Logo width={brand.logoMinPrimaryWidth} ground="dark" />'));
    expect(layout, contains('>admin</span>'));
    expect(RegExp(r'>\s*RAWWERS admin\s*<').hasMatch(layout), isFalse, reason: 'the name as text');
    final login = File('../web/app/login/page.tsx').readAsStringSync();
    expect(login, contains('<Logo width={brand.signInLogoWidth} ground="dark" />'));
    final component = File('../web/components/logo.tsx').readAsStringSync();
    expect(component, contains('width >= brand.logoMinPrimaryWidth'), reason: 'mono under the minimum width');
    expect(component, contains('alt="RAWWERS"'));
  });
}
