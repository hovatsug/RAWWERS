import 'package:decimal/decimal.dart';
import 'package:rawwers/api/models/payout_request_create_request.dart';

/// The generated PayoutRequestCreateRequest types `amountEur` as `dynamic` -
/// see pro_package_money.dart for why. Build every PayoutRequestCreateRequest
/// through here, never the raw generated constructor.
PayoutRequestCreateRequest createPayoutRequest({required Decimal amountEur}) {
  return PayoutRequestCreateRequest(amountEur: amountEur.toStringAsFixed(2));
}
