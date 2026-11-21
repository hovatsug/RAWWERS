import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:rawwers/api/models/my_presentation_video_state.dart';
import 'package:rawwers/api/models/presentation_video_upload_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

/// A video the photographer chose or recorded, as far as the phone knows it.
class PickedVideo {
  const PickedVideo({required this.path, required this.byteSize, required this.contentType, this.durationSeconds});

  final String path;
  final int byteSize;
  final String contentType;
  final double? durationSeconds;
}

enum VideoSource { library, camera }

/// Choosing from the library (the phone's picker). Recording uses the
/// in-app camera instead (record_video_screen.dart), which never records
/// above 1080p. A provider so tests choose without a picker.
final videoPickerProvider = Provider<Future<PickedVideo?> Function(VideoSource source, int maxSeconds)>((ref) {
  return (source, maxSeconds) async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: Duration(seconds: maxSeconds));
    if (file == null) return null;
    final size = await file.length();
    final lower = file.path.toLowerCase();
    final type = lower.endsWith('.mov') ? 'video/quicktime' : 'video/mp4';
    double? seconds;
    final reader = VideoPlayerController.file(File(file.path));
    try {
      await reader.initialize();
      seconds = reader.value.duration.inMilliseconds / 1000;
    } catch (_) {
      seconds = null; // The server checks the length Mux measures anyway.
    } finally {
      await reader.dispose();
    }
    return PickedVideo(path: file.path, byteSize: size, contentType: type, durationSeconds: seconds);
  };
});

/// Sends the file to the upload address (Mux's, or the dev fake's) with an
/// HTTP PUT of its bytes. No API headers: the address carries its own
/// permission. A provider so tests send nothing.
final videoUploaderProvider = Provider<Future<void> Function(String url, PickedVideo video, void Function(double) onProgress)>((ref) {
  return (url, video, onProgress) async {
    await Dio().put<void>(
      url,
      data: File(video.path).openRead(),
      options: Options(headers: {
        Headers.contentLengthHeader: video.byteSize,
        Headers.contentTypeHeader: video.contentType,
      }),
      onSendProgress: (sent, total) => onProgress(total > 0 ? sent / total : 0),
    );
  };
});

/// The screen's state: the server's answer, and what this phone is doing.
class PresentationVideoScreenState {
  const PresentationVideoScreenState({required this.server, this.uploadProgress, this.error, this.retry});

  final MyPresentationVideoState server;

  /// 0-1 while this phone sends the file; null otherwise.
  final double? uploadProgress;

  /// What went wrong on this phone, in plain words.
  final String? error;

  /// The upload to try again after a failure on this phone.
  final PickedVideo? retry;

  PresentationVideoScreenState copyWith({MyPresentationVideoState? server, double? uploadProgress, String? error, PickedVideo? retry, bool clearProgress = false, bool clearError = false}) =>
      PresentationVideoScreenState(
        server: server ?? this.server,
        uploadProgress: clearProgress ? null : (uploadProgress ?? this.uploadProgress),
        error: clearError ? null : (error ?? this.error),
        retry: retry ?? this.retry,
      );

  bool get processing => {'uploading', 'processing'}.contains(server.pending?.status) && uploadProgress == null;
}

final presentationVideoControllerProvider =
    AsyncNotifierProvider.autoDispose<PresentationVideoController, PresentationVideoScreenState>(PresentationVideoController.new);

/// "Your introduction video": what the server says, the upload this phone
/// sends, and a look every few seconds while Mux is processing.
class PresentationVideoController extends AutoDisposeAsyncNotifier<PresentationVideoScreenState> {
  Timer? _poll;
  String? _requestId;
  static const pollEvery = Duration(seconds: 4);

  @override
  Future<PresentationVideoScreenState> build() async {
    ref.onDispose(() => _poll?.cancel());
    final server = await _fetch();
    final next = PresentationVideoScreenState(server: server);
    _schedulePoll(next);
    return next;
  }

  Future<MyPresentationVideoState> _fetch() async {
    final result = await apiCall(() => ref.read(presentationVideoClientProvider).myPresentationVideoV1ProMePresentationVideoGet(authorization: null, xMinusUserMinusId: null));
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  void _schedulePoll(PresentationVideoScreenState s) {
    _poll?.cancel();
    if (!s.processing) return;
    _poll = Timer(pollEvery, () async {
      try {
        final server = await _fetch();
        final current = state.valueOrNull;
        if (current == null) return;
        final next = current.copyWith(server: server);
        state = AsyncData(next);
        _schedulePoll(next);
      } catch (_) {
        final current = state.valueOrNull;
        if (current != null) _schedulePoll(current);
      }
    });
  }

  /// Choose from the library, then [uploadVideo]. Returns a message to show, or null.
  Future<String?> pickAndUpload(VideoSource source) async {
    final current = state.valueOrNull;
    if (current == null || !current.server.available) return null;
    final PickedVideo? video;
    try {
      video = await ref.read(videoPickerProvider)(source, current.server.maxSeconds);
    } catch (_) {
      return 'Your videos could not open. Allow RAWWERS to see your videos in Settings.';
    }
    return uploadVideo(video);
  }

  /// A chosen or recorded video: checks the limits here first (the server
  /// checks them again), then uploads. Returns a message to show, or null.
  Future<String?> uploadVideo(PickedVideo? video) async {
    final current = state.valueOrNull;
    if (current == null || !current.server.available || video == null) return null;
    final seconds = video.durationSeconds;
    if (seconds != null && seconds > current.server.maxSeconds + 0.9) {
      return 'Your video is longer than ${current.server.maxSeconds} seconds. Choose or record a shorter one.';
    }
    if (video.byteSize > current.server.maxBytes) {
      return 'Your video is larger than ${current.server.maxBytes ~/ 1000000} MB. Record it in 1080p or choose a shorter clip.';
    }
    _requestId = _newRequestId();
    return _upload(video);
  }

  /// After a failure on this phone: the same video again, with the same
  /// request id, so the server answers with the same upload (never a second).
  Future<String?> retryUpload() async {
    final retry = state.valueOrNull?.retry;
    if (retry == null) return null;
    return _upload(retry);
  }

  Future<String?> _upload(PickedVideo video) async {
    final current = state.valueOrNull!;
    state = AsyncData(PresentationVideoScreenState(server: current.server, uploadProgress: 0));
    final started = await apiCall(() => ref.read(presentationVideoClientProvider).startPresentationVideoUploadV1ProMePresentationVideoUploadsPost(
          requestBody: PresentationVideoUploadRequest(
            byteSize: video.byteSize,
            durationSeconds: video.durationSeconds,
            contentType: video.contentType,
            requestId: _requestId ?? _newRequestId(),
          ),
          authorization: null,
          xMinusUserMinusId: null,
        ));
    final String url;
    final String id;
    switch (started) {
      case Ok(:final value):
        url = value.uploadUrl;
        id = value.mediaAssetId;
      case Err(:final failure):
        return _failed(video, _message(failure));
    }
    try {
      await ref.read(videoUploaderProvider)(url, video, (fraction) {
        final s = state.valueOrNull;
        if (s != null) state = AsyncData(s.copyWith(uploadProgress: fraction));
      });
    } catch (_) {
      return _failed(video, 'The upload stopped. Check your connection and try again.');
    }
    await apiCall(() => ref.read(presentationVideoClientProvider).presentationVideoUploadedV1ProMePresentationVideoMediaAssetIdUploadedPost(
          mediaAssetId: id,
          authorization: null,
          xMinusUserMinusId: null,
        ));
    _requestId = null;
    final server = await _fetch().catchError((_) => state.valueOrNull!.server);
    final next = PresentationVideoScreenState(server: server);
    state = AsyncData(next);
    _schedulePoll(next);
    return null;
  }

  String? _failed(PickedVideo video, String message) {
    final s = state.valueOrNull;
    if (s != null) state = AsyncData(PresentationVideoScreenState(server: s.server, error: message, retry: video));
    return message;
  }

  /// Deletes the video (after the screen's confirmation). Returns a message, or null.
  Future<String?> delete(String mediaAssetId) async {
    final result = await apiCall(() => ref.read(presentationVideoClientProvider).deletePresentationVideoV1ProMePresentationVideoMediaAssetIdDelete(
          mediaAssetId: mediaAssetId,
          authorization: null,
          xMinusUserMinusId: null,
        ));
    switch (result) {
      case Ok(:final value):
        state = AsyncData(PresentationVideoScreenState(server: value));
        return null;
      case Err(:final failure):
        return _message(failure);
    }
  }

  static String _message(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'No connection. Check it and try again.',
        RateLimited() => 'Too many tries in a short time. Wait a little and try again.',
        BusinessError(:final message) => message,
        _ => 'Something went wrong. Try again.',
      };

  static String _newRequestId() {
    final r = Random.secure();
    return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}
