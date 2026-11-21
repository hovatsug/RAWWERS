// Recording the introduction video in the app (owner, 2026-11-21): never
// above 1080p; it stops by itself at the limit; a camera that cannot open
// says so in plain words; the recorded file comes back with its length.
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/presentation_video/presentation_video_controller.dart';
import 'package:rawwers/features/pro/presentation_video/record_video_screen.dart';

class _FakeBackend implements VideoRecorderBackend {
  _FakeBackend({this.failOpen = false});

  final bool failOpen;
  final opened = <bool>[];
  int starts = 0;
  int stops = 0;
  bool closed = false;

  @override
  bool get canSwitch => true;

  @override
  Future<void> open({required bool front}) async {
    opened.add(front);
    if (failOpen) throw StateError('no camera');
  }

  @override
  Widget preview() => const SizedBox(key: ValueKey('preview'), width: 10, height: 10);

  @override
  Future<void> start() async => starts++;

  @override
  Future<String> stop() async {
    stops++;
    return '/videos/clip.mp4';
  }

  @override
  Future<void> close() async => closed = true;
}

Future<Future<PickedVideo?> Function()> _pump(WidgetTester tester, _FakeBackend backend) async {
  PickedVideo? result;
  var done = false;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      videoRecorderBackendProvider.overrideWith((ref) => backend),
      fileSizeProvider.overrideWithValue((path) async => 61000000),
    ],
    child: MaterialApp(
      theme: buildProTheme(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<PickedVideo>(
              MaterialPageRoute(builder: (_) => const RecordVideoScreen(maxSeconds: 60)),
            );
            done = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  return () async => done ? result : null;
}

void main() {
  testWidgets('never above 1080p: 1080p on iOS at a set bit rate, 720p on Android', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(RecordingSettings.preset, ResolutionPreset.veryHigh);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(RecordingSettings.preset, ResolutionPreset.high);
    debugDefaultTargetPlatformOverride = null;
    // A minute at the iOS settings stays under the 100 MB limit.
    expect((RecordingSettings.videoBitrate + RecordingSettings.audioBitrate) * 60 / 8, lessThan(100000000));
  });

  testWidgets('opens the front camera, records, and stops by itself at 60 seconds', (tester) async {
    final backend = _FakeBackend();
    final result = await _pump(tester, backend);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(backend.opened, [true]);
    expect(find.byKey(const ValueKey('preview')), findsOneWidget);
    expect(find.text('Up to 60 seconds. It stops by itself.'), findsOneWidget);

    await tester.tap(find.text('Start recording'));
    await tester.pump();
    expect(backend.starts, 1);
    await tester.pump(const Duration(seconds: 12));
    expect(find.text('0:12 of 1:00'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);

    await tester.pump(const Duration(seconds: 48));
    await tester.pumpAndSettle();
    expect(backend.stops, 1, reason: 'stops by itself at the limit');
    final video = await result();
    expect(video, isNotNull);
    expect(video!.durationSeconds, 60);
    expect(video.byteSize, 61000000);
    expect(video.contentType, 'video/mp4');
    expect(backend.closed, isTrue, reason: 'the camera is given back');
  });

  testWidgets('Stop gives the video back with its length', (tester) async {
    final backend = _FakeBackend();
    final result = await _pump(tester, backend);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start recording'));
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect((await result())!.durationSeconds, 20);
  });

  testWidgets('a camera that cannot open says so, and Close goes back', (tester) async {
    final backend = _FakeBackend(failOpen: true);
    final result = await _pump(tester, backend);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('record-failed')), findsOneWidget);
    expect(find.textContaining('Allow RAWWERS to use the camera and microphone'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(await result(), isNull);
    expect(find.text('open'), findsOneWidget);
  });
}
