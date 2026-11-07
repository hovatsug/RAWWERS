import 'package:rawwers/api/models/credit_history_item.dart';

/// "€1.00" from the server's decimal string. Credit is shown in euros,
/// never as points and never called RAWW (a photographer's RAWW is a
/// different unit).
String creditEuros(String amount) {
  final negative = amount.startsWith('-');
  final digits = negative ? amount.substring(1) : amount;
  return '${negative ? '−' : ''}€$digits';
}

/// "+€1.00" / "−€2.00" for the history.
String signedCreditEuros(String amount) => amount.startsWith('-') ? creditEuros(amount) : '+${creditEuros(amount)}';

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
