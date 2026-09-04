import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/models/complete_photo_upload_request.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/api/models/media_visibility.dart';
import 'package:rawwers/api/models/photo_upload_create_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';

const uploadReceiveTimeout = Duration(minutes: 5);

/// Uploads a photo via the backend's presigned-PUT flow (this API has no
/// multipart upload endpoints - confirmed against the real OpenAPI schema -
/// media goes straight to R2):
///
///   1. POST /v1/media/photos/uploads -> a fresh presigned PUT URL
///   2. PUT the file bytes straight to that URL
///   3. POST /v1/media/photos/{id}/complete
///
/// Steps 1-2 are auto-retried as a pair, bounded by [maxAttempts]: a
/// presigned URL expires, so a retry after a failed PUT must never reuse
/// the same URL - it goes back to step 1 for a fresh one and a fresh
/// media_asset_id, discarding whatever step 1 produced on the failed
/// attempt.
///
/// Step 3 is called at most once and is never auto-retried, even though it
/// isn't in the payment/booking/gig list that must never be repeated: the
/// backend only accepts `complete` while the asset is still `uploading` or
/// `created` (checked against the real handler, not assumed) - calling it
/// again after a success that the client failed to observe (e.g. a
/// response timeout) gets a 409, not a harmless no-op. A failed step 3 is
/// returned to the caller as-is; if it's worth retrying, that's a decision
/// for the UI, not something this transport does automatically.
class PhotoUploadService {
  PhotoUploadService({required MediaClient mediaClient, required Dio storageDio})
      : _mediaClient = mediaClient,
        _storageDio = storageDio;

  final MediaClient _mediaClient;

  /// A separate, bare Dio (no baseUrl, no auth/refresh interceptors) for
  /// the direct-to-storage PUT - presigned URLs are self-authenticating via
  /// their query string and must never carry our Authorization header.
  final Dio _storageDio;

  Future<Result<String>> uploadPhoto({
    required Stream<Uint8List> Function() openFile,
    required int fileSize,
    required MediaPurpose purpose,
    required String contentType,
    String? fileName,
    MediaVisibility? visibility,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    int maxAttempts = 3,
  }) async {
    final uploaded = await _createAndPutWithRetry(
      openFile: openFile,
      fileSize: fileSize,
      purpose: purpose,
      contentType: contentType,
      fileName: fileName,
      visibility: visibility,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      maxAttempts: maxAttempts,
    );
    if (uploaded is Err<String>) return uploaded;
    final mediaAssetId = (uploaded as Ok<String>).value;

    final completeResult = await apiCall(
      () => _mediaClient.completePhotoUploadV1MediaPhotosMediaAssetIdCompletePost(
        requestBody: CompletePhotoUploadRequest(byteSize: fileSize),
        mediaAssetId: mediaAssetId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (completeResult) {
      Ok() => Ok(mediaAssetId),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<String>> _createAndPutWithRetry({
    required Stream<Uint8List> Function() openFile,
    required int fileSize,
    required MediaPurpose purpose,
    required String contentType,
    String? fileName,
    MediaVisibility? visibility,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    required int maxAttempts,
  }) async {
    ApiFailure? lastFailure;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final createResult = await apiCall(
        () => _mediaClient.createPhotoUploadV1MediaPhotosUploadsPost(
          // Visibility is passed explicitly by callers that care. Null
          // lets the backend apply its own default, which for a portfolio
          // photo is public - but a caller should not have to know that.
          requestBody: PhotoUploadCreateRequest(
            purpose: purpose,
            contentType: contentType,
            fileName: fileName,
            visibility: visibility,
          ),
          authorization: null,
          xMinusUserMinusId: null,
        ),
      );
      if (createResult case Err(:final failure)) {
        lastFailure = failure;
        continue;
      }
      final created = (createResult as Ok).value;
      final payload = created.upload;

      if (cancelToken?.isCancelled ?? false) {
        return const Err(NetworkError());
      }

      try {
        await _storageDio.put<void>(
          payload.url,
          data: openFile(),
          options: Options(
            headers: {
              ...?payload.headers,
              Headers.contentLengthHeader: fileSize,
            },
            receiveTimeout: uploadReceiveTimeout,
            sendTimeout: uploadReceiveTimeout,
          ),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
        );
        return Ok(created.mediaAssetId);
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          return const Err(NetworkError());
        }
        // This presigned URL is now potentially expired or partially
        // consumed - never retried. Loop back to step 1 for a fresh one;
        // the abandoned mediaAssetId/upload is simply dropped (complete is
        // never called for it, so it stays "uploading" and never surfaces
        // to the client).
        lastFailure = const NetworkError();
      }
    }

    return Err(lastFailure ?? const NetworkError());
  }
}
