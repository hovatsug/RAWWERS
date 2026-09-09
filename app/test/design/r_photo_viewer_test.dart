// The fullscreen viewer.
//
// The gestures individually are framework behaviour and not worth asserting.
// What is worth asserting is where they interact, because that is where a
// photo viewer goes wrong: zoom in, drag to look at the bottom of the frame,
// and a naive implementation either skips to the next photo or throws the
// viewer away entirely.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';

// Image.network cannot reach anything under test, so every photo renders the
// viewer's fallback. That is fine here: the fallback sits in the same place in
// the tree as a loaded photo, and the gestures are what these tests are about.
Future<void> _pumpViewer(
  WidgetTester tester, {
  int count = 4,
  int initialIndex = 0,
  bool reduceMotion = false,
  Widget Function(BuildContext, int)? actionsBuilder,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        home: RPhotoViewer(
          urls: [for (var i = 0; i < count; i++) 'https://example.test/$i.jpg'],
          initialIndex: initialIndex,
          title: 'Gallery',
          actionsBuilder: actionsBuilder,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on the photo that was tapped, not the first one', (tester) async {
    await _pumpViewer(tester, count: 5, initialIndex: 3);
    expect(find.text('4 of 5'), findsOneWidget);
  });

  testWidgets('swiping pages between photos and the counter follows', (tester) async {
    await _pumpViewer(tester, count: 5);
    expect(find.text('1 of 5'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 of 5'), findsOneWidget);
  });

  testWidgets('a zoomed photo does not page away when panned sideways', (tester) async {
    // The interaction that matters. Zoomed in, a horizontal drag has to move
    // within the photo; if it pages, you cannot look at the left edge of a
    // frame without losing it.
    await _pumpViewer(tester, count: 5);
    final viewer = tester.state<State<RPhotoViewer>>(find.byType(RPhotoViewer));

    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(
      pageView.physics,
      isA<NeverScrollableScrollPhysics>(),
      reason: 'paging must be off while zoomed or a pan skips to the next photo',
    );

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('1 of 5'), findsOneWidget, reason: 'panning a zoomed photo changed the page');
    expect(viewer.mounted, isTrue);
  });

  testWidgets('double-tap toggles zoom back off', (tester) async {
    await _pumpViewer(tester, count: 3);
    final center = tester.getCenter(find.byType(PageView));

    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).physics, isA<NeverScrollableScrollPhysics>());

    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pumpAndSettle();
    expect(
      tester.widget<PageView>(find.byType(PageView)).physics,
      isA<PageScrollPhysics>(),
      reason: 'zooming back out must restore paging',
    );
  });

  testWidgets('a downward drag dismisses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showRPhotoViewer(
                  context,
                  urls: const ['https://example.test/0.jpg', 'https://example.test/1.jpg'],
                  initialIndex: 0,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsNothing, reason: 'a downward drag should close the viewer');
  });

  testWidgets('a zoomed photo is not dismissed by dragging down inside it', (tester) async {
    // Asserts the outcome, not the mechanism, and the distinction is worth
    // recording: removing the `if (_zoomed) return` guard from the drag
    // handlers does *not* make this fail, because InteractiveViewer wins the
    // gesture arena while zoomed and the drag never reaches the handler at
    // all. The guard is kept as defence for the case where a zoomed photo is
    // panned to its boundary and the pan is not claimed - which this test
    // cannot reach. Treat the guard as unverified rather than covered.
    await _pumpViewer(tester, count: 3);
    final center = tester.getCenter(find.byType(PageView));

    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsOneWidget, reason: 'panning a zoomed photo closed the viewer');
  });

  testWidgets('a missing url renders the quiet placeholder, not an error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RPhotoViewer(urls: [null, ''], initialIndex: 0),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.photo_camera_outlined), findsWidgets);
    expect(find.text('1 of 2'), findsOneWidget);
  });

  // Not covered, and deliberately recorded as such: _onPageChanged resets the
  // transform so a new photo never inherits the previous one's zoom. Paging is
  // disabled while zoomed, so a widget test cannot page with a transform set,
  // and deleting the reset leaves every test here green. It guards a real
  // edge - fling momentum settling after a zoom begins - that needs a device
  // to reproduce.

  testWidgets('caller controls are shown over the photo', (tester) async {
    await _pumpViewer(
      tester,
      count: 3,
      actionsBuilder: (context, index) => Text('control for $index'),
    );
    expect(find.text('control for 0'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('control for 1'), findsOneWidget, reason: 'controls must track the visible photo');
  });

  testWidgets('reduced motion opens with no transition', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showRPhotoViewer(
                    context,
                    urls: const ['https://example.test/0.jpg'],
                    initialIndex: 0,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // One frame, no settling: with animations disabled the viewer is already
    // there rather than fading in.
    await tester.pump();
    expect(find.byType(RPhotoViewer), findsOneWidget);
  });
}
