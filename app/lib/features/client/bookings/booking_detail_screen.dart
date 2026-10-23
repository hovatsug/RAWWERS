import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_booking_refund.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/core/paging/paged_list_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/features/client/bookings/booking_status_display.dart';
import 'package:rawwers/features/client/bookings/review_panel.dart';

/// How often a booking on a short clock is checked again while the screen
/// is open. A short-notice request has 30 minutes to be answered and 30 to
/// be paid; with no push yet, waiting for a pull could miss most of either.
const shortNoticeRefreshEvery = Duration(seconds: 20);

/// Waiting on something that runs on the short clock: the photographer's
/// answer, or the client's payment.
bool waitsOnShortClock(ClientBookingStatusResponse booking) =>
    booking.shortNotice && (booking.bookingStatus == 'pending' || booking.payBy != null);

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  Timer? _refresh;

  void _keepFresh(bool on) {
    if (on == (_refresh != null)) return;
    _refresh?.cancel();
    _refresh = on
        ? Timer.periodic(shortNoticeRefreshEvery, (_) => ref.invalidate(bookingDetailProvider(widget.bookingId)))
        : null;
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = widget.bookingId;
    final booking = ref.watch(bookingDetailProvider(bookingId));
    _keepFresh(switch (booking.valueOrNull) {
      final b? => waitsOnShortClock(b),
      null => false,
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        // A booking already on screen stays there if checking it again
        // fails - one dropped request out of a check every 20 seconds must
        // not replace it with an error page.
        child: switch (booking) {
          AsyncValue(hasValue: true, :final value?) => _Detail(bookingId: bookingId, booking: value),
          AsyncError(:final error) => RErrorState(
              message: pagingFailureMessage(error),
              onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
            ),
          _ => const PagedListSkeleton(),
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
          if (booking.bookingStatus == 'pending' && booking.expiresAt != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(
              'Your photographer has until ${clockTime(context, booking.expiresAt!)} to answer.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (status.canPay) ...[
            const SizedBox(height: RSpace.s16),
            _PayPanel(bookingId: bookingId, payBy: booking.payBy),
          ],
          if (booking.proofGalleryId != null) ...[
            const SizedBox(height: RSpace.s16),
            _PhotosPanel(bookingId: bookingId, booking: booking),
          ],
          for (final refund in booking.refunds) ...[
            const SizedBox(height: RSpace.s16),
            _RefundCard(refund: refund),
          ],
          if (reviewPanelFor(bookingId, booking) case final review?) ...[
            const SizedBox(height: RSpace.s16),
            review,
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

/// What paying now means, said before paying: the deposit is held against
/// the package and the price is settled when the photos are chosen.
const depositExplainer =
    'Your deposit is held against your package. The final price is set when you choose your photos, '
    'and any difference is refunded to you.';

/// A refund because the price came down after paying, with the reasons in
/// the words the server gives - shown as a refund, never as a change of
/// price the client has to work out.
class _RefundCard extends StatelessWidget {
  const _RefundCard({required this.refund});

  final ClientBookingRefund refund;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Refund of ${refund.currency} ${refund.amount}', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          for (final reason in refund.reasons) Text(reason, style: theme.textTheme.bodyMedium),
          const SizedBox(height: RSpace.s4),
          Text('It goes back to the card you paid with. Banks usually take a few days.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PayPanel extends ConsumerWidget {
  const _PayPanel({required this.bookingId, required this.payBy});

  final String bookingId;
  final DateTime? payBy;

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
            // The time is held until the deadline the pay route enforces - 24
            // hours for an ordinary booking, 30 minutes at short notice -
            // then released.
            payBy == null
                ? 'Your photographer accepted. Pay to confirm it.'
                : 'Your photographer accepted. We are holding this time for you until ${clockTime(context, payBy!)} - pay to confirm it.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s8),
          Text(depositExplainer, style: theme.textTheme.bodySmall),
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


/// The way into the photographs.
///
/// Only rendered once the backend hands over a gallery id, which it does only
/// for a gallery the client is allowed to open - a draft one the photographer
/// is still filling is withheld, so this cannot offer a door onto a 403.
class _PhotosPanel extends StatelessWidget {
  const _PhotosPanel({required this.bookingId, required this.booking});

  final String bookingId;
  final ClientBookingStatusResponse booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryId = booking.proofGalleryId!;
    final choosing = booking.proofGalleryStatus == 'published';

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(choosing ? 'Your photos are ready' : 'Your photos', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            choosing
                ? 'Choose the ones you want to keep.'
                : 'You have already chosen. These are yours.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s12),
          RButton(
            label: choosing ? 'Choose your photos' : 'View your photos',
            onPressed: () => context.push(
              choosing
                  ? ClientRoute.gallery(bookingId, galleryId)
                  : ClientRoute.delivered(bookingId, galleryId),
            ),
          ),
        ],
      ),
    );
  }
}

/// A deadline as the client reads it: the time, and the day when it is not
/// today.
String clockTime(BuildContext context, DateTime at) {
  final local = at.toLocal();
  final now = DateTime.now();
  final time = TimeOfDay.fromDateTime(local).format(context);
  if (local.year == now.year && local.month == now.month && local.day == now.day) return time;
  return '$time on ${local.day}/${local.month}';
}
