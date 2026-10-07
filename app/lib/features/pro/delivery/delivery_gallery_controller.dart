import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/add_gallery_items_request.dart';
import 'package:rawwers/api/models/create_proof_gallery_request.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/api/models/media_visibility.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/upload/upload_pool.dart';
import 'package:rawwers/features/pro/delivery/delivery_photo_picker.dart';

part 'delivery_gallery_controller.g.dart';

/// The gallery of proofs for one gig.
///
/// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
/// screen is safe to repeat - but the first call is the one that fixes
/// included_photos and extra_photo_price, and later calls silently ignore
/// the body. Those two numbers therefore come from the gig's pricing
/// snapshot, which is what the client already agreed to pay, rather than
/// from anything typed here.
@riverpod
class DeliveryGalleryController extends _$DeliveryGalleryController {
  @override
  Future<GalleryDetailResponse> build(GigResponse gig) async {
    final galleries = ref.read(proofGalleriesClientProvider);

    final created = await apiCall(
      () => galleries.createProofGalleryV1GigsGigIdProofGalleryPost(
        gigId: gig.id,
        requestBody: CreateProofGalleryRequest(
          includedPhotos: _includedPhotos(gig),
          extraPhotoPrice: _extraPhotoPrice(gig),
        ),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    final gallery = switch (created) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    final detail = await apiCall(
      () => galleries.getGalleryV1ProofGalleriesGalleryIdGet(
        galleryId: gallery.id,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (detail) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Publishing is what tells the client their photos are ready, so it is
  /// deliberately not something that happens as a side effect of uploading.
  Future<String?> publish() async {
    final gallery = state.valueOrNull?.gallery;
    if (gallery == null) return 'The gallery is still loading.';

    final galleries = ref.read(proofGalleriesClientProvider);
    final result = await apiCall(
      () => galleries.publishGalleryV1ProofGalleriesGalleryIdPublishPost(
        galleryId: gallery.id,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not publish the gallery.',
        };
    }
  }

  /// The gig's pricing snapshot is a free-form JSON blob, so both of these
  /// read defensively: a missing or malformed value falls back to
  /// something safe rather than throwing on the way into the screen.
  int _includedPhotos(GigResponse gig) {
    final snapshot = gig.metadata?['pricing_snapshot'];
    final value = snapshot is Map ? snapshot['included_photos'] : null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 10;
  }

  String _extraPhotoPrice(GigResponse gig) {
    final snapshot = gig.metadata?['pricing_snapshot'];
    final value = snapshot is Map ? snapshot['extra_photo_price'] : null;
    // Kept as a string end to end - this is money, and a double would
    // round it somewhere between here and Stripe.
    if (value is String && value.isNotEmpty) return value;
    if (value is num) return value.toStringAsFixed(2);
    return '0.00';
  }
}

/// One photo, somewhere between "picked" and "visible in the gallery below".
///
/// Uploading and appearing in the gallery are not the same moment: the
/// server will not add a photo to a gallery until it has generated the
/// watermark preview the client is shown. Measured on real R2 (2026-10-05),
/// the image work itself is about a second a photo; the wait is moving the
/// original to the worker and the preview back, so it follows the network -
/// 30 seconds to two minutes on a slow link. A photo sits as [DeliveryUploadProcessing] for exactly that
/// long, on its own clock, independent of every other photo in the batch.
sealed class DeliveryUploadItem {
  const DeliveryUploadItem({required this.fileName, this.localPath});

  final String fileName;

  /// The picked file on this phone, shown as the row's preview from the
  /// first moment - the photographer sees their photo while it uploads and
  /// processes, not a filename. Carried through every state rather than being
  /// a state of its own: it is what the row looks like, not where the upload
  /// has got to.
  final String? localPath;

  /// The same item, showing [path] as its preview.
  DeliveryUploadItem withLocalPath(String? path);
}

final class DeliveryUploadUploading extends DeliveryUploadItem {
  const DeliveryUploadUploading({required super.fileName, required this.sent, required this.total, super.localPath});

  final int sent;
  final int total;

  double get fraction => total <= 0 ? 0 : (sent / total).clamp(0, 1).toDouble();

  @override
  DeliveryUploadUploading withLocalPath(String? path) =>
      DeliveryUploadUploading(fileName: fileName, sent: sent, total: total, localPath: path);
}

/// The file is in storage and has a `MediaAsset`, but the server has not yet
/// confirmed the watermark preview it requires before this can join the
/// gallery. Retried automatically in the background; this is progress, not
/// a problem, and must never be shown the way an error is.
final class DeliveryUploadProcessing extends DeliveryUploadItem {
  const DeliveryUploadProcessing({required super.fileName, required this.mediaAssetId, super.localPath});

  final String mediaAssetId;

  @override
  DeliveryUploadProcessing withLocalPath(String? path) =>
      DeliveryUploadProcessing(fileName: fileName, mediaAssetId: mediaAssetId, localPath: path);
}

final class DeliveryUploadFailed extends DeliveryUploadItem {
  const DeliveryUploadFailed({required super.fileName, required this.message, this.mediaAssetId, super.localPath});

  final String message;

  /// Set when the raw upload itself succeeded and only attaching it to the
  /// gallery gave up - retrying then needs no re-upload, just another attempt
  /// at the one call that failed.
  final String? mediaAssetId;

  @override
  DeliveryUploadFailed withLocalPath(String? path) =>
      DeliveryUploadFailed(fileName: fileName, message: message, mediaAssetId: mediaAssetId, localPath: path);
}

/// How long to wait before checking again whether a just-uploaded photo's
/// watermark preview is ready.
///
/// A seam, the same shape as [PaymentSheetLauncher] and `GearFilePicker`:
/// the real delay is real wall-clock time, which a test cannot spend without
/// either becoming slow or reaching for `fake_async` machinery this codebase
/// does not otherwise use. Tests override this to return immediately and
/// assert on the retry *count* and *condition*, not on the clock.
typedef GalleryAttachBackoff = Future<void> Function(int attempt);

@Riverpod(keepAlive: true)
GalleryAttachBackoff galleryAttachBackoff(Ref ref) => (attempt) => Future.delayed(_backoffDelay(attempt));

/// 3s, 5s, 8s, 13s, then every 15s.
Duration _backoffDelay(int attempt) {
  const delaysSeconds = [3, 5, 8, 13, 15];
  final seconds = attempt < delaysSeconds.length ? delaysSeconds[attempt] : delaysSeconds.last;
  return Duration(seconds: seconds);
}

/// How long a photo may stay "still processing" before the attach gives up.
///
/// This used to be a fixed six attempts - about 44 seconds of waiting - while
/// real processing took 44 seconds at the median and 98 at the 90th
/// percentile, so photos that were processing perfectly well were marked
/// failed. The wait is now bounded by time, generously, and ends early the
/// moment the server says processing actually failed.
const attachWaitBudget = Duration(minutes: 10);

/// How many attach attempts fit in [attachWaitBudget]: the first, plus one
/// after each backoff delay until the delays add up to the budget.
int attachAttemptsWithinBudget() {
  var attempts = 1;
  var waited = Duration.zero;
  while (waited < attachWaitBudget) {
    waited += _backoffDelay(attempts - 1);
    attempts++;
  }
  return attempts;
}

/// Uploads proofs into one gig's gallery.
///
/// Separate from the portfolio uploader because the purpose and visibility
/// differ: these are `proof` assets for one client, not public portfolio
/// work, and getting that backwards would publish a client's shoot.
///
/// Each photo is attached to the gallery on its own, as soon as its own
/// watermark preview is ready - not as one call at the end of the batch for
/// every photo together. A single all-or-nothing call was the original
/// design, and it failed every time a real photo was still processing:
/// `add_gallery_items` refuses the *whole* request if even one of the ids in
/// it lacks a ready watermark preview, so a batch of twelve photos where the
/// twelfth was still generating dropped all twelve, silently as far as the
/// gallery grid was concerned - the individual uploads had genuinely
/// succeeded, so nothing about the per-file progress looked wrong.
@riverpod
class DeliveryUploadController extends _$DeliveryUploadController {

  /// Set by [build]'s own `ref.onDispose`, which every provider lifecycle
  /// guarantees - unlike `ref.mounted`, which the `Ref` type this generates
  /// does not expose in the riverpod version pinned here. A background retry
  /// loop
  /// outlives any single `pickAndUpload` call and is never awaited by it, so
  /// the screen (and this auto-dispose provider) can be gone before a retry
  /// completes; writing to `state` after that throws.
  bool _disposed = false;

  @override
  Map<String, DeliveryUploadItem> build(GigResponse gig) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const {};
  }

  Future<void> pickAndUpload() async {
    final files = await ref.read(deliveryPhotoPickerProvider).pickMultiple();
    if (files.isEmpty) return;

    final service = ref.read(photoUploadServiceProvider);

    await forEachConcurrently(files, (file) async {
      final key = '${DateTime.now().microsecondsSinceEpoch}-${file.name}';
      state = {...state, key: DeliveryUploadUploading(fileName: file.name, sent: 0, total: file.size, localPath: file.path)};

      final result = await service.uploadPhoto(
        openFile: file.open,
        openRange: file.openRange,
        fileSize: file.size,
        purpose: MediaPurpose.proof,
        // client_only, not public: these are one client's photos, and the
        // gallery decides who sees them.
        visibility: MediaVisibility.clientOnly,
        contentType: _contentTypeFor(file.name),
        fileName: file.name,
        onSendProgress: (sent, total) {
          final current = state[key];
          if (current is! DeliveryUploadUploading) return;
          state = {...state, key: DeliveryUploadUploading(fileName: file.name, sent: sent, total: current.total, localPath: file.path)};
        },
      );

      switch (result) {
        case Ok(:final value):
          state = {...state, key: DeliveryUploadProcessing(fileName: file.name, mediaAssetId: value, localPath: file.path)};
          // Deliberately not awaited. This file's attach-and-retry runs on
          // its own clock from here; waiting for it would hold this upload
          // slot while the photo processes, instead of starting the next
          // file.
          unawaited(_attachWhenReady(key: key, fileName: file.name, mediaAssetId: value));
        case Err(:final failure):
          state = {...state, key: DeliveryUploadFailed(fileName: file.name, message: _explain(failure), localPath: file.path)};
      }
    });
  }

  /// Attaches one photo to the gallery, retrying only the failure the server
  /// can recover from on its own.
  ///
  /// `add_gallery_items` (api/app/api/v1/proof_galleries.py) has exactly one
  /// validation check: the watermark preview must be `ready`. That is the
  /// only 422 this call can produce, so a 422 here is retried - it means
  /// "not yet", not "wrong". Everything else (403 wrong owner, 404 gone,
  /// network) is a real failure: retrying those would repeat them forever
  /// while the UI claimed to be making progress.
  Future<void> _attachWhenReady({required String key, required String fileName, required String mediaAssetId}) async {
    final galleries = ref.read(proofGalleriesClientProvider);
    final backoff = ref.read(galleryAttachBackoffProvider);

    final maxAttempts = attachAttemptsWithinBudget();
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      // Dismissed while waiting: nothing left to update, and nothing left to
      // retry for.
      if (!state.containsKey(key)) return;

      final gallery = ref.read(deliveryGalleryControllerProvider(gig)).valueOrNull?.gallery;
      if (gallery == null) {
        _set(key, DeliveryUploadFailed(fileName: fileName, message: 'The gallery is not ready yet.', mediaAssetId: mediaAssetId));
        return;
      }

      final result = await apiCall(
        () => galleries.addGalleryItemsV1ProofGalleriesGalleryIdItemsPost(
          galleryId: gallery.id,
          requestBody: AddGalleryItemsRequest(mediaAssetIds: [mediaAssetId]),
          authorization: null,
          xMinusUserMinusId: null,
        ),
      );

      switch (result) {
        case Ok():
          if (_disposed) return;
          state = {...state}..remove(key);
          await ref.read(deliveryGalleryControllerProvider(gig).notifier).refresh();
          return;
        case Err(:final failure):
          if (failure is BusinessError && failure.code == 'invalid_state') {
            // The server refused the photo itself (its processing failed):
            // retrying the attach would only be refused again, so no
            // mediaAssetId - and no Retry button - only "upload it again".
            _set(key, DeliveryUploadFailed(fileName: fileName, message: failure.message));
            return;
          }
          if (failure is! BusinessError || failure.status != 422) {
            _set(key, DeliveryUploadFailed(fileName: fileName, message: _explain(failure), mediaAssetId: mediaAssetId));
            return;
          }
          // "Not ready yet" - unless processing has actually failed, in which
          // case waiting longer cannot help and the photo has to be sent again.
          if (await _processingFailed(mediaAssetId)) {
            _set(
              key,
              DeliveryUploadFailed(
                fileName: fileName,
                message: 'This photo could not be processed. Remove it and upload it again.',
              ),
            );
            return;
          }
      }

      if (!state.containsKey(key)) return;
      _set(key, DeliveryUploadProcessing(fileName: fileName, mediaAssetId: mediaAssetId));
      await backoff(attempt);
    }

    _set(
      key,
      DeliveryUploadFailed(
        fileName: fileName,
        message: 'Still processing after ten minutes. Try again in a moment.',
        mediaAssetId: mediaAssetId,
      ),
    );
  }

  /// Whether the server gave up on processing this photo. A failed check is
  /// treated as "no": the attach keeps trying rather than failing a photo on
  /// the strength of a lost status request.
  Future<bool> _processingFailed(String mediaAssetId) async {
    final result = await apiCall(
      () => ref.read(mediaClientProvider).getMediaAssetV1MediaMediaAssetIdGet(
            mediaAssetId: mediaAssetId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => value.status == 'failed',
      Err() => false,
    };
  }

  /// Retries attaching a photo whose upload already succeeded, without
  /// asking for the file again - the point of keeping [mediaAssetId] on a
  /// failed attach rather than dropping it with the error.
  Future<void> retryAttach(String key) async {
    final item = state[key];
    if (item is! DeliveryUploadFailed || item.mediaAssetId == null) return;
    _set(key, DeliveryUploadProcessing(fileName: item.fileName, mediaAssetId: item.mediaAssetId!));
    await _attachWhenReady(key: key, fileName: item.fileName, mediaAssetId: item.mediaAssetId!);
  }

  void dismiss(String key) => state = {...state}..remove(key);

  /// `_disposed` matters here specifically: this runs at the end of a
  /// background retry loop that outlives any single `pickAndUpload` call and
  /// is never awaited by its caller, so the screen (and this provider, which
  /// is auto-dispose) can be gone before a retry completes. Writing to
  /// `state` after that throws; every write in this class that follows an
  /// `await` goes through here rather than assigning `state` directly.
  void _set(String key, DeliveryUploadItem value) {
    if (_disposed) return;
    // A row keeps the preview it started with, whatever state it moves to.
    final preview = value.localPath ?? state[key]?.localPath;
    state = {...state, key: value.localPath == preview ? value : value.withLocalPath(preview)};
  }

  String _explain(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Upload failed - check your connection.',
        BusinessError(:final message) => message,
        _ => 'Upload failed.',
      };

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }
}
