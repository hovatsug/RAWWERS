import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

/// Every amount of money the pro app shows, in one place.
///
/// The device's locale decides how the number is written: an English phone
/// reads "€1,350.00", a Portuguese one "1 350,00 €". The currency is the
/// server's - the `currency` a response carries - and only where a response
/// sends none (the balance, earnings and payout fields, which are named for
/// EUR: `withdrawable_eur`) does it fall back to [fallbackCurrency]. See
/// docs/BACKEND_GAPS.md.
///
/// Amounts arrive as decimal strings and stay strings: nothing here goes
/// through a double. A fraction is shown as sent ("12.00" keeps its cents,
/// "1000" has none).
class RMoney {
  const RMoney._({required this.decimalMark, required this.groupMark, required this.symbolAfter});

  /// The conventions for [locale]: Portuguese writes "1 350,00 €";
  /// everyone else, English first among them, "€1,350.00".
  factory RMoney.forLocale(Locale locale) {
    final pt = locale.languageCode == 'pt';
    return RMoney._(decimalMark: pt ? ',' : '.', groupMark: pt ? _nbsp : ',', symbolAfter: pt);
  }

  /// The conventions of the device this runs on.
  static RMoney of(BuildContext context) => RMoney.forLocale(View.of(context).platformDispatcher.locale);

  /// The same, for code with no BuildContext (a controller's message).
  static RMoney ofDevice() => RMoney.forLocale(WidgetsBinding.instance.platformDispatcher.locale);

  /// For responses that carry no currency. The one place EUR is assumed.
  static const fallbackCurrency = 'EUR';

  /// A no-break space, so "1 350,00 €" never wraps inside the number.
  static const _nbsp = ' ';

  final String decimalMark;
  final String groupMark;
  final bool symbolAfter;

  /// "€", "£", "$" - or the code itself for a currency without a symbol
  /// here, so an unfamiliar one is named rather than mislabelled.
  static String symbolFor(String? currency) => switch ((currency ?? fallbackCurrency).toUpperCase()) {
        'EUR' => '€',
        'GBP' => '£',
        'USD' => r'$',
        final code => code,
      };

  /// [amount] in [currency] (EUR when the response sent none).
  /// "-462.00" reads "-€462.00".
  String format(String amount, {String? currency}) {
    final symbol = symbolFor(currency);
    final parsed = Decimal.tryParse(amount.trim());
    if (parsed == null) return _place(symbol, amount.trim());
    final negative = parsed < Decimal.zero;
    final digits = amount.trim().replaceFirst(RegExp(r'^[-+]'), '');
    final [whole, ...fraction] = digits.split('.');
    final grouped = _group(whole);
    final number = fraction.isEmpty ? grouped : '$grouped$decimalMark${fraction.first}';
    return '${negative ? '-' : ''}${_place(symbol, number)}';
  }

  /// The same amount, taken off: a fee, a credit given away.
  /// (Nothing taken off stays "€0.00": minus zero is not below zero.)
  String minus(String amount, {String? currency}) {
    final trimmed = amount.trim();
    return format(trimmed.startsWith('-') ? trimmed : '-$trimmed', currency: currency);
  }

  String _place(String symbol, String number) {
    final spaced = symbol.length > 1; // a code, not a symbol: "CHF 12.00"
    if (symbolAfter) return '$number$_nbsp$symbol';
    return spaced ? '$symbol$_nbsp$number' : '$symbol$number';
  }

  String _group(String whole) {
    final out = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) out.write(groupMark);
      out.write(whole[i]);
    }
    return out.toString();
  }
}
