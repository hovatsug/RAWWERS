import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';

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

/// Uploads proofs into one gig's gallery.
///
/// Separate from the portfolio uploader because the purpose and visibility
/// differ: these are `proof` assets for one client, not public portfolio
/// work, and getting that backwards would publish a client's shoot.
@riverpod
class DeliveryUploadController extends _$DeliveryUploadController {
  @override
  Map<String, UploadProgress> build(GigResponse gig) => const {};

  Future<String?> pickAndUpload() async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty) return null;

    final service = ref.read(photoUploadServiceProvider);
    final uploaded = <String>[];

    for (final file in files) {
      final key = '${DateTime.now().microsecondsSinceEpoch}-${file.name}';
      final length = await file.length();
      state = {...state, key: UploadProgress(fileName: file.name, sent: 0, total: length)};

      final result = await service.uploadPhoto(
        openFile: () => File(file.path).openRead().map(Uint8List.fromList),
        fileSize: length,
        purpose: MediaPurpose.proof,
        // client_only, not public: these are one client's photos, and the
        // gallery decides who sees them.
        visibility: MediaVisibility.clientOnly,
        contentType: _contentTypeFor(file.name),
        fileName: file.name,
        onSendProgress: (sent, total) {
          final current = state[key];
          if (current == null) return;
          state = {...state, key: current.copyWith(sent: sent)};
        },
      );

      switch (result) {
        case Ok(:final value):
          uploaded.add(value);
          final current = state[key];
          if (current != null) state = {...state, key: current.copyWith(sent: current.total)};
        case Err(:final failure):
          final current = state[key];
          if (current != null) {
            state = {...state, key: current.copyWith(error: _explain(failure))};
          }
      }
    }

    state = {
      for (final entry in state.entries)
        if (entry.value.error != null) entry.key: entry.value,
    };

    if (uploaded.isEmpty) return 'Nothing uploaded.';
    return _attach(uploaded);
  }

  /// Uploading a proof does not put it in the gallery - that is a second
  /// call, and skipping it would leave the pro looking at photos the
  /// client will never receive.
  Future<String?> _attach(List<String> mediaAssetIds) async {
    final gallery = ref.read(deliveryGalleryControllerProvider(gig)).valueOrNull?.gallery;
    if (gallery == null) return 'The gallery is not ready yet.';

    final galleries = ref.read(proofGalleriesClientProvider);
    final result = await apiCall(
      () => galleries.addGalleryItemsV1ProofGalleriesGalleryIdItemsPost(
        galleryId: gallery.id,
        requestBody: AddGalleryItemsRequest(mediaAssetIds: mediaAssetIds),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await ref.read(deliveryGalleryControllerProvider(gig).notifier).refresh();
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Photos uploaded, but adding them to the gallery failed. Pull to refresh.',
          BusinessError(:final message) => message,
          _ => 'Photos uploaded, but adding them to the gallery failed.',
        };
    }
  }

  void dismiss(String key) => state = {...state}..remove(key);

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
