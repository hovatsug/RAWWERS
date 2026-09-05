import 'package:decimal/decimal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_request_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/money/payout_request_money.dart';

part 'wallet_controller.g.dart';

/// Payout rules, mirrored from the backend so they can be enforced before a
/// request is sent rather than surfaced as a 422 afterwards.
///
/// These are duplicated from `api/app/services/payouts.py`, which is a real
/// (if small) coupling: if the server changes them this copy goes stale and
/// the UI will let through a request the server rejects. The server stays the
/// authority - a rejection is still handled - this only avoids making the
/// photographer discover the floor by hitting it.
abstract final class PayoutRules {
  /// MIN_PAYOUT_EUR in payouts.py.
  static final minimum = Decimal.parse('50.00');

  /// PAYOUT_REQUEST_LIMIT_7D in payouts.py.
  static const requestsPer7Days = 2;
}

/// Everything the Wallet screen needs, fetched together.
///
/// One provider rather than four: the screen is useless with a partial
/// answer - a balance with no payout history, or a withdrawable figure with
/// no account status - so a single loading and a single error state is a
/// truer model of it than four independently-failing panels.
class WalletData {
  const WalletData({
    required this.balance,
    required this.ledger,
    required this.payouts,
    required this.account,
  });

  final EarningsBalanceView balance;
  final List<EarningsLedgerItemView> ledger;
  final List<PayoutRequestView> payouts;
  final PayoutAccountView account;

  Decimal get withdrawable => Decimal.parse(balance.withdrawableEur);

  /// Payout requests inside the rolling 7-day window the backend counts.
  int get recentRequestCount {
    final since = DateTime.now().toUtc().subtract(const Duration(days: 7));
    return payouts.where((payout) => payout.createdAt.isAfter(since)).length;
  }

  /// Why a payout can't be requested right now, or null if it can.
  ///
  /// Checked in the same order the server checks, so the message a
  /// photographer sees is the reason the server would actually give.
  String? get payoutBlockedReason {
    if (recentRequestCount >= PayoutRules.requestsPer7Days) {
      return 'You\'ve made ${PayoutRules.requestsPer7Days} payout requests in the last 7 days. '
          'You can request again once one of them falls outside the window.';
    }
    if (withdrawable < PayoutRules.minimum) {
      return 'You need at least €${PayoutRules.minimum.toStringAsFixed(2)} available to request a payout. '
          'You have €${withdrawable.toStringAsFixed(2)}.';
    }
    return null;
  }
}

@riverpod
class WalletController extends _$WalletController {
  @override
  Future<WalletData> build() async {
    final client = ref.read(payoutsClientProvider);

    // Sequential rather than concurrent: the transport does single-flight
    // refresh on a 401 (see auth_interceptors.dart), and four parallel calls
    // on a stale token would all queue behind the same refresh anyway.
    final balance = await apiCall(
      () => client.getMyEarningsBalanceV1ProEarningsBalanceGet(authorization: null, xMinusUserMinusId: null),
    );
    if (balance case Err(:final failure)) throw failure;

    final ledger = await apiCall(
      () => client.getMyEarningsLedgerV1ProEarningsLedgerGet(
        sourceType: null,
        from: null,
        to: null,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (ledger case Err(:final failure)) throw failure;

    final payouts = await apiCall(
      () => client.getMyPayoutsV1ProPayoutsGet(authorization: null, xMinusUserMinusId: null),
    );
    if (payouts case Err(:final failure)) throw failure;

    final account = await apiCall(
      () => client.getMyPayoutAccountV1ProPayoutsAccountGet(authorization: null, xMinusUserMinusId: null),
    );
    if (account case Err(:final failure)) throw failure;

    return WalletData(
      balance: (balance as Ok<EarningsBalanceView>).value,
      ledger: (ledger as Ok).value.items,
      payouts: (payouts as Ok).value.items,
      account: (account as Ok<PayoutAccountView>).value,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Requests a payout of [amount]. Returns null on success, a message
  /// otherwise.
  Future<String?> requestPayout(Decimal amount) async {
    final client = ref.read(payoutsClientProvider);
    final result = await apiCall(
      () => client.requestMyPayoutV1ProPayoutsRequestPost(
        // Built through the money wrapper, never the raw generated
        // constructor - the generated amountEur is typed dynamic.
        requestBody: createPayoutRequest(amountEur: amount),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        return _payoutMessage(failure);
    }
  }
}

String _payoutMessage(ApiFailure failure) {
  if (failure is Validation) {
    for (final messages in failure.fieldErrors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return 'That payout request was rejected. Check the amount and try again.';
  }
  return switch (failure) {
    // Covers the server-side rules this client also checks up front, plus
    // frozen payouts - a risk action the client has no way to know about.
    BusinessError(:final message) => message,
    RateLimited() => 'You\'ve hit the payout request limit for this week.',
    NetworkError() => 'No connection - check your network and try again.',
    Timeout() => 'That took too long - try again.',
    _ => 'Something went wrong. Please try again.',
  };
}
