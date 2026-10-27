import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/core/router/app_router_pro.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/requests/widgets/request_countdown.dart';

/// What is waiting on the photographer, most urgent first: requests to answer
/// (each with the server's own deadline, soonest first), then shoots whose
/// proofs have not been sent. The first carries an accent edge - the one to
/// do now.
///
/// A pointer to where the work is done, never a second place to do it:
/// a request opens the Requests tab, a shoot its delivery screen. Read from
/// the same lists those screens use, so the two cannot disagree.
class NeedsYou extends ConsumerWidget {
  const NeedsYou({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requests = [...?ref.watch(pendingRequestsControllerProvider).valueOrNull?.items]
      ..sort((a, b) => (a.secondsUntilExpiry ?? 1 << 30).compareTo(b.secondsUntilExpiry ?? 1 << 30));
    final proofs = (ref.watch(gigsControllerProvider).valueOrNull?.items ?? const <GigResponse>[])
        .where((g) => g.status == GigStatus.shootDone)
        .toList();

    final items = <Widget>[
      for (final request in requests) _RequestItem(request: request),
      for (final gig in proofs) _ProofsItem(gig: gig),
    ];
    if (items.isEmpty) {
      return RCard(child: Text('Nothing is waiting on you.', style: theme.textTheme.bodyMedium));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: RSpace.s8),
          _Item(first: i == 0, child: items[i]),
        ],
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.first, required this.child});

  final bool first;
  final Widget child;

  static const firstEdgeKey = ValueKey('needs-you-first');

  @override
  Widget build(BuildContext context) {
    if (!first) return child;
    final scheme = Theme.of(context).colorScheme;
    // A strip inside the card's left edge, not a border around it: the
    // card draws its own hairline over anything outside.
    return Stack(
      // The card keeps the full width the list gives it.
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: DecoratedBox(
            key: firstEdgeKey,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(RRadius.surface)),
            ),
            child: const SizedBox(width: RMotif.attentionEdge),
          ),
        ),
      ],
    );
  }
}

/// Exposed so a test can find the first item's edge.
const needsYouFirstKey = _Item.firstEdgeKey;

class _RequestItem extends ConsumerWidget {
  const _RequestItem({required this.request});

  final BookingRequestListItem request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seconds = request.secondsUntilExpiry;
    return InkWell(
      onTap: () => context.go(ProRoute.requests),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking request', style: theme.textTheme.titleMedium),
            const SizedBox(height: RSpace.s4),
            Text(
              RDates.of(context).dateTime(request.requestedStart),
              style: theme.textTheme.bodyMedium,
            ),
            if (seconds != null) ...[
              const SizedBox(height: RSpace.s4),
              RequestCountdown(
                secondsUntilExpiry: seconds,
                onExpired: () => ref.invalidate(pendingRequestsControllerProvider),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProofsItem extends StatelessWidget {
  const _ProofsItem({required this.gig});

  final GigResponse gig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shot = gig.scheduledStart;
    return InkWell(
      onTap: () => context.push(ProRoute.gigDelivery, extra: gig),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Proofs to send', style: theme.textTheme.titleMedium),
            if (shot != null) ...[
              const SizedBox(height: RSpace.s4),
              Text('Shot on ${RDates.of(context).date(shot)}', style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
