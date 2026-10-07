import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/models/complete_photo_upload_request.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/api/models/media_visibility.dart';
import 'package:rawwers/api/models/multipart_part_urls_request.dart';
import 'package:rawwers/api/models/multipart_start_request.dart';
import 'package:rawwers/api/models/photo_upload_create_request.dart';
import 'package:rawwers/api/models/upload_payload.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';

const uploadReceiveTimeout = Duration(minutes: 5);

/// How long an upload may go without sending a single byte before it is
/// treated as dead and retried.
///
/// This replaces a 5-minute limit on the *whole* upload. That limit (Dio's
/// sendTimeout wraps the entire request body) meant a file had to finish in
/// five minutes regardless of whether it was moving: a 58 MB gear RAW needs
/// 1.55 Mbit/s of sustained upload to make it, so on a slower connection it
/// failed at minute five, restarted from zero, and never arrived. A steady
/// upload is now allowed as long as it takes; only one that has stopped is
/// abandoned.
///
/// Three minutes, not one. Send progress only moves when the OS frees room in
/// the socket's send buffer, and that buffer is megabytes on a phone: on a
/// real ~33 KB/s uplink to R2, progress events stopped for a full 60 seconds
/// while bytes were still reaching R2 the whole time, and a one-minute timer
/// cancelled a healthy upload. A dead connection is still given up on within
/// three minutes.
const uploadStallTimeout = Duration(minutes: 3);

/// Files at least this big go in parts, each resumable on its own.
///
/// Every camera RAW is over it (16-58 MB) and so is a full-size camera JPEG
/// from a high-resolution body; a phone photo or a portfolio pick usually is
/// not, and for those one request is simpler and no slower.
const multipartThreshold = 16 * 1024 * 1024;

/// How long to wait before another round of a parts upload, after a round
/// that got nowhere: 2s, 5s, 10s, 20s, then 30s.
///
/// Without it, a round that failed on its API call (no signal for a moment)
/// was retried at once - three failures in a few milliseconds, then an abort
/// that threw away every part already sent. Found against the real API.
Duration partsRetryDelay(int round) {
  const seconds = [2, 5, 10, 20, 30];
  return Duration(seconds: seconds[round < seconds.length ? round : seconds.length - 1]);
}

/// Bytes `start` (inclusive) to `end` (exclusive) of the file being uploaded.
typedef OpenRange = Stream<Uint8List> Function(int start, int end);

/// Uploads a photo straight to R2 through the backend's presigned URLs; the
/// bytes never pass through the API.
///
///   1. POST /v1/media/photos/uploads creates the asset, once.
///   2. The bytes go up:
///      - under [multipartThreshold], one PUT. A retry asks for a fresh URL
///        *for the same asset* (POST .../upload-url): a used presigned URL is
///        never reused, and a failed attempt no longer leaves an orphan
///        asset behind, which creating a new one each time did.
///      - at or over it, in parts. Before sending, the service asks R2 which
///        parts it already holds and sends only the rest, so a dropped
///        connection resumes from the last finished part instead of byte
///        zero. R2 assembles them on POST .../multipart/complete, from its
///        own list of parts - checked server-side against the declared size.
///   3. POST /v1/media/photos/{id}/complete, once - never auto-retried: the
///      backend accepts it only while the asset is still uploading, so a
///      repeat after an unobserved success gets a 409, not a no-op.
///
/// Every PUT runs under the stall watchdog ([uploadStallTimeout]) rather
/// than a limit on its total duration.
class PhotoUploadService {
  PhotoUploadService({
    required MediaClient mediaClient,
    required Dio storageDio,
    this.stallTimeout = uploadStallTimeout,
    this.partThreshold = multipartThreshold,
    this.retryDelay = partsRetryDelay,
  })  : _mediaClient = mediaClient,
        _storageDio = storageDio;

  final MediaClient _mediaClient;

  /// A separate, bare Dio (no baseUrl, no auth/refresh interceptors) for
  /// the direct-to-storage PUT - presigned URLs are self-authenticating via
  /// their query string and must never carry our Authorization header.
  final Dio _storageDio;

  /// See [uploadStallTimeout]. Injectable so tests can use a short one.
  final Duration stallTimeout;

  /// See [multipartThreshold]. Injectable so tests can exercise parts on
  /// small bodies.
  final int partThreshold;

  /// See [partsRetryDelay]. Injectable so tests need not wait it out.
  final Duration Function(int round) retryDelay;

  /// [openRange] lets a large file be read a part at a time. Without it the
  /// service reads past the start of [openFile] to reach each part - correct,
  /// and local disk reads only, but slower; every picker in the app has a
  /// file path and supplies it.
  Future<Result<String>> uploadPhoto({
    required Stream<Uint8List> Function() openFile,
    required int fileSize,
    required MediaPurpose purpose,
    required String contentType,
    OpenRange? openRange,
    String? fileName,
    MediaVisibility? visibility,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    int maxAttempts = 3,
  }) async {
    final created = await _create(
      purpose: purpose,
      contentType: contentType,
      fileName: fileName,
      visibility: visibility,
      maxAttempts: maxAttempts,
    );
    if (created case Err(:final failure)) return Err(failure);
    final (mediaAssetId, firstUpload) = (created as Ok<(String, UploadPayload)>).value;

    if (cancelToken?.isCancelled ?? false) return const Err(NetworkError());

    final sent = fileSize >= partThreshold
        ? await _sendInParts(
            mediaAssetId: mediaAssetId,
            fileSize: fileSize,
            openRange: openRange ?? ((start, end) => _slice(openFile(), start, end)),
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            maxAttempts: maxAttempts,
          )
        : await _sendWhole(
            mediaAssetId: mediaAssetId,
            firstUpload: firstUpload,
            openFile: openFile,
            fileSize: fileSize,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            maxAttempts: maxAttempts,
          );
    if (sent case Err(:final failure)) return Err(failure);

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

  /// Creates the asset. Only this request is retried here - once an asset
  /// exists, every later attempt works on it.
  Future<Result<(String, UploadPayload)>> _create({
    required MediaPurpose purpose,
    required String contentType,
    String? fileName,
    MediaVisibility? visibility,
    required int maxAttempts,
  }) async {
    ApiFailure? lastFailure;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await apiCall(
        () => _mediaClient.createPhotoUploadV1MediaPhotosUploadsPost(
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
      switch (result) {
        case Ok(:final value):
          return Ok((value.mediaAssetId, value.upload));
        case Err(:final failure):
          lastFailure = failure;
      }
    }
    return Err(lastFailure ?? const NetworkError());
  }

  Future<Result<void>> _sendWhole({
    required String mediaAssetId,
    required UploadPayload firstUpload,
    required Stream<Uint8List> Function() openFile,
    required int fileSize,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    required int maxAttempts,
  }) async {
    var upload = firstUpload;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        // A fresh URL for the same object - never the one that just failed.
        final refreshed = await apiCall(
          () => _mediaClient.refreshPhotoUploadUrlV1MediaPhotosMediaAssetIdUploadUrlPost(
            mediaAssetId: mediaAssetId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
        );
        if (refreshed case Ok(:final value)) {
          upload = value;
        } else {
          continue;
        }
      }
      final outcome = await _put(
        url: upload.url,
        headers: {...?upload.headers},
        body: openFile(),
        length: fileSize,
        cancelToken: cancelToken,
        onProgress: (sent) => onSendProgress?.call(sent, fileSize),
      );
      switch (outcome) {
        case _PutOutcome.sent:
          return const Ok(null);
        case _PutOutcome.cancelled:
          return const Err(NetworkError());
        case _PutOutcome.failed:
          continue;
      }
    }
    return const Err(NetworkError());
  }

  /// Sends the file in parts, resuming from whatever R2 already holds.
  ///
  /// Gives up after [maxAttempts] rounds in a row in which no new part
  /// arrived - a round that gets even one part further resets the count, so
  /// a long upload over a flaky connection keeps going as long as it is
  /// making progress. Giving up aborts the upload, so R2 does not keep
  /// orphaned parts.
  Future<Result<void>> _sendInParts({
    required String mediaAssetId,
    required int fileSize,
    required OpenRange openRange,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    required int maxAttempts,
  }) async {
    final started = await apiCall(
      () => _mediaClient.startMultipartUploadV1MediaPhotosMediaAssetIdMultipartPost(
        requestBody: MultipartStartRequest(byteSize: fileSize),
        mediaAssetId: mediaAssetId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (started case Err(:final failure)) return Err(failure);
    final layout = (started as Ok).value;
    final partSize = layout.partSize as int;
    final partCount = layout.partCount as int;

    var roundsWithoutProgress = 0;
    while (true) {
      // What R2 already has. On the first round that is nothing; after a
      // drop it is every part that finished.
      final held = await apiCall(
        () => _mediaClient.multipartPartsV1MediaPhotosMediaAssetIdMultipartPartsGet(
          mediaAssetId: mediaAssetId,
          authorization: null,
          xMinusUserMinusId: null,
        ),
      );
      if (held case Err()) {
        if (++roundsWithoutProgress >= maxAttempts) return _abandon(mediaAssetId);
        await Future<void>.delayed(retryDelay(roundsWithoutProgress - 1));
        continue;
      }
      final done = {for (final part in (held as Ok).value.parts) part.partNumber as int};
      final missing = [for (var n = 1; n <= partCount; n++) if (!done.contains(n)) n];
      if (missing.isEmpty) break;

      var heldBytes = done.fold<int>(0, (sum, n) => sum + _partLength(n, partSize, partCount, fileSize));
      onSendProgress?.call(heldBytes, fileSize);

      final urls = await apiCall(
        () => _mediaClient.multipartPartUrlsV1MediaPhotosMediaAssetIdMultipartPartUrlsPost(
          requestBody: MultipartPartUrlsRequest(partNumbers: missing.take(100).toList()),
          mediaAssetId: mediaAssetId,
          authorization: null,
          xMinusUserMinusId: null,
        ),
      );
      if (urls case Err()) {
        if (++roundsWithoutProgress >= maxAttempts) return _abandon(mediaAssetId);
        await Future<void>.delayed(retryDelay(roundsWithoutProgress - 1));
        continue;
      }

      var progressed = false;
      for (final part in (urls as Ok).value.parts) {
        final n = part.partNumber as int;
        final start = (n - 1) * partSize;
        final length = _partLength(n, partSize, partCount, fileSize);
        final base = heldBytes;
        final outcome = await _put(
          url: part.url as String,
          headers: const {},
          body: openRange(start, start + length),
          length: length,
          cancelToken: cancelToken,
          onProgress: (sent) => onSendProgress?.call(base + sent, fileSize),
        );
        if (outcome == _PutOutcome.cancelled) return const Err(NetworkError());
        if (outcome == _PutOutcome.failed) break; // back to asking R2 what it has
        heldBytes += length;
        progressed = true;
      }
      roundsWithoutProgress = progressed ? 0 : roundsWithoutProgress + 1;
      if (roundsWithoutProgress >= maxAttempts) return _abandon(mediaAssetId);
      // A part failed; give the connection a moment before the next round.
      await Future<void>.delayed(retryDelay(roundsWithoutProgress));
    }

    final assembled = await apiCall(
      () => _mediaClient.completeMultipartV1MediaPhotosMediaAssetIdMultipartCompletePost(
        mediaAssetId: mediaAssetId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (assembled) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<void>> _abandon(String mediaAssetId) async {
    await apiCall(
      () => _mediaClient.abortMultipartV1MediaPhotosMediaAssetIdMultipartAbortPost(
        mediaAssetId: mediaAssetId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return const Err(NetworkError());
  }

  /// One PUT under the stall watchdog.
  Future<_PutOutcome> _put({
    required String url,
    required Map<String, String> headers,
    required Stream<Uint8List> body,
    required int length,
    CancelToken? cancelToken,
    void Function(int sent)? onProgress,
  }) async {
    // The attempt's own token: the watchdog cancels it without touching the
    // caller's, and a caller's cancel is forwarded to it.
    final attemptToken = CancelToken();
    cancelToken?.whenCancel.then((_) => attemptToken.cancel('cancelled by caller'));
    Timer? watchdog;
    var stalled = false;
    void armWatchdog() {
      watchdog?.cancel();
      watchdog = Timer(stallTimeout, () {
        stalled = true;
        attemptToken.cancel('upload stalled');
      });
    }

    try {
      armWatchdog();
      await _storageDio.put<void>(
        url,
        data: body,
        options: Options(
          headers: {...headers, Headers.contentLengthHeader: length},
          // Bounds the wait for R2's answer after the last byte, including
          // the time to the response headers (checked in Dio's IO adapter).
          receiveTimeout: uploadReceiveTimeout,
          // No sendTimeout: it limits the whole body, not a stall. The
          // watchdog above is the stall limit.
        ),
        cancelToken: attemptToken,
        onSendProgress: (sent, _) {
          // The watchdog is for sending. Once the last byte is handed over,
          // the wait is for the network to drain the send buffer (megabytes
          // on a phone) and for R2 to answer - no further progress events
          // come during it, so a stall timer would fire on an upload that is
          // fine. That wait is bounded by receiveTimeout instead.
          if (sent >= length) {
            watchdog?.cancel();
          } else {
            armWatchdog();
          }
          onProgress?.call(sent);
        },
      );
      return _PutOutcome.sent;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel && !stalled) return _PutOutcome.cancelled;
      return _PutOutcome.failed;
    } finally {
      watchdog?.cancel();
    }
  }
}

enum _PutOutcome { sent, failed, cancelled }

int _partLength(int n, int partSize, int partCount, int fileSize) =>
    n < partCount ? partSize : fileSize - partSize * (partCount - 1);

/// Bytes [start, end) of [source], for pickers that cannot read a range.
Stream<Uint8List> _slice(Stream<Uint8List> source, int start, int end) async* {
  var position = 0;
  await for (final chunk in source) {
    final chunkEnd = position + chunk.length;
    if (chunkEnd > start && position < end) {
      final from = start > position ? start - position : 0;
      final to = end < chunkEnd ? end - position : chunk.length;
      yield Uint8List.sublistView(chunk, from, to);
    }
    position = chunkEnd;
    if (position >= end) break;
  }
}
