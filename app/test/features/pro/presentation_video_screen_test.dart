// "Your introduction video" (BETA_SCOPE #37): every state in plain words.
//
// Not available (no Mux): the message and no buttons. None yet: Choose and
// Record. Uploading: a progress bar. Processing: says so, and checks again.
// Ready: a preview that plays on tap, Replace and Delete (with a
// confirmation). Failed: what happened, and choosing again. A video over the
// limits is refused before anything is sent; an upload that stops can be
// tried again with the same request id.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/presentation_video_client.dart';
import 'package:rawwers/api/models/my_presentation_video.dart';
import 'package:rawwers/api/models/my_presentation_video_state.dart';
import 'package:rawwers/api/models/presentation_video_playback.dart';
import 'package:rawwers/api/models/presentation_video_upload_request.dart';
import 'package:rawwers/api/models/presentation_video_upload_response.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/presentation_video/presentation_video_controller.dart';
import 'package:rawwers/features/pro/presentation_video/presentation_video_screen.dart';
import 'package:rawwers/features/shared/video/video_surface.dart';
import 'package:retrofit/retrofit.dart';

MyPresentationVideoState _state({bool available = true, MyPresentationVideo? shown, MyPresentationVideo? pending}) =>
    MyPresentationVideoState(
      available: available,
      message: available ? null : 'Video is not available right now.',
      maxSeconds: 60,
      maxBytes: 100000000,
      shown: shown,
      pending: pending,
    );

const _ready = MyPresentationVideo(mediaAssetId: 'v1', status: 'ready', posterUrl: 'https://x.test/p.jpg', playbackUrl: 'https://x.test/v.mp4', durationSeconds: 12);

class _FakeClient implements PresentationVideoClient {
  _FakeClient(this.state);

  MyPresentationVideoState state;
  final starts = <PresentationVideoUploadRequest>[];
  final deleted = <String>[];
  bool failStart = false;

  Response<T> _ok<T>(T data) => Response<T>(data: data, statusCode: 200, requestOptions: RequestOptions());

  @override
  Future<HttpResponse<MyPresentationVideoState>> myPresentationVideoV1ProMePresentationVideoGet({
    required String? authorization, required String? xMinusUserMinusId, CancelToken? cancelToken,
    ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, Map<String, dynamic>? extras,
  }) async => HttpResponse(state, _ok(state));

  @override
  Future<HttpResponse<PresentationVideoUploadResponse>> startPresentationVideoUploadV1ProMePresentationVideoUploadsPost({
    required PresentationVideoUploadRequest requestBody, required String? authorization, required String? xMinusUserMinusId,
    CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, Map<String, dynamic>? extras,
  }) async {
    starts.add(requestBody);
    if (failStart) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(),
        response: Response(statusCode: 422, requestOptions: RequestOptions(), data: {
          'error': {'code': 'video_too_long', 'message': 'Your video is longer than 60 seconds. Choose or record a shorter one.'},
        }),
      );
    }
    const body = PresentationVideoUploadResponse(mediaAssetId: 'v2', uploadUrl: 'https://upload.test/v2', status: 'uploading');
    return HttpResponse(body, _ok(body));
  }

  @override
  Future<HttpResponse<MyPresentationVideoState>> presentationVideoUploadedV1ProMePresentationVideoMediaAssetIdUploadedPost({
    required String mediaAssetId, required String? authorization, required String? xMinusUserMinusId, CancelToken? cancelToken,
    ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, Map<String, dynamic>? extras,
  }) async {
    state = _state(shown: state.shown, pending: MyPresentationVideo(mediaAssetId: mediaAssetId, status: 'processing'));
    return HttpResponse(state, _ok(state));
  }

  @override
  Future<HttpResponse<MyPresentationVideoState>> deletePresentationVideoV1ProMePresentationVideoMediaAssetIdDelete({
    required String mediaAssetId, required String? authorization, required String? xMinusUserMinusId, CancelToken? cancelToken,
    ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, Map<String, dynamic>? extras,
  }) async {
    deleted.add(mediaAssetId);
    state = _state();
    return HttpResponse(state, _ok(state));
  }

  @override
  Future<HttpResponse<PresentationVideoPlayback>> playPresentationVideoV1ClientProsProUserIdPresentationVideoPlaybackPost({
    required String proUserId, required String? authorization, required String? xMinusUserMinusId, CancelToken? cancelToken,
    ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, Map<String, dynamic>? extras,
  }) async => throw UnimplementedError();
}

const _picked = PickedVideo(path: '/tmp/clip.mov', byteSize: 5000000, contentType: 'video/quicktime', durationSeconds: 20);

Future<_FakeClient> _pump(
  WidgetTester tester,
  MyPresentationVideoState state, {
  PickedVideo? pick = _picked,
  Future<void> Function(String url, PickedVideo video, void Function(double) onProgress)? upload,
}) async {
  final client = _FakeClient(state);
  // A phone, tall enough for the preview and its buttons.
  tester.view.physicalSize = const Size(1170, 3600);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      presentationVideoClientProvider.overrideWithValue(client),
      videoPickerProvider.overrideWithValue((source, max) async => pick),
      videoUploaderProvider.overrideWithValue(upload ?? (url, video, onProgress) async => onProgress(1)),
      videoSurfaceProvider.overrideWithValue((url, {onFailed}) => Text('playing $url', key: const ValueKey('surface'))),
    ],
    child: MaterialApp(theme: buildProTheme(), home: const PresentationVideoScreen()),
  ));
  await tester.pump();
  await tester.pump();
  return client;
}

void main() {
  testWidgets('not available: the message, and no buttons', (tester) async {
    await _pump(tester, _state(available: false));
    expect(find.text('Video is not available right now.'), findsOneWidget);
    expect(find.text('Choose a video'), findsNothing);
    expect(find.text('Record a video'), findsNothing);
  });

  testWidgets('no video yet: choose or record', (tester) async {
    await _pump(tester, _state());
    expect(find.byKey(const ValueKey('video-none')), findsOneWidget);
    expect(find.text('Choose a video'), findsOneWidget);
    expect(find.text('Record a video'), findsOneWidget);
  });

  testWidgets('uploading shows a progress bar, then processing', (tester) async {
    final gate = Completer<void>();
    late void Function(double) report;
    final client = await _pump(tester, _state(), upload: (url, video, onProgress) {
      report = onProgress;
      onProgress(0.42);
      return gate.future;
    });
    await tester.tap(find.text('Choose a video'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('video-uploading')), findsOneWidget);
    expect(find.text('Uploading… 42%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Choose a video'), findsNothing, reason: 'no second upload while one is going');
    report(1);
    gate.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('video-processing')), findsOneWidget);
    expect(client.starts.single.requestId, isNotEmpty);
    expect(client.starts.single.contentType, 'video/quicktime');
    // The screen looks again while Mux processes; nothing left running.
    await tester.pump(PresentationVideoController.pollEvery);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ready: a preview that plays on tap, replace and delete', (tester) async {
    await _pump(tester, _state(shown: _ready));
    expect(find.byKey(const ValueKey('video-ready')), findsOneWidget);
    expect(find.byKey(const ValueKey('surface')), findsNothing, reason: 'never plays by itself');
    expect(find.text('Clients see this video (12 seconds).'), findsOneWidget);
    expect(find.text('Replace with a video from your library'), findsOneWidget);
    expect(find.text('Delete video'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('video-play')));
    await tester.pump();
    expect(find.text('playing https://x.test/v.mp4'), findsOneWidget);
  });

  testWidgets('delete asks first, and cancelling keeps the video', (tester) async {
    final client = await _pump(tester, _state(shown: _ready));
    await tester.ensureVisible(find.text('Delete video'));
    await tester.tap(find.text('Delete video'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your video?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(client.deleted, isEmpty);
    await tester.tap(find.text('Delete video'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(client.deleted, ['v1']);
    expect(find.byKey(const ValueKey('video-none')), findsOneWidget);
  });

  testWidgets('failed: what happened, and choosing again', (tester) async {
    await _pump(tester, _state(pending: const MyPresentationVideo(mediaAssetId: 'v3', status: 'failed', message: 'This video could not be processed. Try another one, or record it again.')));
    expect(find.byKey(const ValueKey('video-failed')), findsOneWidget);
    expect(find.textContaining('could not be processed'), findsOneWidget);
    expect(find.text('Choose a video'), findsOneWidget);
  });

  testWidgets('a video over 60 seconds is refused before anything is sent', (tester) async {
    final client = await _pump(tester, _state(), pick: const PickedVideo(path: '/tmp/long.mp4', byteSize: 9000000, contentType: 'video/mp4', durationSeconds: 75));
    await tester.tap(find.text('Choose a video'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('longer than 60 seconds'), findsOneWidget);
    expect(client.starts, isEmpty);
  });

  testWidgets('a video over 100 MB is refused before anything is sent', (tester) async {
    final client = await _pump(tester, _state(), pick: const PickedVideo(path: '/tmp/big.mov', byteSize: 120000000, contentType: 'video/quicktime', durationSeconds: 30));
    await tester.tap(find.text('Choose a video'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('larger than 100 MB'), findsOneWidget);
    expect(client.starts, isEmpty);
  });

  testWidgets("the server's refusal is shown in its words", (tester) async {
    final client = await _pump(tester, _state());
    client.failStart = true;
    await tester.tap(find.text('Choose a video'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('video-upload-error')), findsOneWidget);
    expect(find.textContaining('longer than 60 seconds'), findsWidgets);
  });

  testWidgets('an upload that stops can be tried again with the same request id', (tester) async {
    var attempts = 0;
    final client = await _pump(tester, _state(), upload: (url, video, onProgress) async {
      attempts++;
      if (attempts == 1) throw Exception('connection lost');
      onProgress(1);
    });
    await tester.tap(find.text('Choose a video'));
    await tester.pump();
    await tester.pump();
    expect(find.text('The upload stopped. Check your connection and try again.'), findsWidgets);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(client.starts, hasLength(2));
    expect(client.starts[0].requestId, client.starts[1].requestId, reason: 'a retry must not start a second upload');
    expect(find.byKey(const ValueKey('video-processing')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
