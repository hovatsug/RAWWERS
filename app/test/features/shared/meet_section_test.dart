// The "Meet the photographer" section: absent when empty, and a video slot
// laid out ready for when videos exist.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/meet_interview_item.dart';
import 'package:rawwers/api/models/meet_the_photographer_view.dart';
import 'package:rawwers/api/models/presentation_video_view.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';

Future<void> _pump(WidgetTester tester, MeetThePhotographerView? meet) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: MeetSection(name: 'Ana', meet: meet)))));

void main() {
  testWidgets('nothing at all for no section', (tester) async {
    await _pump(tester, null);
    expect(find.textContaining('Meet'), findsNothing);
  });

  testWidgets('nothing at all for an empty one', (tester) async {
    await _pump(tester, const MeetThePhotographerView(interview: []));
    expect(find.textContaining('Meet'), findsNothing);
  });

  testWidgets('words only: no video slot', (tester) async {
    await _pump(tester, const MeetThePhotographerView(interview: [MeetInterviewItem(questionId: 'q', title: 'Who I am', answer: 'Ana.')]));
    expect(find.text('Meet Ana'), findsOneWidget);
    expect(find.byType(PresentationVideoSlot), findsNothing);
  });

  testWidgets('a video takes its slot above the words, with a play badge', (tester) async {
    await _pump(
      tester,
      const MeetThePhotographerView(
        video: PresentationVideoView(playbackUrl: 'https://example.test/v.m3u8', durationSeconds: 52),
        interview: [MeetInterviewItem(questionId: 'q', title: 'Who I am', answer: 'Ana.')],
      ),
    );
    expect(find.byType(PresentationVideoSlot), findsOneWidget);
    expect(find.byType(VideoPlayBadge), findsOneWidget);
    expect(tester.getTopLeft(find.byType(PresentationVideoSlot)).dy, lessThan(tester.getTopLeft(find.text('Who I am')).dy));
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Video introduction by Ana, 52 seconds'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a video alone is a section', (tester) async {
    await _pump(tester, const MeetThePhotographerView(video: PresentationVideoView(playbackUrl: 'https://example.test/v.m3u8'), interview: []));
    expect(find.text('Meet Ana'), findsOneWidget);
  });
}
