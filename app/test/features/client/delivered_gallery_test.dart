// The photographs a client has paid for.
//
// Three things here are load-bearing:
//
//   - Only what the server unlocked appears. The gallery listing holds every
//     photo the photographer uploaded, and the unchosen ones are not this
//     client's. Showing them would offer photos that are not theirs.
//   - Full screen shows the original, never the watermarked preview. A
//     watermark on a photograph someone has already bought is absurd, and the
//     listing offers nothing but a thumbnail and a watermarked copy - so
//     getting this wrong looks completely normal in code and is obvious to
//     the one person who matters.
//   - Originals are not read ahead. A 4288px frame decodes to roughly 48MB.
//
// Saving is tested against a fake saver; what the real one does with each
// failure is in test/core/download/photo_saver_test.dart.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/download/photo_saver.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';
import 'package:rawwers/features/client/gallery/delivered_gallery_screen.dart';

class _FakeDelivered extends DeliveredController {
  _FakeDelivered(this._photos, {Map<String, String>? freshLinks}) : _freshLinks = freshLinks;
  final List<DeliveredPhoto> _photos;

  /// What the downloads endpoint would mint now. Defaults to each photo's
  /// page-load link; an absent key is the endpoint failing.
  final Map<String, String>? _freshLinks;
  final linkRequests = <String>[];

  @override
  Future<DeliveredState> build(String galleryId) async => DeliveredState(photos: _photos);

  @override
  Future<String?> freshLinkFor(String assetId) async {
    linkRequests.add(assetId);
    final links = _freshLinks ?? {for (final p in _photos) p.assetId: '${p.finalUrl}?fresh'};
    return links[assetId];
  }
}

class _FakeSaver implements PhotoSaver {
  _FakeSaver([this.outcome = const Saved()]);

  final SaveOutcome outcome;
  final saved = <String>[];

  /// Held open by a test that wants to see the in-progress state.
  Completer<void>? gate;

  @override
  Future<SaveOutcome> save(String url, {required String name, void Function(double)? onProgress}) async {
    saved.add(url);
    onProgress?.call(0.4);
    await gate?.future;
    return outcome;
  }
}

DeliveredPhoto _photo(int i) => DeliveredPhoto(
      item: GalleryItemView(
        mediaAssetId: 'asset-$i',
        sortOrder: i + 1,
        thumbnailUrl: 'https://example.test/$i-thumb.jpg',
        watermarkPreviewUrl: 'https://example.test/$i-WATERMARKED.jpg',
      ),
      finalUrl: 'https://example.test/$i-original.jpg',
    );

/// A message shown over the photo, where the person is looking. A snackbar
/// goes to every Scaffold, so the grid underneath gets a copy too; that one
/// is not what they read.
Finder _inViewer(Finder finder) => find.descendant(of: find.byType(RPhotoViewer), matching: finder);

Future<void> _pump(
  WidgetTester tester,
  List<DeliveredPhoto> photos, {
  _FakeDelivered? controller,
  _FakeSaver? saver,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deliveredControllerProvider('g1').overrideWith(() => controller ?? _FakeDelivered(photos)),
        photoSaverProvider.overrideWithValue(saver ?? _FakeSaver()),
      ],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const DeliveredGalleryScreen(galleryId: 'g1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // The rule is tested on the function that implements it, not through a
  // fake controller. An earlier version of this test overrode build() and
  // handed the screen a pre-filtered list, so it passed happily against a
  // controller changed to show the whole gallery - it was testing the fake.
  group('what the client owns', () {
    final gallery = [
      GalleryItemView(mediaAssetId: 'bought-1', sortOrder: 1, thumbnailUrl: 't1'),
      GalleryItemView(mediaAssetId: 'not-bought', sortOrder: 2, thumbnailUrl: 't2'),
      GalleryItemView(mediaAssetId: 'bought-2', sortOrder: 3, thumbnailUrl: 't3'),
    ];

    test('only assets the downloads response carried a link for', () {
      final photos = crossGalleryWithLinks(gallery, {
        'bought-1': 'https://example.test/1-original.jpg',
        'bought-2': 'https://example.test/2-original.jpg',
      });
      expect(photos.map((p) => p.assetId), ['bought-1', 'bought-2']);
    });

    test('gallery order is kept, not download-response order', () {
      final photos = crossGalleryWithLinks(gallery, {
        'bought-2': 'https://example.test/2-original.jpg',
        'bought-1': 'https://example.test/1-original.jpg',
      });
      expect(photos.map((p) => p.assetId), ['bought-1', 'bought-2']);
    });

    test('an empty link is not a photo', () {
      // The shape a careless refactor produces: iterate everything, fall back
      // to '' when no link exists. That shows unbought photos.
      final photos = crossGalleryWithLinks(gallery, {'bought-1': '', 'bought-2': 'u'});
      expect(photos.map((p) => p.assetId), ['bought-2']);
    });

    test('nothing paid for yields nothing', () {
      expect(crossGalleryWithLinks(gallery, const {}), isEmpty);
    });
  });

  testWidgets('the grid renders what the controller says is owned', (tester) async {
    await _pump(tester, [_photo(0), _photo(1)]);
    expect(find.byType(RImageTile), findsNWidgets(2));
  });

  testWidgets('full screen shows the original, never the watermarked preview', (tester) async {
    await _pump(tester, [_photo(0), _photo(1)]);

    await tester.tap(find.byType(RImageTile).first);
    await tester.pumpAndSettle();

    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(
      viewer.urls,
      ['https://example.test/0-original.jpg', 'https://example.test/1-original.jpg'],
    );
    for (final url in viewer.urls) {
      expect(
        url,
        isNot(contains('WATERMARKED')),
        reason: 'a watermark on a photo the client has already paid for',
      );
    }
  });

  testWidgets('originals are not read ahead', (tester) async {
    await _pump(tester, [_photo(0), _photo(1), _photo(2)]);
    await tester.tap(find.byType(RImageTile).first);
    await tester.pumpAndSettle();

    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(
      viewer.prefetchNeighbours,
      isFalse,
      reason: 'three 4288px frames is ~145MB and gets the app killed',
    );
  });

  testWidgets('nothing paid for yet reads as waiting, not as an error', (tester) async {
    await _pump(tester, const []);
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.byType(RImageTile), findsNothing);
  });

  group('saving a photo', () {
    Future<void> openViewer(WidgetTester tester, int index) async {
      await tester.tap(find.byType(RImageTile).at(index));
      await tester.pumpAndSettle();
    }

    testWidgets('the grid offers no save; full screen does', (tester) async {
      await _pump(tester, [_photo(0)]);
      expect(find.byType(SavePhotoButton), findsNothing);

      await openViewer(tester, 0);
      expect(find.byType(SavePhotoButton), findsOneWidget);
      expect(find.text('Save to Photos'), findsOneWidget);
    });

    testWidgets('only bought photos can be saved, each with a freshly minted link', (tester) async {
      // Built through the real rule, not a hand-filtered list: the gallery
      // holds an unbought photo and only the downloads response decides.
      final gallery = [
        GalleryItemView(mediaAssetId: 'bought-1', sortOrder: 1, thumbnailUrl: 't1'),
        GalleryItemView(mediaAssetId: 'not-bought', sortOrder: 2, thumbnailUrl: 't2'),
        GalleryItemView(mediaAssetId: 'bought-2', sortOrder: 3, thumbnailUrl: 't3'),
      ];
      final photos = crossGalleryWithLinks(gallery, {
        'bought-1': 'https://storage.test/1-original.jpg',
        'bought-2': 'https://storage.test/2-original.jpg',
      });
      final controller = _FakeDelivered(photos);
      final saver = _FakeSaver();
      await _pump(tester, photos, controller: controller, saver: saver);

      // Every photo the viewer can page to, saved in turn.
      await openViewer(tester, 0);
      for (var page = 0; page < photos.length; page++) {
        await tester.tap(find.text('Save to Photos'));
        await tester.pumpAndSettle();
        ScaffoldMessenger.of(tester.element(find.byType(SavePhotoButton))).removeCurrentSnackBar();
        await tester.pumpAndSettle();
        if (page < photos.length - 1) {
          await tester.drag(find.byType(PageView), const Offset(-600, 0));
          await tester.pumpAndSettle();
        }
      }

      expect(controller.linkRequests, ['bought-1', 'bought-2']);
      expect(saver.saved, [
        'https://storage.test/1-original.jpg?fresh',
        'https://storage.test/2-original.jpg?fresh',
      ], reason: 'the link minted at tap time, not the one from page load');
    });

    testWidgets('saving shows progress and cannot be started twice', (tester) async {
      final saver = _FakeSaver()..gate = Completer<void>();
      await _pump(tester, [_photo(0)], saver: saver);
      await openViewer(tester, 0);

      await tester.tap(find.text('Save to Photos'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Saving… 40%'), findsOneWidget);

      await tester.tap(find.text('Saving… 40%'));
      await tester.pump();
      expect(saver.saved, hasLength(1), reason: 'a second tap mid-save starts nothing');

      saver.gate!.complete();
      await tester.pumpAndSettle();
      expect(_inViewer(find.text('Saved to your photos.')), findsOneWidget);
      expect(find.text('Save to Photos'), findsOneWidget);
    });

    for (final failure in SaveFailure.values) {
      testWidgets('a failed save says why: ${failure.name}', (tester) async {
        await _pump(tester, [_photo(0)], saver: _FakeSaver(SaveFailed(failure)));
        await openViewer(tester, 0);

        await tester.tap(find.text('Save to Photos'));
        await tester.pumpAndSettle();

        expect(_inViewer(find.text(failure.message)), findsOneWidget);
        expect(_inViewer(find.text('Saved to your photos.')), findsNothing);
        expect(find.text('Save to Photos'), findsOneWidget, reason: 'free to try again');
      });
    }

    testWidgets('no link from the API is a failure the person sees, not a no-op', (tester) async {
      final saver = _FakeSaver();
      await _pump(
        tester,
        [_photo(0)],
        controller: _FakeDelivered([_photo(0)], freshLinks: const {}),
        saver: saver,
      );
      await openViewer(tester, 0);

      await tester.tap(find.text('Save to Photos'));
      await tester.pumpAndSettle();

      expect(_inViewer(find.text(SaveFailure.linkUnavailable.message)), findsOneWidget);
      expect(saver.saved, isEmpty);
    });
  });
}
