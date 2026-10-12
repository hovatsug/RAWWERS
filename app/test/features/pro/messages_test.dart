import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/chat_message_v1_view.dart';
import 'package:rawwers/api/models/chat_sender_type.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/api/models/chat_thread_status.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/client/messages/thread_screen.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';
import 'package:rawwers/features/pro/messages/pro_messages_screen.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/shared/chat/chat_side.dart';

ChatThreadSummary _summary(String id, {int unread = 0, String? preview, String? client = 'Rita Sousa'}) => ChatThreadSummary(
      id: id,
      proUserId: 'pro-1',
      clientUserId: 'client-$id',
      status: ChatThreadStatus.open,
      createdAt: DateTime.utc(2026, 10, 12, 9),
      updatedAt: DateTime.utc(2026, 10, 12, 9),
      clientDisplayName: client,
      unreadCount: unread,
      lastMessagePreview: preview,
      lastMessageAt: DateTime.now().toUtc(),
    );

class _FakeInbox extends ProMessagesController {
  _FakeInbox(this.threads);
  final List<ChatThreadSummary> threads;
  @override
  Future<List<ChatThreadSummary>> build() async => threads;
}

class _FakeUnread extends ProUnreadController {
  _FakeUnread(this.count);
  final int count;
  @override
  Future<int> build() async => count;
}

class _FakeProThread extends ProThreadController {
  _FakeProThread(this.detail);
  final ChatThreadDetailResponse detail;
  int reads = 0;
  @override
  Future<ChatThreadDetailResponse> build(String threadId) async => detail;
  @override
  Future<void> markRead() async => reads++;
  @override
  Future<String?> send(String content) async => null;
}

ChatMessageV1View _m(String text, ChatSenderType sender) =>
    ChatMessageV1View(id: 'm-$text', threadId: 't-1', senderType: sender, content: text, createdAt: DateTime.utc(2026, 10, 12, 9));

void main() {
  testWidgets('the inbox shows who wrote, what they said last, and what is unread', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        proMessagesControllerProvider.overrideWith(() => _FakeInbox([
              _summary('a', unread: 2, preview: 'Are you free on the 14th?'),
              _summary('b', client: 'Tomás', preview: 'Thanks!'),
            ])),
        proUnreadControllerProvider.overrideWith(() => _FakeUnread(1)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: ProMessagesScreen(threadPath: (id) => '/messages/$id')),
    ));
    await tester.pump();

    expect(find.text('Rita Sousa'), findsOneWidget);
    expect(find.text('Are you free on the 14th?'), findsOneWidget);
    expect(find.text('2'), findsOneWidget, reason: 'the unread conversation carries its count');
    expect(find.text('Thanks!'), findsOneWidget);
  });

  testWidgets('an empty inbox says where messages will come from', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        proMessagesControllerProvider.overrideWith(() => _FakeInbox(const [])),
        proUnreadControllerProvider.overrideWith(() => _FakeUnread(0)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: ProMessagesScreen(threadPath: (id) => '/messages/$id')),
    ));
    await tester.pump();

    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('the Messages tab carries the unread count, and nothing at zero', (tester) async {
    Future<void> pumpWith(int unread) => tester.pumpWidget(ProviderScope(
          key: ValueKey(unread),
          overrides: [proUnreadControllerProvider.overrideWith(() => _FakeUnread(unread))],
          child: MaterialApp(theme: buildProTheme(), home: const Scaffold(body: MessagesTabIcon(Icons.chat_bubble_outline))),
        ));

    await pumpWith(3);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await pumpWith(0);
    await tester.pump();
    expect(find.text('0'), findsNothing);
  });

  testWidgets("the photographer sees their assistant's replies marked, and reading is recorded", (tester) async {
    final fake = _FakeProThread(ChatThreadDetailResponse(
      thread: _summary('t-1'),
      messages: [
        _m('How much for portraits?', ChatSenderType.client),
        _m('From EUR 120 for an hour.', ChatSenderType.aI),
        _m('Happy to help - when?', ChatSenderType.pro),
      ],
    ));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        proThreadControllerProvider('t-1').overrideWith(() => fake),
        proUnreadControllerProvider.overrideWith(() => _FakeUnread(0)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const ThreadScreen(threadId: 't-1', side: ChatSide.pro)),
    ));
    await tester.pump();

    expect(find.text('Your assistant'), findsOneWidget, reason: 'what was said on their behalf is marked as such');
    expect(find.text('Rita Sousa'), findsWidgets, reason: 'the client is named');
    expect(find.text('You'), findsNothing, reason: 'their own messages sit on the right, unlabelled');
    expect(fake.reads, 1, reason: 'opening the conversation marks it read');
  });
}
