// Screenshots of the pro You tab, for a person to look at - not goldens.
//
// Skipped unless SCREENSHOT_DIR is set; then each state is rendered at a
// phone's size with the real Archivo and Material icon fonts (tests otherwise
// draw every glyph as a box) and written there as a PNG. Nothing is
// compared and nothing is committed:
//
//   SCREENSHOT_DIR=/tmp/shots flutter test test/screenshots
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gig_status.dart';

import '../features/pro/you_tab_fixtures.dart';
import 'screenshot_support.dart';

void main() {
  setUpAll(() async {
    if (screenshotDir != null) await loadScreenshotFonts();
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
    'you-available-on': (scale) => youTab(walletData: wallet(withdrawable: '412.50'), availableNowOn: true, textScale: scale),
    'you-errors': (scale) => youTab(walletFails: true, availableNowFails: true, textScale: scale),
  };

  for (final MapEntry(key: name, value: build) in busy.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('screenshot $name at $scale', (tester) async {
        await shoot(tester, '$name-${scale == 1.0 ? '1.0' : '1.3'}', build(scale));
      }, skip: screenshotDir == null);
    }
  }

  // The whole scrolling page, top to bottom, at 1.0.
  testWidgets('screenshot you full page', (tester) async {
    await shoot(tester, 'you-full-page-1.0', busy['you']!(1.0), size: const Size(390, 2200));
  }, skip: screenshotDir == null);
}
