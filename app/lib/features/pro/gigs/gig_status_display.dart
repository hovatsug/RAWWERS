import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/design/components/r_chip.dart';

/// Maps the backend's 15 gig states onto the design system's three chip
/// treatments, and onto words a photographer would use.
///
/// The mapping lives in feature code on purpose: RStatusChipKind carries only
/// "ongoing / done / broken", and the design system deliberately doesn't know
/// this domain's state names (see r_chip.dart). The label does the specific
/// work; colour only says whether to worry.
extension GigStatusDisplay on GigStatus {
  RStatusChipKind get chipKind => switch (this) {
        GigStatus.completed || GigStatus.finalDelivered => RStatusChipKind.positive,

        // The four ways a gig ends badly. Filled, not outlined - these are
        // the states a photographer has to notice without hunting for them.
        GigStatus.cancelledByClient ||
        GigStatus.cancelledByPro ||
        GigStatus.refunded ||
        GigStatus.disputed =>
          RStatusChipKind.stopped,

        // Everything still moving. No colour meaning beyond "in flight".
        _ => RStatusChipKind.inProgress,
      };

  /// Written from the pro's side, since this is the pro app: "You've been
  /// paid", not "payment captured". Where a state means someone is waiting,
  /// the label says who - a photographer scanning a list needs to spot the
  /// ones blocked on *them*.
  String get label => switch (this) {
        GigStatus.draft => 'Draft',
        GigStatus.requested => 'Requested',
        GigStatus.accepted => 'Accepted',
        GigStatus.paymentPending => 'Awaiting payment',
        GigStatus.paid => 'Paid',
        GigStatus.scheduled => 'Scheduled',
        GigStatus.shootDone => 'Shoot done',
        GigStatus.proofsDelivered => 'Proofs sent',
        GigStatus.selectionPending => 'Client selecting',
        GigStatus.finalDelivered => 'Delivered',
        GigStatus.completed => 'Completed',
        GigStatus.cancelledByClient => 'Cancelled by client',
        GigStatus.cancelledByPro => 'You cancelled',
        GigStatus.refunded => 'Refunded',
        GigStatus.disputed => 'Disputed',
      };

  /// Whether tapping this booking should open delivery.
  ///
  /// The server refuses to start a gallery for a booking that is unpaid or
  /// cancelled, so a card that opened the delivery screen anyway led to an
  /// error screen. Finished bookings stay openable because their gallery
  /// already exists and delivered work has to be viewable.
  ///
  /// Exhaustive on purpose, no default: a status added on the server has to be
  /// classified here rather than quietly becoming a card that opens.
  bool get canOpenDelivery => switch (this) {
        GigStatus.paid ||
        GigStatus.scheduled ||
        GigStatus.shootDone ||
        GigStatus.proofsDelivered ||
        GigStatus.selectionPending ||
        GigStatus.finalDelivered ||
        GigStatus.completed =>
          true,
        GigStatus.draft ||
        GigStatus.requested ||
        GigStatus.accepted ||
        GigStatus.paymentPending ||
        GigStatus.cancelledByClient ||
        GigStatus.cancelledByPro ||
        GigStatus.refunded ||
        GigStatus.disputed =>
          false,
      };

  /// Why a card does not open, for the ones where the reason is "not yet"
  /// rather than "never". Cancelled and refunded say so in their status chip.
  String? get deliveryNote => switch (this) {
        GigStatus.draft ||
        GigStatus.requested ||
        GigStatus.accepted ||
        GigStatus.paymentPending =>
          'Delivery opens once your client has paid.',
        _ => null,
      };
}
