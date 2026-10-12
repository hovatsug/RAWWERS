import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/chat_message_v1_view.dart';
import 'package:rawwers/api/models/chat_sender_type.dart';
import 'package:rawwers/api/models/chat_thread_detail_response.dart';
import 'package:rawwers/api/models/chat_thread_status.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/messages/thread_controller.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';
import 'package:rawwers/features/shared/chat/chat_side.dart';

/// One conversation, from either side - the client app and the pro app
/// share it, so both name the assistant the same way.
///
/// While open it checks for new messages every few seconds (there is no push
/// yet, so this is how a reply shows up) and marks the conversation read
/// whenever something new is on screen.
class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({required this.threadId, this.side = ChatSide.client, super.key});

  final String threadId;
  final ChatSide side;

  static const pollEvery = Duration(seconds: 10);

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen> {
  Timer? _poll;
  int _seen = -1;

  bool get _pro => widget.side == ChatSide.pro;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(ThreadScreen.pollEvery, (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() => _pro
      ? ref.read(proThreadControllerProvider(widget.threadId).notifier).refreshQuietly()
      : ref.read(threadControllerProvider(widget.threadId).notifier).refreshQuietly();

  Future<String?> _send(String text) => _pro
      ? ref.read(proThreadControllerProvider(widget.threadId).notifier).send(text)
      : ref.read(threadControllerProvider(widget.threadId).notifier).send(text);

  void _markReadIfNew(ChatThreadDetailResponse detail) {
    final count = (detail.messages ?? const []).length;
    if (count == _seen) return;
    _seen = count;
    final marked = _pro
        ? ref.read(proThreadControllerProvider(widget.threadId).notifier).markRead()
        : ref.read(threadControllerProvider(widget.threadId).notifier).markRead();
    marked.then((_) {
      if (_pro && mounted) ref.invalidate(proUnreadControllerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = _pro
        ? ref.watch(proThreadControllerProvider(widget.threadId))
        : ref.watch(threadControllerProvider(widget.threadId));
    final detail = thread.valueOrNull;
    if (detail != null) _markReadIfNew(detail);
    final title = _pro ? detail?.thread.clientDisplayName : detail?.thread.proDisplayName;

    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Conversation')),
      body: SafeArea(
        child: switch (thread) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => RErrorState(
            message: pagingFailureMessage(error),
            onRetry: () => _pro
                ? ref.invalidate(proThreadControllerProvider(widget.threadId))
                : ref.invalidate(threadControllerProvider(widget.threadId)),
          ),
          AsyncData(:final value) => _Thread(side: widget.side, detail: value, send: _send),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({required this.side, required this.detail, required this.send});

  final ChatSide side;
  final ChatThreadDetailResponse detail;
  final Future<String?> Function(String) send;

  @override
  Widget build(BuildContext context) {
    final messages = detail.messages ?? const <ChatMessageV1View>[];
    final closed = detail.thread.status == ChatThreadStatus.closed;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('No messages yet. Say hello.'))
              : ListView.separated(
                  // Newest at the bottom, scrolled to on open - the position
                  // a conversation is always read from.
                  reverse: true,
                  padding: const EdgeInsets.all(RSpace.s16),
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
                  itemBuilder: (context, index) => _Bubble(
                    message: messages[messages.length - 1 - index],
                    side: side,
                    proName: detail.thread.proDisplayName,
                    clientName: detail.thread.clientDisplayName,
                  ),
                ),
        ),
        if (closed)
          const Padding(padding: EdgeInsets.all(RSpace.s16), child: Text('This conversation is closed.'))
        else
          _Composer(send: send),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.side, this.proName, this.clientName});

  final ChatMessageV1View message;
  final ChatSide side;
  final String? proName;
  final String? clientName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.senderType == (side == ChatSide.pro ? ChatSenderType.pro : ChatSenderType.client);
    final scheme = theme.colorScheme;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Padding(
                padding: const EdgeInsets.only(bottom: RSpace.s4),
                child: Text(
                  side == ChatSide.pro
                      ? _senderLabelForPro(message.senderType, clientName)
                      : _senderLabel(message.senderType, proName),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: RSpace.s12, vertical: RSpace.s8),
              decoration: BoxDecoration(
                color: mine ? scheme.surfaceContainerHighest : scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(RRadius.surface),
              ),
              child: Text(message.content, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

/// The client is told who is actually answering. An AI reply presented as the
/// photographer's own words would be a small lie with a large blast radius on
/// a marketplace built on trust.
String _senderLabel(ChatSenderType sender, String? proName) => switch (sender) {
  // Named for the photographer it speaks for, but never as them: an AI
  // reply presented as their own words would be a lie the client cannot
  // detect.
  ChatSenderType.aI => proName == null ? 'Assistant' : '$proName\u2019s assistant',
  ChatSenderType.pro => proName ?? 'Photographer',
  ChatSenderType.system => 'RAWWERS',
  ChatSenderType.client => 'You',
};

/// The photographer's view of the same conversation. Their assistant's
/// replies are marked as such, so they can see what was said on their
/// behalf - and answering takes the conversation over from it.
String _senderLabelForPro(ChatSenderType sender, String? clientName) => switch (sender) {
  ChatSenderType.aI => 'Your assistant',
  ChatSenderType.client => clientName ?? 'Client',
  ChatSenderType.system => 'RAWWERS',
  ChatSenderType.pro => 'You',
};

class _Composer extends StatefulWidget {
  const _Composer({required this.send});

  final Future<String?> Function(String) send;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    final error = await widget.send(text);
    if (!mounted) return;

    setState(() {
      _sending = false;
      _error = error;
      // The text is cleared only on success. A failed send that also wiped
      // what someone typed would lose their message twice over.
      if (error == null) _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            Text(_error!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: RShade.shade600)),
            const SizedBox(height: RSpace.s8),
          ],
          Row(
            children: [
              Expanded(
                child: RInput(
                  label: 'Message',
                  controller: _controller,
                  maxLength: chatMessageMaxLength,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: RSpace.s8),
              IconButton(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                tooltip: 'Send',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
