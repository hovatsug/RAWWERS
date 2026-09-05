import 'package:decimal/decimal.dart';
import 'package:rawwers/api/models/create_gig_request.dart';

/// The generated CreateGigRequest types `amountTotal` as `dynamic` - see
/// pro_package_money.dart for why. Build every CreateGigRequest through
/// here, never the raw generated constructor.
CreateGigRequest createGigRequest({
  required String proUserId,
  String? nicheId,
  required Decimal amountTotal,
  String currency = 'EUR',
  String? locationText,
  DateTime? scheduledStart,
  DateTime? scheduledEnd,
}) {
  return CreateGigRequest(
    proUserId: proUserId,
    nicheId: nicheId,
    amountTotal: amountTotal.toStringAsFixed(2),
    currency: currency,
    locationText: locationText,
    scheduledStart: scheduledStart,
    scheduledEnd: scheduledEnd,
  );
}
