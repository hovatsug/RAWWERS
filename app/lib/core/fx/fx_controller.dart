import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/display_currency_update_request.dart';
import 'package:rawwers/api/models/display_currency_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/format/approx_money.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';

part 'fx_controller.g.dart';

/// The default display currency (docs/MULTI_CURRENCY.md 10.1): UK first. A
/// guest sees approximations in it; a signed-in user's own choice wins.
const defaultDisplayCurrency = 'GBP';

/// The day's display rates (GET /v1/fx/rates). On any failure: none, so
/// every approximation is dropped and "Charged in EUR" is shown instead.
/// Never used for money.
@Riverpod(keepAlive: true)
Future<FxRates> fxRates(Ref ref) async {
  final client = ref.read(fxClientProvider);
  final result = await apiCall(() => client.fxRatesV1FxRatesGet());
  return switch (result) {
    Ok(:final value) => FxRates(
        base: value.baseAA,
        rates: {for (final e in value.rates.entries) e.key: Decimal.parse("${e.value}")},
      ),
    Err() => FxRates.none,
  };
}

/// The signed-in user's display currency and what they may choose from
/// (Account > Display currency). Null for a guest.
@riverpod
class DisplayCurrency extends _$DisplayCurrency {
  @override
  Future<DisplayCurrencyView?> build() async {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    if (auth is! AuthAuthenticated) return null;
    final client = ref.read(fxClientProvider);
    final result = await apiCall(
      () => client.getDisplayCurrencyV1MeDisplayCurrencyGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Choose a currency, or null for the default. Returns an error message, or null.
  Future<String?> choose(String? currency) async {
    final client = ref.read(fxClientProvider);
    final result = await apiCall(
      () => client.putDisplayCurrencyV1MeDisplayCurrencyPut(
        requestBody: DisplayCurrencyUpdateRequest(displayCurrency: currency),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        return failure is BusinessError ? failure.message : 'Your display currency could not be saved.';
    }
  }
}

/// The currency approximations are shown in now.
@riverpod
String displayCurrencyCode(Ref ref) =>
    ref.watch(displayCurrencyProvider).valueOrNull?.displayCurrency ?? defaultDisplayCurrency;
