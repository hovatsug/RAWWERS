// Choosing photographs while spending money.
//
// The assertions that matter here are not that the screen renders. They are:
//
//   - what is ticked is ONE fact, so the grid and the viewer can never
//     disagree about what the client has chosen;
//   - no money figure is ever computed locally, so the screen cannot show a
//     price nobody is charged;
//   - the minimum-10 gate reads the same in both views;
//   - a locked gallery does not appear to accept taps;
//   - tapping a thumbnail ticks it; the corner button or a long press opens
//     it full screen, and the tick is the same fact there.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/api/models/proof_gallery_response.dart';
import 'package:rawwers/api/models/proof_gallery_status.dart';
import 'package:rawwers/api/models/selection_quote_response.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/gallery/selection_controller.dart';
import 'package:rawwers/features/client/gallery/selection_gallery_screen.dart';

/// Stands in for the backend. Records what it was asked, so a test can prove
/// the app asked rather than guessed.
class _FakeSelection extends SelectionController {
  _FakeSelection({required this.itemCount, this.locked = false, this.quoteFails = false, this.amountDueFor});

  final int itemCount;
  final bool locked;
  final bool quoteFails;

  /// The server's amount due for a count; by default free until 20, then
  /// 8.00 a photo.
  final String Function(int count)? amountDueFor;

  /// Every selected_count the screen asked the server to price.
  final List<int> quotedCounts = [];

  @override
  Future<SelectionState> build(String galleryId) async {
    quotedCounts.add(0);
    return SelectionState(
      gallery: GalleryDetailResponse(
        gallery: ProofGalleryResponse(
          id: galleryId,
          gigId: 'gig-1',
          proUserId: 'pro-1',
          clientUserId: 'client-1',
          createdAt: DateTime.utc(2026, 9, 12),
          updatedAt: DateTime.utc(2026, 9, 12),
          status: locked ? ProofGalleryStatus.selectionSubmitted : ProofGalleryStatus.published,
          includedPhotos: 20,
          extraPhotoPrice: '10.00',
          currency: 'EUR',
        ),
        items: [
          for (var i = 0; i < itemCount; i++)
            GalleryItemView(
              mediaAssetId: 'asset-$i',
              sortOrder: i + 1,
              thumbnailUrl: 'https://example.test/$i-thumb.jpg',
              watermarkPreviewUrl: 'https://example.test/$i-wm.jpg',
            ),
        ],
      ),
      selectedIds: const {},
      locked: locked,
      quote: quoteFails ? null : _quote(0),
      quoteFailed: quoteFails,
    );
  }

  SelectionQuoteResponse _quote(int count) => SelectionQuoteResponse(
        selectedCount: count,
        includedPhotos: 20,
        minimumPhotos: 10,
        currency: 'EUR',
        amountTotal: '200.00',
        amountPaid: '200.00',
        // Free until 20, then 8.00 a photo - enough to tell the two apart.
        amountDue: amountDueFor?.call(count) ?? (count <= 20 ? '0.00' : '${(count - 20) * 8}.00'),
        nextPhotoPrice: count >= itemCount ? null : (count < 20 ? '0.00' : '8.00'),
        extrasCount: 0,
        canSubmit: count >= 10,
        photosStillNeeded: count >= 10 ? 0 : 10 - count,
      );

  @override
  void toggle(String assetId) {
    final current = state.valueOrNull;
    if (current == null || current.locked) return;
    final next = Set<String>.from(current.selectedIds);
    if (!next.remove(assetId)) next.add(assetId);
    quotedCounts.add(next.length);
    state = AsyncData(
      current.copyWith(
        selectedIds: next,
        quote: quoteFails ? null : _quote(next.length),
        quoteFailed: quoteFails,
        quoteStale: false,
      ),
    );
  }
}

Future<_FakeSelection> _pump(
  WidgetTester tester, {
  int itemCount = 12,
  bool locked = false,
  bool quoteFails = false,
  String Function(int count)? amountDueFor,
}) async {
  final fake = _FakeSelection(itemCount: itemCount, locked: locked, quoteFails: quoteFails, amountDueFor: amountDueFor);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [selectionControllerProvider('g1').overrideWith(() => fake)],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const SelectionGalleryScreen(galleryId: 'g1', bookingId: 'b1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

final _expand = find.byKey(const ValueKey('r-image-tile-expand'));

Future<void> _openViewer(WidgetTester tester) async {
  await tester.tap(_expand.first);
  await tester.pumpAndSettle();
}

List<RImageTile> _tiles(WidgetTester tester) => tester.widgetList<RImageTile>(find.byType(RImageTile)).toList();

void main() {
  testWidgets('a photo chosen full screen is already chosen in the grid', (tester) async {
    await _pump(tester);

    await _openViewer(tester);
    expect(find.byType(RPhotoViewer), findsOneWidget);
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    expect(find.text('Chosen'), findsOneWidget);

    // Back to the grid: the same photo must already be ticked. Two separate
    // selection sets would show nothing here.
    await tester.tap(find.byTooltip('Close photo viewer'));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<RImageTile>(find.byType(RImageTile)).toList();
    expect(tiles.first.selected, isTrue, reason: 'the grid did not see the choice made full screen');
    expect(tiles.skip(1).every((t) => !t.selected), isTrue, reason: 'the wrong photo was ticked');
  });

  testWidgets('unchoosing full screen clears it in the grid too', (tester) async {
    await _pump(tester);
    await _openViewer(tester);
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chosen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close photo viewer'));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<RImageTile>(find.byType(RImageTile)).toList();
    expect(tiles.every((t) => !t.selected), isTrue);
  });

  testWidgets('the count is the same fact in both views', (tester) async {
    await _pump(tester);
    await _openViewer(tester);
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(find.text('1 chosen'), findsOneWidget, reason: 'the viewer should show the running count');

    await tester.tap(find.byTooltip('Close photo viewer'));
    await tester.pumpAndSettle();
    expect(find.text('9 more to continue'), findsOneWidget);
  });

  testWidgets('the minimum gate counts down and then releases', (tester) async {
    final fake = await _pump(tester);
    expect(find.text('10 more to continue'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      fake.toggle('asset-$i');
    }
    await tester.pumpAndSettle();

    expect(find.text('10 chosen'), findsOneWidget);
    expect(find.text('10 more to continue'), findsNothing);
  });

  testWidgets('every price shown came from the server', (tester) async {
    final fake = await _pump(tester);

    // Nothing owed while inside the included count.
    for (var i = 0; i < 10; i++) {
      fake.toggle('asset-$i');
    }
    await tester.pumpAndSettle();
    expect(find.text('Nothing more to pay'), findsOneWidget);
    expect(find.text('The next photo is included'), findsOneWidget);

    // The screen asked the server for every count it displayed - it never
    // worked one out itself.
    expect(fake.quotedCounts, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  });

  testWidgets('the marginal price is stated outright once it is real', (tester) async {
    final fake = await _pump(tester, itemCount: 30);
    for (var i = 0; i < 21; i++) {
      fake.toggle('asset-$i');
    }
    await tester.pumpAndSettle();

    expect(find.text('EUR 8.00 to pay'), findsOneWidget);
    expect(find.text('One more adds EUR 8.00'), findsOneWidget);
  });

  testWidgets('a failed quote hides the total rather than inventing one', (tester) async {
    await _pump(tester, quoteFails: true);
    expect(find.textContaining('to pay'), findsNothing);
    expect(find.textContaining('adds'), findsNothing);
  });

  testWidgets('a submitted gallery does not accept taps in either view', (tester) async {
    final fake = await _pump(tester, locked: true);
    expect(find.textContaining('cannot be changed'), findsOneWidget);

    final tile = tester.widget<RImageTile>(find.byType(RImageTile).first);
    expect(tile.onTap, isNull, reason: 'a locked gallery must not look tappable');
    expect(tile.selectable, isFalse, reason: 'an empty ring invites a tap that does nothing');

    fake.toggle('asset-0');
    await tester.pumpAndSettle();
    final after = tester.widgetList<RImageTile>(find.byType(RImageTile)).toList();
    expect(after.every((t) => !t.selected), isTrue, reason: 'a locked gallery accepted a selection');
  });

  testWidgets('the viewer shows the full-size preview, not the grid thumbnail', (tester) async {
    await _pump(tester);
    await _openViewer(tester);
    final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
    expect(viewer.urls.first, 'https://example.test/0-wm.jpg');
  });

  group('tapping thumbnails', () {
    // A phone's height, so a few rows sit above the price bar.
    setUp(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(1200, 2400);
      view.devicePixelRatio = 2;
    });
    tearDown(() {
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    Finder photo(int number) =>
        find.byWidgetPredicate((w) => w is RImageTile && (w.semanticLabel?.startsWith('Photo $number,') ?? false));

    testWidgets('a tap ticks a photo and a second tap unticks it, without leaving the grid', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(RImageTile).at(2));
      await tester.pumpAndSettle();
      expect(find.byType(RPhotoViewer), findsNothing, reason: 'a tap on the thumbnail opened full screen');
      expect([for (final t in _tiles(tester)) t.selected].indexOf(true), 2);
      expect(find.text('9 more to continue'), findsOneWidget);

      await tester.tap(find.byType(RImageTile).at(2));
      await tester.pumpAndSettle();
      expect(_tiles(tester).every((t) => !t.selected), isTrue);
    });

    testWidgets('a photo ticked in the grid is already chosen full screen', (tester) async {
      await _pump(tester);
      await tester.tap(find.byType(RImageTile).first);
      await tester.pumpAndSettle();

      await _openViewer(tester);
      expect(find.byType(RPhotoViewer), findsOneWidget);
      expect(find.text('Chosen'), findsOneWidget);
      expect(find.text('1 chosen'), findsOneWidget);
    });

    testWidgets('a long press opens the photo full screen too', (tester) async {
      await _pump(tester);
      await tester.longPress(find.byType(RImageTile).at(3));
      await tester.pumpAndSettle();
      final viewer = tester.widget<RPhotoViewer>(find.byType(RPhotoViewer));
      expect(viewer.initialIndex, 3);
      expect(_tiles(tester).every((t) => !t.selected), isTrue, reason: 'a long press also ticked it');
    });

    testWidgets('the expand button opens the photo it is on, and ticks nothing', (tester) async {
      await _pump(tester);
      await tester.tap(_expand.at(4));
      await tester.pumpAndSettle();
      expect(tester.widget<RPhotoViewer>(find.byType(RPhotoViewer)).initialIndex, 4);
      expect(find.text('Choose'), findsOneWidget);
    });

    testWidgets('unticked tiles show an empty ring; ticked ones the check', (tester) async {
      await _pump(tester);
      expect(_tiles(tester).every((t) => t.selectable), isTrue);
      expect(find.byIcon(Icons.check), findsNothing);
      await tester.tap(find.byType(RImageTile).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('a screen reader hears which photo and whether it is selected', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester);
      await tester.tap(find.byType(RImageTile).at(11));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Photo 1, not selected'), findsOneWidget);
      expect(find.bySemanticsLabel('Photo 12, selected'), findsOneWidget);
      final node = tester.getSemantics(find.byType(RImageTile).at(11));
      expect(
        node.getSemanticsData().customSemanticsActionIds,
        isNotEmpty,
        reason: 'no way to open full screen without seeing the corner button',
      );
      semantics.dispose();
    });

    testWidgets('a submitted gallery can still be looked at full screen', (tester) async {
      await _pump(tester, locked: true);
      await _openViewer(tester);
      expect(find.byType(RPhotoViewer), findsOneWidget);
      final choose = tester.widget<ElevatedButton>(
        find.ancestor(of: find.text('Choose'), matching: find.byType(ElevatedButton)),
      );
      expect(choose.onPressed, isNull, reason: 'a locked gallery accepted a choice full screen');
    });

    testWidgets('30 of 40 on a 20-photo package shows the server\'s EUR 14.26', (tester) async {
      // The Stage 1 loop's booking 2: the figure is the server's, the app
      // only shows it. Picked by tapping thumbnails, as a client would.
      await _pump(tester, itemCount: 40, amountDueFor: (count) => count == 30 ? '14.26' : '0.00');
      for (var n = 1; n <= 30; n++) {
        await tester.scrollUntilVisible(photo(n), 100, scrollable: find.byType(Scrollable).first);
        await tester.tap(photo(n));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('30 chosen'), findsOneWidget);
      expect(find.text('EUR 14.26 to pay'), findsOneWidget);
      expect(find.text('Pay EUR 14.26'), findsOneWidget);
    });

    testWidgets('hundreds of photos build only the tiles on screen', (tester) async {
      await _pump(tester, itemCount: 400);
      expect(find.byType(RImageTile).evaluate().length, lessThan(60));
    });
  });
}
