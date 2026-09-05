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

class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({required this.threadId, super.key});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = ref.watch(threadControllerProvider(threadId));

    return Scaffold(
      appBar: AppBar(title: Text(thread.valueOrNull?.thread.proDisplayName ?? 'Conversation')),
      body: SafeArea(
        child: switch (thread) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => RErrorState(
            message: pagingFailureMessage(error),
            onRetry: () => ref.invalidate(threadControllerProvider(threadId)),
          ),
          AsyncData(:final value) => _Thread(threadId: threadId, detail: value),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({required this.threadId, required this.detail});

  final String threadId;
  final ChatThreadDetailResponse detail;

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
                  itemBuilder: (context, index) =>
                      _Bubble(message: messages[messages.length - 1 - index], proName: detail.thread.proDisplayName),
                ),
        ),
        if (closed)
          const Padding(padding: EdgeInsets.all(RSpace.s16), child: Text('This conversation is closed.'))
        else
          _Composer(threadId: threadId),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.proName});

  final ChatMessageV1View message;
  final String? proName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.senderType == ChatSenderType.client;
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
                child: Text(_senderLabel(message.senderType, proName), style: theme.textTheme.bodySmall),
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

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.threadId});

  final String threadId;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
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

    final error = await ref.read(threadControllerProvider(widget.threadId).notifier).send(text);
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
