import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/api/models/proof_gallery_response.dart';
import 'package:rawwers/api/models/proof_gallery_status.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/delivery/delivery_gallery_controller.dart';
import 'package:rawwers/features/pro/delivery/delivery_gallery_screen.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';

/// Publishing is the moment a client is told their photos are ready, and
/// there is no unsend. These cover that it never happens by accident.
class _FakeGallery extends DeliveryGalleryController {
  _FakeGallery(this._detail);

  final GalleryDetailResponse _detail;
  var publishCount = 0;

  @override
  Future<GalleryDetailResponse> build(GigResponse gig) async => _detail;

  @override
  Future<String?> publish() async {
    publishCount++;
    return null;
  }
}

class _FailingGallery extends DeliveryGalleryController {
  @override
  Future<GalleryDetailResponse> build(GigResponse gig) async => throw const NetworkError();
}

class _FakeUploads extends DeliveryUploadController {
  _FakeUploads(this._state);

  final Map<String, UploadProgress> _state;

  @override
  Map<String, UploadProgress> build(GigResponse gig) => _state;
}

final _gig = GigResponse(
  id: 'gig-1',
  clientUserId: 'client-1',
  proUserId: 'pro-1',
  status: GigStatus.scheduled,
  currency: 'EUR',
  amountMinimum: '150.00',
  amountPlatformFee: '15.00',
  amountProGross: '135.00',
  locationText: 'Lisbon',
  scheduledStart: null,
  scheduledEnd: null,
  metadata: const {
    'pricing_snapshot': {'included_photos': 25, 'extra_photo_price': '8.00'},
  },
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

GalleryDetailResponse _detail({
  ProofGalleryStatus status = ProofGalleryStatus.draft,
  int items = 3,
  int includedPhotos = 25,
}) =>
    GalleryDetailResponse(
      gallery: ProofGalleryResponse(
        id: 'gal-1',
        gigId: 'gig-1',
        proUserId: 'pro-1',
        clientUserId: 'client-1',
        includedPhotos: includedPhotos,
        extraPhotoPrice: '8.00',
        currency: 'EUR',
        status: status,
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
      items: [
        for (var i = 0; i < items; i++)
          GalleryItemView(mediaAssetId: 'm$i', sortOrder: i, thumbnailUrl: null),
      ],
    );

Widget _wrap({
  DeliveryGalleryController Function()? gallery,
  Map<String, UploadProgress> uploads = const {},
}) =>
    ProviderScope(
      overrides: [
        deliveryGalleryControllerProvider(_gig).overrideWith(gallery ?? () => _FakeGallery(_detail())),
        deliveryUploadControllerProvider(_gig).overrideWith(() => _FakeUploads(uploads)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: DeliveryGalleryScreen(gig: _gig)),
    );

void main() {
  testWidgets('a draft gallery says the photos are still private', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump();

    expect(find.text('Not sent yet'), findsOneWidget);
    expect(find.textContaining('stay private until you send them'), findsOneWidget);
  });

  testWidgets('an empty draft cannot be sent', (tester) async {
    await tester.pumpWidget(_wrap(gallery: () => _FakeGallery(_detail(items: 0))));
    await tester.pump();

    final button = tester.widget<RButton>(find.widgetWithText(RButton, 'Send to client'));
    expect(button.onPressed, isNull);
  });

  testWidgets('sending warns that it cannot be undone', (tester) async {
    final gallery = _FakeGallery(_detail());
    await tester.pumpWidget(_wrap(gallery: () => gallery));
    await tester.pump();

    await tester.tap(find.widgetWithText(RButton, 'Send to client'));
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot unsend'), findsOneWidget);
    expect(gallery.publishCount, 0, reason: 'nothing sent before confirming');

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(gallery.publishCount, 0);
  });

  testWidgets('confirming sends it', (tester) async {
    final gallery = _FakeGallery(_detail());
    await tester.pumpWidget(_wrap(gallery: () => gallery));
    await tester.pump();

    await tester.tap(find.widgetWithText(RButton, 'Send to client'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send').last);
    await tester.pumpAndSettle();

    expect(gallery.publishCount, 1);
  });

  testWidgets('a sent gallery offers no send button', (tester) async {
    await tester.pumpWidget(_wrap(gallery: () => _FakeGallery(_detail(status: ProofGalleryStatus.published))));
    await tester.pump();

    expect(find.text('Sent to your client'), findsOneWidget);
    expect(find.widgetWithText(RButton, 'Send to client'), findsNothing);
    // The number the client is choosing down to is the thing they agreed to.
    expect(find.textContaining('choosing their 25'), findsOneWidget);
  });

  testWidgets('a failed upload names the file', (tester) async {
    await tester.pumpWidget(_wrap(uploads: const {
      'k1': UploadProgress(fileName: 'DSC_9001.jpg', sent: 5, total: 100, error: 'Upload failed - check your connection.'),
    }));
    await tester.pump();

    expect(find.text('DSC_9001.jpg'), findsOneWidget);
    expect(find.textContaining('check your connection'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await tester.pumpWidget(_wrap(gallery: _FailingGallery.new));
    await tester.pump();

    expect(find.text('Could not open the gallery for this shoot.'), findsOneWidget);
  });
}
