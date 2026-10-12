import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';

/// Clients who wrote, newest conversation first. Before this a client's
/// message to a photographer was stored and shown to nobody: the pro app had
/// no way to see it.
class ProMessagesScreen extends ConsumerWidget {
  const ProMessagesScreen({required this.threadPath, super.key});

  /// Where a conversation opens, given its id.
  final String Function(String threadId) threadPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(proMessagesControllerProvider);

    Future<void> refresh() async {
      ref.invalidate(proUnreadControllerProvider);
      await ref.read(proMessagesControllerProvider.notifier).refresh();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: SafeArea(
        child: switch (threads) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => RErrorState(message: pagingFailureMessage(error), onRetry: refresh),
          AsyncData(:final value) when value.isEmpty => RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: const [
                  SizedBox(height: RSpace.s32),
                  REmptyState(
                    title: 'No messages yet',
                    body: 'When a client writes to you from your profile, it appears here.',
                    icon: Icons.chat_bubble_outline,
                  ),
                ],
              ),
            ),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(RSpace.s16),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: RSpace.s8),
                itemBuilder: (context, index) => _ThreadCard(
                  thread: value[index],
                  onTap: () async {
                    await context.push(threadPath(value[index].id));
                    // Reading happened in there; the list and badge catch up.
                    await refresh();
                  },
                ),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final ChatThreadSummary thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = thread.unreadCount;
    final at = thread.lastMessageAt ?? thread.createdAt;

    return InkWell(
      onTap: onTap,
      child: RCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.clientDisplayName ?? 'Client',
                    style: unread > 0 ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700) : theme.textTheme.titleSmall,
                  ),
                  if (thread.lastMessagePreview != null) ...[
                    const SizedBox(height: RSpace.s4),
                    Text(thread.lastMessagePreview!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: RSpace.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_relative(at), style: theme.textTheme.bodySmall),
                if (unread > 0) ...[
                  const SizedBox(height: RSpace.s4),
                  Semantics(label: '$unread unread', child: Badge(label: Text('$unread'))),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _relative(DateTime at) {
  final delta = DateTime.now().difference(at.toLocal());
  if (delta.inMinutes < 1) return 'now';
  if (delta.inHours < 1) return '${delta.inMinutes}m';
  if (delta.inDays < 1) return '${delta.inHours}h';
  return '${delta.inDays}d';
}
