// The fullscreen viewer.
//
// The gestures individually are framework behaviour and not worth asserting.
// What is worth asserting is where they interact, because that is where a
// photo viewer goes wrong: zoom in, drag to look at the bottom of the frame,
// and a naive implementation either skips to the next photo or throws the
// viewer away entirely.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';

// Image.network cannot reach anything under test, so every photo renders the
// viewer's fallback. That is fine here: the fallback sits in the same place in
// the tree as a loaded photo, and the gestures are what these tests are about.
Future<void> _pumpViewer(
  WidgetTester tester, {
  int count = 4,
  int initialIndex = 0,
  bool reduceMotion = false,
  bool accessibleNavigation = false,
  List<String?>? captions,
  Widget Function(BuildContext, int)? actionsBuilder,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion, accessibleNavigation: accessibleNavigation),
      child: MaterialApp(
        home: RPhotoViewer(
          urls: [for (var i = 0; i < count; i++) 'https://example.test/$i.jpg'],
          initialIndex: initialIndex,
          title: 'Gallery',
          captions: captions,
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

  // --- Opened from a profile: captions, buttons for every gesture, memory. ---

  testWidgets('the counter is right on the first and on the last photo', (tester) async {
    await _pumpViewer(tester, count: 3);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('3 of 3'), findsOneWidget);

    // Past the end is not a fourth photo.
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('3 of 3'), findsOneWidget);
  });

  testWidgets('a single photo opens without a crash and offers no paging', (tester) async {
    await _pumpViewer(tester, count: 1);
    expect(tester.takeException(), isNull);
    expect(find.text('1 of 1'), findsOneWidget);
    expect(find.byTooltip('Previous photo'), findsNothing);
    expect(find.byTooltip('Next photo'), findsNothing);
  });

  testWidgets('each photo shows its own caption, and none where it has none', (tester) async {
    await _pumpViewer(tester, count: 3, captions: const ['Weddings', null, 'Portraits']);
    expect(find.text('Weddings'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Weddings'), findsNothing);
    expect(find.text('Portraits'), findsNothing);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Portraits'), findsOneWidget);
  });

  testWidgets('next and previous buttons page without a swipe', (tester) async {
    await _pumpViewer(tester, count: 3);
    expect(find.byTooltip('Previous photo'), findsNothing, reason: 'nothing before the first photo');

    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();
    expect(find.text('3 of 3'), findsOneWidget);
    expect(find.byTooltip('Next photo'), findsNothing, reason: 'nothing after the last photo');

    await tester.tap(find.byTooltip('Previous photo'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 3'), findsOneWidget);
  });

  testWidgets('a zoom button does what pinch and double-tap do', (tester) async {
    await _pumpViewer(tester, count: 2);
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).physics, isA<NeverScrollableScrollPhysics>());

    await tester.tap(find.byTooltip('Zoom out'));
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(find.byType(PageView)).physics, isA<PageScrollPhysics>());
  });

  testWidgets('the close button is labelled, large, and closes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showRPhotoViewer(context, urls: const ['https://example.test/0.jpg'], initialIndex: 0),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Close photo viewer'), findsOneWidget);
    final size = tester.getSize(find.byTooltip('Close photo viewer'));
    expect(size.width, greaterThanOrEqualTo(56));
    expect(size.height, greaterThanOrEqualTo(56));
    semantics.dispose();

    await tester.tap(find.byTooltip('Close photo viewer'));
    await tester.pumpAndSettle();
    expect(find.byType(RPhotoViewer), findsNothing);
  });

  testWidgets('changing photo is announced, with its caption', (tester) async {
    await _pumpViewer(tester, count: 3, captions: const [null, 'Weddings', null]);
    tester.takeAnnouncements();

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(tester.takeAnnouncements().map((a) => a.message), contains('Photo 2 of 3, Weddings'));
  });

  testWidgets('a tap hides the controls, after the double-tap window', (tester) async {
    await _pumpViewer(tester, count: 3);
    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip('Close photo viewer'), findsNothing);
  });

  testWidgets('with a screen reader on, a tap leaves the controls in place', (tester) async {
    await _pumpViewer(tester, count: 3, accessibleNavigation: true);
    await tester.tapAt(tester.getCenter(find.byType(PageView)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip('Close photo viewer'), findsOneWidget);
    expect(find.byTooltip('Next photo'), findsOneWidget);
  });

  testWidgets('an empty caption shows nothing, not a blank line', (tester) async {
    await _pumpViewer(tester, count: 2, captions: const ['', 'Weddings']);
    expect(find.descendant(of: find.byType(RPhotoViewer), matching: find.text('')), findsNothing);
  });

  testWidgets('photos more than one away are released from memory', (tester) async {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    await _pumpViewer(tester, count: 5);
    // Stand in for decoded frames: whatever is cached under these keys is
    // what the viewer has to let go of.
    final held = [
      for (var i = 0; i < 5; i++) cache.putIfAbsent(DiskCachedImage('https://example.test/$i.jpg'), () => _FakeCompleter()),
    ];

    for (var page = 0; page < 3; page++) {
      await tester.tap(find.byTooltip('Next photo'));
      await tester.pumpAndSettle();
    }
    expect(find.text('4 of 5'), findsOneWidget);
    expect(cache.containsKey(DiskCachedImage('https://example.test/0.jpg')), isFalse, reason: 'three away and still held');
    expect(cache.containsKey(DiskCachedImage('https://example.test/1.jpg')), isFalse, reason: 'two away and still held');
    // The same decoded frame, not one fetched again after being thrown away.
    final previous = cache.putIfAbsent(DiskCachedImage('https://example.test/2.jpg'), () => _FakeCompleter());
    expect(identical(previous, held[2]), isTrue, reason: 'the previous photo is kept for the swipe back');
  });

  testWidgets('closing the viewer releases every photo it held', (tester) async {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    await _pumpViewer(tester, count: 3);
    for (var i = 0; i < 3; i++) {
      cache.putIfAbsent(DiskCachedImage('https://example.test/$i.jpg'), () => _FakeCompleter());
    }
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 3; i++) {
      expect(cache.containsKey(DiskCachedImage('https://example.test/$i.jpg')), isFalse);
    }
  });

  testWidgets('under reduced motion the buttons change photo without a slide', (tester) async {
    await _pumpViewer(tester, count: 3, reduceMotion: true);
    await tester.tap(find.byTooltip('Next photo'));
    // One frame: no animation to wait for.
    await tester.pump();
    expect(find.text('2 of 3'), findsOneWidget);
  });

  testWidgets('only the next and previous photos are fetched ahead', (tester) async {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    await tester.pumpWidget(
      MaterialApp(
        home: RPhotoViewer(
          urls: [for (var i = 0; i < 5; i++) 'https://example.test/$i.jpg'],
          initialIndex: 2,
        ),
      ),
    );
    // The frame after the first, where the prefetch runs.
    await tester.pump();
    expect(cache.containsKey(DiskCachedImage('https://example.test/1.jpg')), isTrue);
    expect(cache.containsKey(DiskCachedImage('https://example.test/3.jpg')), isTrue);
    expect(cache.containsKey(DiskCachedImage('https://example.test/0.jpg')), isFalse);
    expect(cache.containsKey(DiskCachedImage('https://example.test/4.jpg')), isFalse);
  });
}

class _FakeCompleter extends ImageStreamCompleter {}
