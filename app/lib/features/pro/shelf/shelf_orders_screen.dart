import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/shelf_order_view.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_controller.dart';

/// Where each order is, in words, with the date it got there.
String shelfOrderStatusLine(ShelfOrderView order, RDates dates) => switch (order.status) {
      'placed' => 'Placed on ${dates.date(order.placedAt)}. We will order it from the supplier.',
      'ordered' => 'Ordered from the supplier on ${dates.date(order.orderedAt ?? order.placedAt)}.',
      'shipped' => 'Shipped on ${dates.date(order.shippedAt ?? order.placedAt)}.',
      'delivered' => 'Delivered on ${dates.date(order.deliveredAt ?? order.placedAt)}.',
      'cancelled' => 'Cancelled.',
      'refunded' => 'Cancelled on ${dates.date(order.refundedAt ?? order.placedAt)}. ${order.priceRaww} RAWW back in your balance.',
      _ => order.status,
    };

/// My orders on The Shelf.
class ShelfOrdersScreen extends ConsumerWidget {
  const ShelfOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(shelfOrdersControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: SafeArea(
        child: switch (orders) {
          AsyncData(:final value) when value.isEmpty => const REmptyState(
              title: 'No orders yet',
              body: 'What you order from The Shelf shows here, with where it is.',
            ),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(shelfOrdersControllerProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(RSpace.s16),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
                itemBuilder: (context, index) => _OrderCard(order: value[index]),
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Your orders could not be loaded.',
              onRetry: () => ref.invalidate(shelfOrdersControllerProvider),
            ),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(width: RSize.lineMedium)),
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({required this.order});

  final ShelfOrderView order;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _busy = false;

  Future<void> _cancel() async {
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showRConfirmDialog(
      context,
      title: 'Cancel this order?',
      message: 'Your ${widget.order.priceRaww} RAWW come back at once.',
      confirmLabel: 'Cancel order',
      cancelLabel: 'Keep it',
    );
    if (!sure || !mounted) return;
    setState(() => _busy = true);
    final problem = await ref.read(shelfOrdersControllerProvider.notifier).cancel(widget.order.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (problem != null) messenger.showSnackBar(SnackBar(content: Text(problem)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.title, style: theme.textTheme.titleSmall),
          Text('${order.priceRaww} RAWW', style: muted),
          const SizedBox(height: RSpace.s8),
          Text(shelfOrderStatusLine(order, RDates.of(context)), style: theme.textTheme.bodyMedium),
          if (order.trackingCode != null) ...[
            const SizedBox(height: RSpace.s4),
            SelectableText('Tracking: ${order.trackingCode}', style: muted),
          ],
          if (order.canCancel) ...[
            const SizedBox(height: RSpace.s12),
            RButton(label: 'Cancel order', variant: RButtonVariant.secondary, loading: _busy, onPressed: _busy ? null : _cancel),
          ],
        ],
      ),
    );
  }
}
