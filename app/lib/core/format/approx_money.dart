import 'package:decimal/decimal.dart';
import 'package:rawwers/core/format/money.dart';

/// The day's display rates, as the server sends them (GET /v1/fx/rates):
/// units of each currency per one euro, only when at most four days old.
/// Never used for money: they make the "about" beside an amount, nothing
/// else (docs/MULTI_CURRENCY.md 2.4, 4.1, 4.3).
class FxRates {
  const FxRates({required this.base, required this.rates});

  /// No usable rate: every approximation is dropped.
  static const none = FxRates(base: 'EUR', rates: {});

  final String base;
  final Map<String, Decimal> rates;

  /// Units of [currency] per euro, or null.
  Decimal? perEuro(String currency) => currency == base ? Decimal.one : rates[currency];
}

/// [amount] (a decimal string in [from]) as minor units of [to], rounded
/// half up once, at full precision before that; null when no rate is known.
/// Only conversions to or from the euro exist, as on the server.
int? approxMinor(String amount, String from, String to, FxRates rates) {
  final value = Decimal.tryParse(amount.trim());
  if (value == null) return null;
  final minor = (value * Decimal.fromInt(100)).round();
  if (from == to) return minor.toBigInt().toInt();
  final Decimal converted;
  if (from == rates.base) {
    final rate = rates.perEuro(to);
    if (rate == null) return null;
    converted = minor * rate;
  } else if (to == rates.base) {
    final rate = rates.perEuro(from);
    if (rate == null || rate == Decimal.zero) return null;
    converted = (minor / rate).toDecimal(scaleOnInfinitePrecision: 12);
  } else {
    return null;
  }
  return _halfUp(converted);
}

int _halfUp(Decimal value) {
  // Decimal.round() rounds half away from zero; amounts are never negative
  // here, so that is half up.
  return value.round().toBigInt().toInt();
}

/// "about £851" for 85123 pence; "about £10.50" below £20. Shown to the
/// whole unit from 20.00 up, to the minor unit below (4.3).
String approxText(int minor, String currency, RMoney money) {
  if (minor >= 2000) {
    final whole = (Decimal.fromInt(minor) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 4).round();
    return 'about ${money.format(whole.toString(), currency: currency)}';
  }
  final pounds = minor ~/ 100;
  final pence = (minor % 100).toString().padLeft(2, '0');
  return 'about ${money.format('$pounds.$pence', currency: currency)}';
}

/// The approximation of [amount] (in [currency]) in [display], or null when
/// there is none to show: the same currency, or no rate.
String? approxOf(String amount, String currency, String display, FxRates rates, RMoney money) {
  if (currency == display) return null;
  final minor = approxMinor(amount, currency, display, rates);
  if (minor == null) return null;
  return approxText(minor, display, money);
}

/// The short label beside a price: "about £850 · charged in €1,000.00".
/// Without a rate: "Charged in EUR". The same currency: null.
String? shortLabel(String amount, String currency, String display, FxRates rates, RMoney money) {
  if (currency == display) return null;
  final approx = approxOf(amount, currency, display, rates, money);
  if (approx == null) return chargedIn(currency);
  return '$approx · charged in ${money.format(amount, currency: currency)}';
}

/// Before paying (2.4): "You'll be charged €1,000.00 (EUR). About £850 at
/// today's rate. Your bank or card sets the final amount." Without a rate:
/// "Charged in EUR". The same currency: null.
String? beforePaying(String total, String currency, String display, FxRates rates, RMoney money) {
  if (currency == display) return null;
  final approx = approxOf(total, currency, display, rates, money);
  if (approx == null) return chargedIn(currency);
  final about = 'A${approx.substring(1)}';
  return "You'll be charged ${money.format(total, currency: currency)} ($currency). "
      '$about at today\'s rate. Your bank or card sets the final amount.';
}

/// The one line on a receipt, a history entry or a request sheet.
String chargedIn(String currency) => 'Charged in $currency';

const _names = {'EUR': 'euros', 'GBP': 'pounds'};

/// The booking request sheet's line (2.4), when the package is not in the
/// display currency: "You'll be charged in euros (EUR). Your bank sets the
/// final amount in pounds."
String? requestCurrencyNote(String currency, String display) {
  if (currency == display) return null;
  return "You'll be charged in ${_names[currency] ?? currency} ($currency). "
      'Your bank sets the final amount in ${_names[display] ?? display}.';
}
