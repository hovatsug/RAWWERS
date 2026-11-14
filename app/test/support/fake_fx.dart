import 'package:rawwers/api/models/display_currency_view.dart';
import 'package:rawwers/core/format/approx_money.dart';
import 'package:rawwers/core/fx/fx_controller.dart';

/// No display rates and no signed-in choice: widgets that show "about £…"
/// beside a price stay off the network in tests (docs/MULTI_CURRENCY.md M3).
final fxTestOverrides = [
  fxRatesProvider.overrideWith((ref) async => FxRates.none),
  displayCurrencyProvider.overrideWith(_NoChoice.new),
];

class _NoChoice extends DisplayCurrency {
  @override
  Future<DisplayCurrencyView?> build() async => null;
}
