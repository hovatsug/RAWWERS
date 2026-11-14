import 'package:rawwers/api/models/credit_history_item.dart';
import 'package:rawwers/core/format/money.dart';

/// "€1.00" from the server's decimal string, in the credit's [currency]
/// (every credit amount the API sends carries one; euros until batch M4).
/// Credit is never shown as points and never called RAWW (a photographer's
/// RAWW is a different unit).
String creditAmount(String amount, {required String currency}) {
  final negative = amount.startsWith('-');
  final digits = negative ? amount.substring(1) : amount;
  return '${negative ? '−' : ''}${RMoney.symbolFor(currency)}$digits';
}

/// "+€1.00" / "−€2.00" for the history.
String signedCreditAmount(String amount, {required String currency}) =>
    amount.startsWith('-') ? creditAmount(amount, currency: currency) : '+${creditAmount(amount, currency: currency)}';

/// What an entry was, in the client's words.
String creditLabel(CreditHistoryItem item) => switch (item.kind) {
      'marketing_permission' => item.photographerFirstName == null
          ? 'Marketing permission'
          : 'Marketing permission · booking with ${item.photographerFirstName}',
      'used_on_booking' => 'Used on a booking',
      'returned' => 'Returned to you',
      'refunded_credit' => 'Refunded credit',
      'reversed' => 'Reversed',
      'earned' => 'Credit earned',
      _ => 'Adjustment',
    };
