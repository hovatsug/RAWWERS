import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/chat_message_v1_view.dart';
import 'package:rawwers/api/models/chat_sender_type.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/api/models/chat_thread_status.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/messages/thread_controller.dart';
import 'package:rawwers/features/client/messages/thread_screen.dart';

const _threadId = 'thread-1';

class _FakeThread extends ThreadController {
  _FakeThread(this._detail, {this.sendError});

  final ChatThreadDetailResponse _detail;
  final String? sendError;

  /// What the composer handed us, so the test can assert the text survived a
  /// failed send.
  String? lastSent;

  @override
  Future<ChatThreadDetailResponse> build(String threadId) async => _detail;

  @override
  Future<String?> send(String content) async {
    lastSent = content;
    return sendError;
  }
}

ChatMessageV1View _message(String content, ChatSenderType sender) => ChatMessageV1View(
      id: 'm-$content',
      threadId: _threadId,
      senderType: sender,
      content: content,
      createdAt: DateTime.utc(2026, 9, 10, 9),
    );

ChatThreadDetailResponse _detail({
  ChatThreadStatus status = ChatThreadStatus.open,
  List<ChatMessageV1View>? messages,
}) =>
    ChatThreadDetailResponse(
      thread: ChatThreadSummary(
        id: _threadId,
        proUserId: 'pro-1',
        status: status,
        createdAt: DateTime.utc(2026, 9, 10, 9),
        updatedAt: DateTime.utc(2026, 9, 10, 9),
      ),
      messages: messages ??
          [
            _message('Are you free on the 20th?', ChatSenderType.client),
            _message('Checking with Alex now.', ChatSenderType.aI),
            _message('Yes, 3pm works.', ChatSenderType.pro),
          ],
    );

Widget _wrap(_FakeThread fake) => ProviderScope(
      overrides: [threadControllerProvider(_threadId).overrideWith(() => fake)],
      child: MaterialApp(
        theme: buildClientTheme(),
        home: const ThreadScreen(threadId: _threadId),
      ),
    );

void main() {
  testWidgets('names who is actually answering', (tester) async {
    await tester.pumpWidget(_wrap(_FakeThread(_detail())));
    await tester.pump();

    // An AI reply presented as the photographer's own words would be a lie
    // the client cannot detect.
    expect(find.text('Assistant'), findsOneWidget);
    expect(find.text('Photographer'), findsOneWidget);
    // The client's own messages are not labelled - they are on the right.
    expect(find.text('You'), findsNothing);
  });

  testWidgets('a closed thread explains itself instead of showing a dead composer', (tester) async {
    await tester.pumpWidget(_wrap(_FakeThread(_detail(status: ChatThreadStatus.closed))));
    await tester.pump();

    expect(find.text('This conversation is closed.'), findsOneWidget);
    expect(find.byIcon(Icons.send), findsNothing);
  });

  testWidgets('an empty thread invites the first message', (tester) async {
    await tester.pumpWidget(_wrap(_FakeThread(_detail(messages: const []))));
    await tester.pump();

    expect(find.text('No messages yet. Say hello.'), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('a failed send keeps the text the person typed', (tester) async {
    final fake = _FakeThread(_detail(), sendError: 'Not sent - check your connection.');
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Could you do 4pm instead?');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(fake.lastSent, 'Could you do 4pm instead?');
    expect(find.text('Not sent - check your connection.'), findsOneWidget);
    // Losing someone's message because the network blinked loses it twice.
    expect(find.text('Could you do 4pm instead?'), findsOneWidget);
  });

  testWidgets('a successful send clears the composer', (tester) async {
    final fake = _FakeThread(_detail());
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'See you then.');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(fake.lastSent, 'See you then.');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);
  });
}
