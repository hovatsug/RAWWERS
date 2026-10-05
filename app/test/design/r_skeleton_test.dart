// A loading placeholder under the OS reduced-motion setting.
//
// Its shimmer controller used to be created lazily. Under reduced motion the
// build never touched it, so dispose() was its first read - and creating a
// ticker on an element that is being torn down throws. Every screen that
// swapped a placeholder for content did that, for anyone with Reduce Motion
// on. Found by the niche navigation test, which turns reduced motion on to
// stop the hero's pan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_skeleton.dart';

Widget _app({required bool reduceMotion, required bool showSkeleton}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: showSkeleton ? const RSkeleton(width: 40) : const Text('loaded')),
      ),
    );

void main() {
  for (final reduceMotion in [true, false]) {
    testWidgets('a placeholder can be replaced by its content (reduce motion: $reduceMotion)', (tester) async {
      await tester.pumpWidget(_app(reduceMotion: reduceMotion, showSkeleton: true));
      await tester.pump();

      await tester.pumpWidget(_app(reduceMotion: reduceMotion, showSkeleton: false));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('loaded'), findsOneWidget);
    });
  }

  testWidgets('under reduced motion the placeholder holds still', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true, showSkeleton: true));
    // Nothing is animating, so the tree settles. A shimmer still running
    // would time this out.
    await tester.pumpAndSettle();
    expect(find.byType(RSkeleton), findsOneWidget);
  });
}
