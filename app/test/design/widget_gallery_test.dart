import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/gallery/widget_gallery_screen.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';

const _iphoneSe = Size(375, 667);
const _largePhone = Size(430, 932);

Future<void> _pumpGalleryAt(
  WidgetTester tester, {
  required ThemeData theme,
  required Size size,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(theme: theme, home: const RWidgetGalleryScreen()),
    ),
  );
  // Not pumpAndSettle(): RSkeleton's shimmer repeats forever by design (a
  // loading placeholder that stops animating would be a bug), so settling
  // never completes. A few fixed frames is enough to catch layout/overflow
  // exceptions without waiting on an animation that isn't meant to end.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  for (final theme in [('client (dark)', buildClientTheme()), ('pro (light)', buildProTheme())]) {
    for (final viewport in [('iPhone SE', _iphoneSe), ('largest phone', _largePhone)]) {
      for (final textScale in [1.0, 1.3]) {
        testWidgets(
          'renders with no overflow: ${theme.$1}, ${viewport.$1}, textScale $textScale',
          (tester) async {
            await _pumpGalleryAt(tester, theme: theme.$2, size: viewport.$2, textScale: textScale);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('respects reduced motion - skeleton renders statically, no exception', (tester) async {
    tester.view.physicalSize = _iphoneSe;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(MaterialApp(theme: buildClientTheme(), home: const RWidgetGalleryScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
