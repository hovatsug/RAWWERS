// The photographer's video on their profile (BETA_SCOPE #37): the poster and
// a play button; nothing plays until tapped (never sound nobody asked for);
// a spinner while the link is fetched; plain words when it cannot play, and
// a second tap tries again; and no video means no video section at all.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/meet_interview_item.dart';
import 'package:rawwers/api/models/meet_the_photographer_view.dart';
import 'package:rawwers/api/models/presentation_video_view.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';
import 'package:rawwers/features/shared/video/video_surface.dart';

const _video = PresentationVideoView(playbackUrl: 'https://x.test/old', posterUrl: 'https://x.test/poster.jpg', durationSeconds: 30);

Future<List<String>> _pump(WidgetTester tester, MeetThePhotographerView? meet, {Future<String?> Function(String)? playback}) async {
  final asked = <String>[];
  tester.view.physicalSize = const Size(1170, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      presentationVideoPlaybackProvider.overrideWithValue((id) {
        asked.add(id);
        return (playback ?? (_) async => 'https://x.test/fresh')(id);
      }),
      videoSurfaceProvider.overrideWithValue((url, {onFailed}) => Text('playing $url', key: const ValueKey('surface'))),
    ],
    child: MaterialApp(
      theme: buildClientTheme(),
      home: Scaffold(body: SingleChildScrollView(child: MeetSection(name: 'Alex', meet: meet, proUserId: 'pro-1'))),
    ),
  ));
  await tester.pump();
  return asked;
}

void main() {
  testWidgets('the poster and a play button; nothing plays by itself', (tester) async {
    await _pump(tester, const MeetThePhotographerView(video: _video, interview: []));
    expect(find.text('Meet Alex'), findsOneWidget);
    expect(find.byKey(const ValueKey('video-play-badge')), findsOneWidget);
    expect(find.byKey(const ValueKey('surface')), findsNothing);
  });

  testWidgets('a tap fetches a fresh link and plays it', (tester) async {
    final gate = Completer<String?>();
    final asked = await _pump(tester, const MeetThePhotographerView(video: _video, interview: []), playback: (_) => gate.future);
    await tester.tap(find.byKey(const ValueKey('video-play-badge')));
    await tester.pump();
    expect(find.byKey(const ValueKey('video-loading')), findsOneWidget);
    gate.complete('https://x.test/fresh');
    await tester.pump();
    expect(asked, ['pro-1']);
    expect(find.text('playing https://x.test/fresh'), findsOneWidget, reason: 'not the five-minute link the profile came with');
  });

  testWidgets('a video that cannot play says so, and a tap tries again', (tester) async {
    var calls = 0;
    await _pump(tester, const MeetThePhotographerView(video: _video, interview: []), playback: (_) async => ++calls == 1 ? null : 'https://x.test/again');
    await tester.tap(find.byKey(const ValueKey('video-play-badge')));
    await tester.pump();
    expect(find.byKey(const ValueKey('video-failed')), findsOneWidget);
    expect(find.text("This video can't play right now. Tap to try again."), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('video-play-badge')));
    await tester.pump();
    expect(find.text('playing https://x.test/again'), findsOneWidget);
  });

  testWidgets('no video: no video, and the words still show', (tester) async {
    await _pump(tester, const MeetThePhotographerView(interview: [MeetInterviewItem(questionId: 'q', title: 'Who I am', answer: 'Alex, portraits.')]));
    expect(find.byKey(const ValueKey('video-play-badge')), findsNothing);
    expect(find.text('Who I am'), findsOneWidget);
  });

  testWidgets('nothing at all: no section', (tester) async {
    await _pump(tester, null);
    expect(find.textContaining('Meet'), findsNothing);
  });
}
