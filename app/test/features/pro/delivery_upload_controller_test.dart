// The incremental-attach fix: each photo joins the gallery on its own, as
// soon as its own watermark preview is ready, instead of one all-or-nothing
// call for the whole batch.
//
// The bug this replaces: `add_gallery_items` refuses the *whole* request if
// even one asset in it lacks a ready watermark preview. A batch call made
// once at the end of the upload loop meant one slow photo dropped every
// photo in the batch, silently as far as the gallery grid was concerned -
// the uploads themselves had genuinely succeeded. These tests drive the
// real controller against a fake backend that can hold one asset "not
// ready yet" while another is, and assert the ready one appears without
// waiting for the slow one.
//
// The backoff between retries is a seam ([GalleryAttachBackoff]) for
// exactly this reason: these tests replace it with a completer per call, so
// a retry loop can be paused mid-flight and inspected instead of either
// racing the real controller or waiting out real delays.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/api_client/proof_galleries_client.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';
import 'package:rawwers/features/pro/delivery/delivery_gallery_controller.dart';
import 'package:rawwers/features/pro/delivery/delivery_photo_picker.dart';

import '../../support/fake_http_client_adapter.dart';

class _FakePicker implements DeliveryPhotoPicker {
  _FakePicker(this.files);

  final List<DeliveryPickedFile> files;

  @override
  Future<List<DeliveryPickedFile>> pickMultiple() async => files;
}

DeliveryPickedFile _file(String name) => DeliveryPickedFile(
      name: name,
      size: 2048,
      open: () => Stream.value(Uint8List(8)),
    );

/// Lets a test control exactly when a paused retry loop resumes, instead of
/// either racing a real controller against instant fakes or waiting out
/// real delays.
class _ControllableBackoff {
  final _waiting = <Completer<void>>[];

  Future<void> call(int attempt) {
    final c = Completer<void>();
    _waiting.add(c);
    return c.future;
  }

  /// Resumes every loop currently paused on this backoff and drains the
  /// microtask queue so each resumed loop runs to its next await point -
  /// another API round trip, then either done, failed, or paused again.
  Future<void> releaseAll() async {
    final toRelease = List<Completer<void>>.from(_waiting);
    _waiting.clear();
    for (final c in toRelease) {
      if (!c.isCompleted) c.complete();
    }
    await _settle();
  }
}

/// Drains pending microtasks so an unawaited background task (the attach
/// loop `pickAndUpload` deliberately does not wait for) gets to run.
Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// A fake gallery: items are added only once the asset backing them has
/// been marked ready - exactly the rule the real `add_gallery_items`
/// enforces, and the only 422 that endpoint produces.
class _Backend {
  final List<String> calls = [];
  final Set<String> readyAssets = {};
  final List<String> attachedAssetIds = [];
  final Map<String, int> attachAttempts = {};

  /// Non-422 failure to return for a given asset's next attach attempt,
  /// simulating a real rejection (wrong owner, gallery gone) rather than
  /// "not ready yet".
  final Map<String, int> failStatusFor = {};

  /// Assets whose processing the server gave up on.
  final Set<String> failedAssets = {};

  Future<ResponseBody> api(RequestOptions o) async {
    calls.add('${o.method} ${o.path}');

    if (o.path == '/v1/media/photos/uploads') {
      final assetId = 'asset-${calls.where((c) => c.contains('/uploads')).length}';
      return jsonResponseBody(
        jsonEncode({
          'media_asset_id': assetId,
          'upload': {
            'method': 'PUT',
            'url': 'https://storage.invalid/put',
            'headers': {'Content-Type': 'application/octet-stream'},
            'storage_key': 'key-$assetId',
            'expires_in': 900,
          },
        }),
        200,
      );
    }
    if (o.method == 'GET' && o.path.startsWith('/v1/media/asset-')) {
      final assetId = o.path.split('/').last;
      return jsonResponseBody(jsonEncode(_assetJson(assetId)), 200);
    }
    if (o.path.endsWith('/complete')) {
      return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'processing'}), 200);
    }
    if (o.path == '/v1/gigs/gig-1/proof-gallery') {
      return jsonResponseBody(jsonEncode(_galleryJson()), 200);
    }
    if (o.path == '/v1/proof-galleries/gal-1' && o.method == 'GET') {
      return jsonResponseBody(jsonEncode(_detailJson()), 200);
    }
    if (o.path == '/v1/proof-galleries/gal-1/items') {
      final body = jsonDecode(jsonEncode(o.data)) as Map<String, dynamic>;
      final assetId = (body['media_asset_ids'] as List).single as String;
      attachAttempts[assetId] = (attachAttempts[assetId] ?? 0) + 1;

      final failStatus = failStatusFor[assetId];
      if (failStatus != null) {
        return jsonResponseBody(
          jsonEncode({
            'error': {'code': 'forbidden', 'message': 'That gallery is not yours.'},
          }),
          failStatus,
        );
      }
      if (!readyAssets.contains(assetId)) {
        return jsonResponseBody(
          jsonEncode({
            'error': {'code': 'validation_error', 'message': 'Watermark preview is not ready yet.'},
          }),
          422,
        );
      }
      attachedAssetIds.add(assetId);
      return jsonResponseBody(jsonEncode(_galleryJson()), 200);
    }
    throw StateError('unexpected call: ${o.method} ${o.path}');
  }

  Map<String, dynamic> _assetJson(String assetId) => {
        'id': assetId,
        'owner_user_id': 'pro-1',
        'kind': 'photo',
        'purpose': 'proof',
        'provider': 'r2',
        'status': failedAssets.contains(assetId) ? 'failed' : (readyAssets.contains(assetId) ? 'ready' : 'processing'),
        'visibility': 'client_only',
        'content_type': 'image/jpeg',
        'byte_size': 8,
        'metadata': <String, dynamic>{},
        'created_at': '2026-09-23T10:00:00Z',
        'updated_at': '2026-09-23T10:00:00Z',
        'objects': <dynamic>[],
      };

  Map<String, dynamic> _galleryJson() => {
        'id': 'gal-1',
        'gig_id': 'gig-1',
        'pro_user_id': 'pro-1',
        'client_user_id': 'client-1',
        'included_photos': 25,
        'extra_photo_price': '8.00',
        'currency': 'EUR',
        'status': 'draft',
        'published_at': null,
        'created_at': '2026-09-23T10:00:00Z',
        'updated_at': '2026-09-23T10:00:00Z',
      };

  Map<String, dynamic> _detailJson() => {
        'gallery': _galleryJson(),
        'items': [
          for (final id in attachedAssetIds)
            {'media_asset_id': id, 'sort_order': 0, 'thumbnail_url': null, 'watermark_preview_url': null},
        ],
      };
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

/// Builds a container wired to a fresh fake backend and a controllable
/// backoff, then - matching what the real screen guarantees before its
/// "Add photos" button can even be tapped - waits for the gallery to finish
/// loading. `_attachWhenReady` reads the gallery synchronously and treats
/// it not being loaded yet as a real failure, not something to wait out.
Future<({ProviderContainer container, _Backend backend, _ControllableBackoff backoff})> _setup(
  List<DeliveryPickedFile> files,
) async {
  final backend = _Backend();
  final apiDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = FakeHttpClientAdapter(backend.api);
  final storageDio = Dio()..httpClientAdapter = FakeHttpClientAdapter((o) async => ResponseBody.fromString('', 200));
  final backoff = _ControllableBackoff();

  final container = ProviderContainer(
    overrides: [
      proofGalleriesClientProvider.overrideWithValue(ProofGalleriesClient(apiDio)),
      mediaClientProvider.overrideWithValue(MediaClient(apiDio)),
      photoUploadServiceProvider.overrideWithValue(
        PhotoUploadService(mediaClient: MediaClient(apiDio), storageDio: storageDio),
      ),
      deliveryPhotoPickerProvider.overrideWithValue(_FakePicker(files)),
      galleryAttachBackoffProvider.overrideWithValue(backoff.call),
    ],
  );
  addTearDown(container.dispose);
  // Kept open for the duration of the test, matching what a real screen
  // does by watching them - both are auto-dispose and would otherwise reset
  // (losing every in-flight upload's state) between awaits.
  container.listen(deliveryGalleryControllerProvider(_gig), (_, _) {});
  container.listen(deliveryUploadControllerProvider(_gig), (_, _) {});
  await container.read(deliveryGalleryControllerProvider(_gig).future);
  return (container: container, backend: backend, backoff: backoff);
}

void main() {
  test('a photo whose watermark is already ready attaches on the first try', () async {
    final t = await _setup([_file('a.jpg')]);
    t.backend.readyAssets.add('asset-1');

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();

    expect(t.container.read(deliveryUploadControllerProvider(_gig)), isEmpty, reason: 'attached, so no longer pending');
    expect(t.backend.attachAttempts['asset-1'], 1);
    expect(t.backend.attachedAssetIds, ['asset-1']);
  });

  test('a photo whose watermark is not ready yet is retried until it is, without blocking a ready one', () async {
    final t = await _setup([_file('slow.jpg'), _file('fast.jpg')]);
    // asset-1 (slow.jpg) starts not-ready; asset-2 (fast.jpg) is ready
    // immediately. The slow one must not hold up the fast one.
    t.backend.readyAssets.add('asset-2');

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();

    // The fast photo attached without waiting on the slow one.
    expect(t.backend.attachedAssetIds, ['asset-2']);
    expect(t.backend.attachAttempts['asset-2'], 1);
    // The slow one is paused mid-retry, not failed and not attached.
    expect(t.backend.attachAttempts['asset-1'], 1);
    final state = t.container.read(deliveryUploadControllerProvider(_gig));
    expect(state.values.whereType<DeliveryUploadProcessing>(), hasLength(1));

    // Once the slow photo's watermark finishes, the next retry attaches it.
    t.backend.readyAssets.add('asset-1');
    await t.backoff.releaseAll();

    expect(t.backend.attachedAssetIds, containsAll(['asset-1', 'asset-2']));
    expect(t.backend.attachAttempts['asset-1'], 2);
    expect(t.container.read(deliveryUploadControllerProvider(_gig)), isEmpty);
  });

  test('a real rejection (not "not ready yet") fails immediately and is not retried', () async {
    final t = await _setup([_file('a.jpg')]);
    t.backend.failStatusFor['asset-1'] = 403;

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();

    expect(t.backend.attachAttempts['asset-1'], 1, reason: 'a 403 is not the retryable "not ready yet" case');
    final state = t.container.read(deliveryUploadControllerProvider(_gig));
    expect(state.values.single, isA<DeliveryUploadFailed>());
    expect((state.values.single as DeliveryUploadFailed).mediaAssetId, 'asset-1');
  });

  test('exhausting every retry leaves an actionable failure with the asset id kept for a manual retry', () async {
    final t = await _setup([_file('a.jpg')]);
    // Never marked ready: every attempt gets the retryable 422.

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();

    // One attempt already happened (paused on the backoff after it). The
    // bound is the ten-minute budget, not a count - releasing every backoff
    // in it exhausts it and lets the final "give up" state land.
    final bound = attachAttemptsWithinBudget();
    for (var i = 0; i < bound; i++) {
      await t.backoff.releaseAll();
    }

    expect(t.backend.attachAttempts['asset-1'], bound, reason: 'bounded, not retried forever');
    final state = t.container.read(deliveryUploadControllerProvider(_gig));
    final failed = state.values.single as DeliveryUploadFailed;
    expect(failed.message, contains('Still processing'));
    expect(failed.mediaAssetId, 'asset-1', reason: 'so a manual retry can skip re-uploading the file');
  });

  test('retryAttach tries again from a failed state, and succeeds once the asset is ready', () async {
    final t = await _setup([_file('a.jpg')]);

    final notifier = t.container.read(deliveryUploadControllerProvider(_gig).notifier);
    await notifier.pickAndUpload();
    await _settle();
    final bound = attachAttemptsWithinBudget();
    for (var i = 0; i < bound; i++) {
      await t.backoff.releaseAll();
    }
    final key = t.container.read(deliveryUploadControllerProvider(_gig)).keys.single;
    expect(t.backend.attachAttempts['asset-1'], bound);

    t.backend.readyAssets.add('asset-1');
    await notifier.retryAttach(key);
    await _settle();

    expect(t.backend.attachedAssetIds, ['asset-1']);
    expect(t.backend.attachAttempts['asset-1'], bound + 1);
    expect(t.container.read(deliveryUploadControllerProvider(_gig)), isEmpty);
  });

  test('a dismissed upload is not retried, even mid-backoff', () async {
    final t = await _setup([_file('a.jpg')]);

    final notifier = t.container.read(deliveryUploadControllerProvider(_gig).notifier);
    await notifier.pickAndUpload();
    await _settle();
    final key = t.container.read(deliveryUploadControllerProvider(_gig)).keys.single;
    expect(t.backend.attachAttempts['asset-1'], 1);

    notifier.dismiss(key);
    t.backend.readyAssets.add('asset-1');
    await t.backoff.releaseAll();

    expect(t.container.read(deliveryUploadControllerProvider(_gig)), isEmpty);
    expect(
      t.backend.attachAttempts['asset-1'],
      1,
      reason: 'the loop must notice the dismissal and stop, not attach a row nothing shows anymore',
    );
  });

  test('two photos upload and attach independently once each is ready', () async {
    final t = await _setup([_file('a.jpg'), _file('b.jpg')]);
    t.backend.readyAssets.addAll(['asset-1', 'asset-2']);

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();

    final uploadCalls = t.backend.calls.where((c) => c == 'POST /v1/media/photos/uploads').toList();
    expect(uploadCalls, hasLength(2), reason: 'both files were uploaded');
    expect(t.backend.attachedAssetIds, containsAll(['asset-1', 'asset-2']));
  });

  test('a photo is not given up on while it is still processing - the wait outlasts real processing times', () async {
    // Real processing took 44 s at the median and 98 s at the 90th
    // percentile; the old bound of six attempts gave up after about 44 s of
    // waiting, marking perfectly good photos failed.
    expect(attachAttemptsWithinBudget(), greaterThan(20));
    final t = await _setup([_file('a.jpg')]);
    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    await _settle();
    // Past where the old bound gave up...
    for (var i = 0; i < 10; i++) {
      await t.backoff.releaseAll();
    }
    expect(t.container.read(deliveryUploadControllerProvider(_gig)).values.single, isA<DeliveryUploadProcessing>());
    // ...and then it finishes processing, and attaches.
    t.backend.readyAssets.add('asset-1');
    await t.backoff.releaseAll();
    expect(t.backend.attachedAssetIds, ['asset-1']);
  });

  test('a photo whose processing failed stops waiting at once, and says to upload it again', () async {
    final t = await _setup([_file('a.jpg')]);
    t.backend.failedAssets.add('asset-1');

    await t.container.read(deliveryUploadControllerProvider(_gig).notifier).pickAndUpload();
    // Attach, its 422, then the status check: one more round trip than the
    // other tests wait for.
    await _settle();
    await _settle();

    final item = t.container.read(deliveryUploadControllerProvider(_gig)).values.single;
    expect(item, isA<DeliveryUploadFailed>());
    expect((item as DeliveryUploadFailed).message, contains('upload it again'));
    expect(item.mediaAssetId, isNull, reason: 'retrying the attach cannot help - the photo itself has to be sent again');
    expect(t.backend.attachAttempts['asset-1'], 1, reason: 'no waiting out the budget on a photo that will never be ready');
  });

  test('a row keeps its local preview from upload through processing to a failure', () async {
    final t = await _setup([
      DeliveryPickedFile(name: 'a.jpg', size: 2048, open: () => Stream.value(Uint8List(8)), path: '/photos/a.jpg'),
    ]);
    t.backend.failStatusFor['asset-1'] = 403;

    final notifier = t.container.read(deliveryUploadControllerProvider(_gig).notifier);
    final seen = <DeliveryUploadItem>[];
    t.container.listen(deliveryUploadControllerProvider(_gig), (_, next) => seen.addAll(next.values));
    await notifier.pickAndUpload();
    await _settle();

    expect(seen.map((item) => item.runtimeType).toSet(),
        containsAll([DeliveryUploadUploading, DeliveryUploadProcessing, DeliveryUploadFailed]));
    expect(seen.map((item) => item.localPath).toSet(), {'/photos/a.jpg'},
        reason: 'every state the row passed through showed the same photo');
  });
}
