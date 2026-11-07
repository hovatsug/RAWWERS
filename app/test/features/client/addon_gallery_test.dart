import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/addon_quote_response.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/api/models/proof_gallery_response.dart';
import 'package:rawwers/api/models/proof_gallery_status.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/gallery/addon_controller.dart';
import 'package:rawwers/features/client/gallery/addon_gallery.dart';

GalleryDetailResponse _gallery({required bool open, DateTime? ends}) => GalleryDetailResponse(
      gallery: ProofGalleryResponse(
        id: 'g1',
        gigId: 'gig-1',
        proUserId: 'pro-1',
        clientUserId: 'client-1',
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
        status: ProofGalleryStatus.selectionSubmitted,
        includedPhotos: 2,
        extraPhotoPrice: '10.00',
        currency: 'EUR',
      ),
      items: [
        for (var i = 0; i < 4; i++)
          GalleryItemView(mediaAssetId: 'a$i', sortOrder: i, thumbnailUrl: 'https://example.test/$i.jpg'),
      ],
      addonWindowEndsAt: ends ?? DateTime.now().add(const Duration(days: 6, hours: 4, minutes: 30)),
      addonOpen: open,
      chosenMediaAssetIds: const ['a0', 'a1'],
    );

class _Fake extends AddonController {
  _Fake(this.initial);

  final AddonState initial;
  final toggled = <String>[];

  @override
  Future<AddonState> build(String galleryId) async => initial;

  @override
  Future<void> toggle(String assetId) async {
    toggled.add(assetId);
    final current = state.requireValue;
    if (current.isChosen(assetId)) return;
    state = AsyncData(current.copyWith(
      picked: {...current.picked, assetId},
      quote: const AddonQuoteResponse(alreadyChosen: 2, adding: 1, amount: '7.50', currency: 'EUR'),
      quoting: false,
    ));
  }
}

Future<_Fake> _pump(WidgetTester tester, AddonState state) async {
  final fake = _Fake(state);
  await tester.pumpWidget(ProviderScope(
    overrides: [addonControllerProvider('g1').overrideWith(() => fake)],
    child: MaterialApp(theme: buildClientTheme(), home: const Scaffold(body: AddonGallery(galleryId: 'g1', bookingId: 'b1'))),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('chosen photos are greyed with a Chosen badge and cannot be picked', (tester) async {
    final fake = await _pump(tester, AddonState(gallery: _gallery(open: true), picked: const {}));

    expect(find.text('Chosen'), findsNWidgets(2));
    final tiles = tester.widgetList<RImageTile>(find.byType(RImageTile)).toList();
    expect([for (final t in tiles) t.onTap == null], [true, true, false, false]);
    expect(tiles[0].onExpand, isNotNull, reason: 'chosen photos still open full size');

    await tester.tap(find.byType(RImageTile).at(0));
    expect(fake.toggled, isEmpty);
  });

  testWidgets('the countdown and what can be added, then the price before confirming', (tester) async {
    await _pump(tester, AddonState(gallery: _gallery(open: true), picked: const {}));

    expect(find.text('Add more photos · 6 days 4 h left'), findsOneWidget);
    expect(find.text('2 more photos you can add'), findsOneWidget);

    await tester.tap(find.byType(RImageTile).at(2));
    await tester.pumpAndSettle();

    expect(find.text('1 to add · EUR 7.50'), findsOneWidget);
    await tester.tap(find.text('Add 1 for EUR 7.50'));
    await tester.pumpAndSettle();
    expect(find.text('You will be charged EUR 7.50. They are yours to download once paid.'), findsOneWidget);
  });

  testWidgets('after the window the gallery is read-only', (tester) async {
    await _pump(
      tester,
      AddonState(gallery: _gallery(open: false, ends: DateTime.now().subtract(const Duration(days: 1))), picked: const {}),
    );

    expect(find.text('Gallery closed'), findsOneWidget);
    expect(find.textContaining('you can add'), findsNothing);
    final tiles = tester.widgetList<RImageTile>(find.byType(RImageTile));
    expect(tiles.every((t) => t.onTap == null), isTrue);
  });
}
