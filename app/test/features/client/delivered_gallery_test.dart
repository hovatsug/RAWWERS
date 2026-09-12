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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';
import 'package:rawwers/features/client/gallery/delivered_gallery_screen.dart';

class _FakeDelivered extends DeliveredController {
  _FakeDelivered(this._photos);
  final List<DeliveredPhoto> _photos;

  @override
  Future<DeliveredState> build(String galleryId) async => DeliveredState(photos: _photos);
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

Future<void> _pump(WidgetTester tester, List<DeliveredPhoto> photos) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [deliveredControllerProvider('g1').overrideWith(() => _FakeDelivered(photos))],
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

  testWidgets('no save control is offered while none can work', (tester) async {
    // Deliberate: the package needed to put a file on the device cannot be
    // added without breaking code generation, and a button that cannot work
    // is worse than no button.
    await _pump(tester, [_photo(0)]);
    await tester.tap(find.byType(RImageTile).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Save'), findsNothing);
    expect(find.textContaining('Download'), findsNothing);
  });
}
