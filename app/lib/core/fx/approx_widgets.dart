import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/approx_money.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/core/fx/fx_controller.dart';

/// "about £850" beside an exact price in another currency; "Charged in EUR"
/// when there is no rate; nothing when the price is in the display currency
/// (docs/MULTI_CURRENCY.md 2.4). Never on a line the client pays from.
class ApproxLine extends ConsumerWidget {
  const ApproxLine({required this.amount, required this.currency, this.style, super.key});

  /// The exact amount, a decimal string, in [currency].
  final String amount;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displayCurrencyCodeProvider);
    if (display == currency) return const SizedBox.shrink();
    final rates = ref.watch(fxRatesProvider).valueOrNull ?? FxRates.none;
    final text = approxOf(amount, currency, display, rates, RMoney.of(context)) ?? chargedIn(currency);
    return Text(text, style: style ?? Theme.of(context).textTheme.bodySmall);
  }
}

/// The line before paying (2.4): "You'll be charged €1,000.00 (EUR). About
/// £850 at today's rate. Your bank or card sets the final amount."; "Charged
/// in EUR" without a rate; nothing in the display currency.
class BeforePayingLine extends ConsumerWidget {
  const BeforePayingLine({required this.total, required this.currency, super.key});

  final String total;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displayCurrencyCodeProvider);
    final rates = ref.watch(fxRatesProvider).valueOrNull ?? FxRates.none;
    final text = beforePaying(total, currency, display, rates, RMoney.of(context));
    if (text == null) return const SizedBox.shrink();
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}

/// One line for a receipt, a booking's detail or a request sheet: "Charged
/// in EUR", when that is not the display currency.
class ChargedInLine extends ConsumerWidget {
  const ChargedInLine({required this.currency, super.key});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(displayCurrencyCodeProvider) == currency) return const SizedBox.shrink();
    return Text(chargedIn(currency), style: Theme.of(context).textTheme.bodySmall);
  }
}

/// Account > Display currency, for clients and photographers: which
/// currency approximations are shown in. Hidden while only one currency is
/// switched on (nothing to choose).
class DisplayCurrencyTile extends ConsumerWidget {
  const DisplayCurrencyTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(displayCurrencyProvider).valueOrNull;
    if (view == null || view.available.length < 2) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Display currency'),
      subtitle: Text('${view.displayCurrency} · prices in other currencies show an approximate amount'),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final code in view.available)
                ListTile(
                  title: Text('$code (${RMoney.symbolFor(code)})'),
                  trailing: code == view.displayCurrency ? const Icon(Icons.check) : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final error = await ref.read(displayCurrencyProvider.notifier).choose(code);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The booking request sheet's currency line (2.4).
class RequestCurrencyNote extends ConsumerWidget {
  const RequestCurrencyNote({required this.currency, super.key});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = requestCurrencyNote(currency, ref.watch(displayCurrencyCodeProvider));
    if (text == null) return const SizedBox.shrink();
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}
