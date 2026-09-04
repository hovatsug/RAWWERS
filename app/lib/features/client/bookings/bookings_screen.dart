import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/client_booking_list_item.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/bookings/booking_status_display.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(bookingsControllerProvider);
    final notifier = ref.read(bookingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: SafeArea(
        child: switch (page) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => PagedListError(error: error, onRetry: notifier.refresh),
          AsyncData(:final value) => PagedListView<ClientBookingListItem>(
              page: value,
              onRefresh: notifier.refresh,
              onLoadMore: notifier.loadMore,
              emptyTitle: 'No bookings yet',
              // 24, not 48: `client_booking_request` sets expires_at to
              // now + 24h. See docs/BACKEND_GAPS.md - the product intent is
              // 48h and the code is 24h, and the copy follows the code,
              // because telling someone they have twice as long as they do
              // is the failure that costs them the booking.
              emptyBody: 'Find a photographer in Discover and send them a request - they have 24 hours to reply.',
              emptyIcon: Icons.camera_outdoor_outlined,
              itemBuilder: (context, booking) => _BookingCard(booking: booking),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final ClientBookingListItem booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = BookingStatusDisplay.from(
      bookingStatus: booking.bookingStatus,
      gigStatus: booking.gigStatus,
      paymentStatus: booking.paymentStatus,
    );

    return InkWell(
      onTap: () => context.push(ClientRoute.bookingDetail(booking.bookingId)),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    formatBookingWindow(booking.requestedStart, booking.requestedEnd),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: RSpace.s8),
                RStatusChip(label: status.label, kind: status.kind),
              ],
            ),
            if (booking.locationText != null && booking.locationText!.isNotEmpty) ...[
              const SizedBox(height: RSpace.s4),
              Text(booking.locationText!, style: theme.textTheme.bodyMedium),
            ],
            if (status.canPay) ...[
              const SizedBox(height: RSpace.s12),
              Text(
                'Your photographer accepted. Pay to confirm the date.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Sat 12 Sep, 14:00–16:00" - the shoot window, in the device's local zone.
///
/// The API sends UTC; a client reading "09:00" for a 14:00 Lisbon shoot would
/// be a booking they miss.
String formatBookingWindow(DateTime start, DateTime end) {
  final localStart = start.toLocal();
  final localEnd = end.toLocal();
  final day = '${_weekdays[localStart.weekday - 1]} ${localStart.day} ${_months[localStart.month - 1]}';
  return '$day, ${_time(localStart)}–${_time(localEnd)}';
}

String _time(DateTime at) => '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
