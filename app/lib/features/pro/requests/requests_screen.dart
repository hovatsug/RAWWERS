import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/requests/widgets/request_countdown.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(requestsControllerProvider);
    final filter = ref.watch(requestsFilterControllerProvider);
    final notifier = ref.read(requestsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: Column(
          children: [
            _FilterBar(selected: filter),
            Expanded(
              child: switch (page) {
                AsyncLoading() => const PagedListSkeleton(),
                AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
                AsyncData(:final value) => PagedListView<BookingRequestListItem>(
                    page: value,
                    onRefresh: notifier.refresh,
                    onLoadMore: notifier.loadMore,
                    emptyTitle: _emptyTitle(filter),
                    emptyBody: _emptyBody(filter),
                    itemBuilder: (context, request) => _RequestCard(request: request),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.selected});

  final RequestsFilter selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s8),
      child: Row(
        children: [
          for (final filter in RequestsFilter.values) ...[
            RFilterChip(
              label: filter.label,
              selected: filter == selected,
              onPressed: () => ref.read(requestsFilterControllerProvider.notifier).select(filter),
            ),
            const SizedBox(width: RSpace.s8),
          ],
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.request});

  final BookingRequestListItem request;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = widget.request;
    final notifier = ref.read(requestsControllerProvider.notifier);

    // Non-null only while pending - the server omits the countdown once a
    // request is settled, so this doubles as "is this still actionable".
    final seconds = request.secondsUntilExpiry;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_dateRange(request), style: theme.textTheme.titleMedium),
          if (request.locationText != null) ...[
            const SizedBox(height: RSpace.s4),
            Text(request.locationText!, style: theme.textTheme.bodyMedium),
          ],
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: RSpace.s8),
            Text(request.notes!, style: theme.textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          if (seconds != null) ...[
            const SizedBox(height: RSpace.s12),
            RequestCountdown(
              secondsUntilExpiry: seconds,
              // Server is the truth: the expiry sweep lags the deadline by up
              // to 15 minutes, so ask rather than assume the request is dead.
              onExpired: notifier.refresh,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (seconds != null) ...[
            const SizedBox(height: RSpace.s16),
            Row(
              children: [
                Expanded(
                  child: RButton(
                    label: 'Accept',
                    loading: _busy,
                    onPressed: _busy ? null : () => _run(() => notifier.accept(request.id)),
                  ),
                ),
                const SizedBox(width: RSpace.s12),
                Expanded(
                  child: RButton(
                    label: 'Decline',
                    variant: RButtonVariant.secondary,
                    onPressed: _busy ? null : () => _run(() => notifier.decline(request.id)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _dateRange(BookingRequestListItem request) {
  final start = request.requestedStart.toLocal();
  final end = request.requestedEnd.toLocal();
  final date = '${start.day}/${start.month}/${start.year}';
  final from = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  final to = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  return '$date · $from–$to';
}

String _emptyTitle(RequestsFilter filter) => switch (filter) {
      RequestsFilter.pending => 'Nothing waiting on you',
      RequestsFilter.accepted => 'No accepted requests yet',
      RequestsFilter.declined => 'Nothing declined',
      RequestsFilter.expired => 'Nothing expired',
    };

String? _emptyBody(RequestsFilter filter) => switch (filter) {
      RequestsFilter.pending => 'New booking requests land here. You have 48 hours to respond to each one.',
      RequestsFilter.accepted => 'Requests you accept show up here, and become gigs once the client pays.',
      _ => null,
    };
