import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/chat_thread_status.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/messages/messages_controller.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(messagesControllerProvider);
    final notifier = ref.read(messagesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: SafeArea(
        child: switch (page) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
          AsyncData(:final value) => PagedListView<ChatThreadSummary>(
              page: value,
              onRefresh: notifier.refresh,
              onLoadMore: notifier.loadMore,
              emptyTitle: 'No conversations yet',
              emptyBody: 'Ask a photographer a question from their profile before you book.',
              emptyIcon: Icons.chat_bubble_outline,
              itemBuilder: (context, thread) => _ThreadCard(thread: thread),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final ChatThreadSummary thread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusLabel(thread.status);

    return InkWell(
      onTap: () => context.push(ClientRoute.thread(thread.id)),
      child: RCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // `ChatThreadSummary` carries `pro_user_id` and no display
                  // name, so there is nothing better to title this with - see
                  // docs/BACKEND_GAPS.md. A UUID would be worse than a
                  // generic noun, so the generic noun wins until the summary
                  // carries a name.
                  Text('Photographer', style: theme.textTheme.titleSmall),
                  const SizedBox(height: RSpace.s4),
                  Text(
                    'Started ${_relative(thread.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: RSpace.s8),
              RStatusChip(label: status.$1, kind: status.$2),
            ],
          ],
        ),
      ),
    );
  }
}

/// Only states worth calling out get a chip. An open thread is the norm and
/// needs no label; a closed one and one a person has stepped into do.
(String, RStatusChipKind)? _statusLabel(ChatThreadStatus status) => switch (status) {
      ChatThreadStatus.open => null,
      // Two enum values for one concept - the backend has not reconciled
      // `pro_takeover` and `pro_active` yet (docs/BACKEND_GAPS.md), so both
      // are handled and read the same to the client, who should not see the
      // seam.
      ChatThreadStatus.proTakeover || ChatThreadStatus.proActive => ('Photographer replying', RStatusChipKind.inProgress),
      ChatThreadStatus.closed => ('Closed', RStatusChipKind.positive),
    };

String _relative(DateTime at) {
  final delta = DateTime.now().difference(at.toLocal());
  if (delta.inMinutes < 1) return 'just now';
  if (delta.inHours < 1) return '${delta.inMinutes}m ago';
  if (delta.inDays < 1) return '${delta.inHours}h ago';
  if (delta.inDays < 30) return '${delta.inDays}d ago';
  return '${(delta.inDays / 30).floor()}mo ago';
}
