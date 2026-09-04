import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';
import 'package:rawwers/features/client/bookings/booking_status_display.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        child: switch (booking) {
          AsyncLoading() => const PagedListSkeleton(),
          AsyncError(:final error) => RErrorState(
              message: pagingFailureMessage(error),
              onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
            ),
          AsyncData(:final value) => _Detail(bookingId: bookingId, booking: value),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.bookingId, required this.booking});

  final String bookingId;
  final ClientBookingStatusResponse booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = BookingStatusDisplay.from(
      bookingStatus: booking.bookingStatus,
      gigStatus: booking.gigStatus,
      paymentStatus: booking.paymentStatus,
    );
    final timeline = parseTimeline(booking.timeline);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(bookingDetailProvider(bookingId)),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RSpace.s16),
        children: [
          Row(
            children: [
              RStatusChip(label: status.label, kind: status.kind),
            ],
          ),
          if (status.canPay) ...[
            const SizedBox(height: RSpace.s16),
            _PayPanel(bookingId: bookingId),
          ],
          const SizedBox(height: RSpace.s24),
          Text('History', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s12),
          if (timeline.isEmpty)
            Text('Nothing has happened yet.', style: theme.textTheme.bodyMedium)
          else
            for (final entry in timeline) ...[
              _TimelineRow(entry: entry),
              const SizedBox(height: RSpace.s12),
            ],
        ],
      ),
    );
  }
}

class _PayPanel extends ConsumerWidget {
  const _PayPanel({required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(bookingPaymentControllerProvider(bookingId));
    final notifier = ref.read(bookingPaymentControllerProvider(bookingId).notifier);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pay to confirm', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'Your photographer accepted. The date is not held until this is paid.',
            style: theme.textTheme.bodyMedium,
          ),
          if (progress case PaymentFailed(:final message)) ...[
            const SizedBox(height: RSpace.s12),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: RShade.shade600)),
          ],
          if (progress is PaymentSucceeded) ...[
            const SizedBox(height: RSpace.s12),
            // Deliberately not "Paid": the sheet closing means Stripe took the
            // payment, but the booking only moves once the webhook lands.
            Text(
              'Payment sent. This updates as soon as it clears.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: RSpace.s16),
          RButton(
            label: progress is PaymentFailed ? 'Try again' : 'Pay now',
            loading: progress is PaymentWorking,
            onPressed: progress is PaymentWorking || progress is PaymentSucceeded ? null : notifier.pay,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final BookingTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = BookingStatusDisplay.from(bookingStatus: entry.to);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            _stamp(entry.at),
            style: theme.textTheme.bodySmall?.copyWith(fontFeatures: RType.tabularFigures),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(display.label, style: theme.textTheme.bodyMedium),
              if (entry.reason != null)
                Text(entry.reason!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

String _stamp(DateTime at) {
  final day = '${at.day} ${_months[at.month - 1]}';
  return '$day ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
