// Screenshots of the pro You tab, for a person to look at - not goldens.
//
// Skipped unless SCREENSHOT_DIR is set; then each state is rendered at a
// phone's size with the real Archivo and Material icon fonts (tests otherwise
// draw every glyph as a box) and written there as a PNG. Nothing is
// compared and nothing is committed:
//
//   SCREENSHOT_DIR=/tmp/shots flutter test test/screenshots
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_status.dart';

import '../features/pro/you_tab_fixtures.dart';

final _dir = Platform.environment['SCREENSHOT_DIR'];

Future<void> _loadFonts() async {
  final archivo = FontLoader('Archivo')..addFont(rootBundle.load('assets/fonts/Archivo-Variable.ttf'));
  await archivo.load();
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

Future<void> _shoot(WidgetTester tester, String name, Widget app, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    if (_dir != null) await _loadFonts();
  });

  final now = DateTime.now().toUtc();
  final busy = <String, Widget Function(double)>{
    'you': (scale) => youTab(
          walletData: wallet(withdrawable: '412.50', pending: '120.00', held: '15.96'),
          next: gig(id: 'g1', status: GigStatus.scheduled, start: now.add(const Duration(days: 3))),
          pending: [
            request(id: 'r1', secondsLeft: 2 * 3600 + 14 * 60, start: now.add(const Duration(days: 9))),
            request(id: 'r2', secondsLeft: 19 * 3600, start: now.add(const Duration(days: 12))),
          ],
          gigs: [gig(id: 'g0', status: GigStatus.shootDone, start: now.subtract(const Duration(days: 2)))],
          textScale: scale,
        ),
    'you-below-minimum': (scale) => youTab(walletData: wallet(withdrawable: '41.95'), textScale: scale),
    'you-errors': (scale) => youTab(walletFails: true, availableNowFails: true, textScale: scale),
  };

  for (final MapEntry(key: name, value: build) in busy.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('screenshot $name at $scale', (tester) async {
        await _shoot(tester, '$name-${scale == 1.0 ? '1.0' : '1.3'}', build(scale));
      }, skip: _dir == null);
    }
  }

  // The whole scrolling page, top to bottom, at 1.0.
  testWidgets('screenshot you full page', (tester) async {
    await _shoot(tester, 'you-full-page-1.0', busy['you']!(1.0), size: const Size(390, 2200));
  }, skip: _dir == null);
}
