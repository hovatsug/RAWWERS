import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/connect_status_response.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'payouts_controller.g.dart';

/// Where the money is, and whether it can leave.
@riverpod
class EarningsBalanceController extends _$EarningsBalanceController {
  @override
  Future<EarningsBalanceView> build() async {
    final client = ref.read(payoutsClientProvider);
    final result = await apiCall(
      () => client.getMyEarningsBalanceV1ProEarningsBalanceGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}

/// Stripe Connect onboarding state.
///
/// Read live from Stripe rather than from our stored status: the
/// account.updated webhook is what normally moves it, and a dropped event
/// would leave a photographer at "pending" forever with nothing to tell
/// them why. Opening this screen reconciles it.
@riverpod
class ConnectStatusController extends _$ConnectStatusController {
  @override
  Future<ConnectStatusResponse> build() async {
    final client = ref.read(payoutsClientProvider);
    final result = await apiCall(
      () => client.getMyConnectStatusV1ProPayoutsConnectStatusGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
    // Settings and the listing preview both read the payout status off the
    // profile; refreshed so they cannot disagree with this screen.
    ref.invalidate(payoutAccountProvider);
  }

  /// A fresh hosted-onboarding URL.
  ///
  /// Requested every time, never stored: Stripe account links expire within
  /// minutes and are consumed on first use, so a cached one is a link that
  /// has already stopped working. A photographer who comes back to this
  /// screen an hour later gets a new one rather than a dead page.
  Future<({String? url, String? error})> onboardingLink() async {
    final client = ref.read(payoutsClientProvider);
    final result = await apiCall(
      () => client.createMyConnectOnboardingLinkV1ProPayoutsConnectOnboardingLinkPost(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => (url: value.url, error: null),
      Err(:final failure) => (url: null, error: _explain(failure)),
    };
  }

  String _explain(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
        // The backend passes Stripe's own sentence through; it names the
        // actual problem far better than anything generic would.
        BusinessError(:final message) => message,
        ServerError(:final message) => message,
        _ => 'Could not start payout setup.',
      };
}

/// What Stripe is still waiting for, in words a photographer can act on.
///
/// The API returns requirement keys like `individual.id_number`. Left raw
/// they read as a database schema; the point of showing them at all is
/// that they are actionable.
String requirementLabel(String key) => switch (key) {
      'individual.id_number' => 'Your ID number',
      'individual.verification.document' => 'A photo of your ID',
      'individual.verification.additional_document' => 'A second document',
      'individual.address.line1' => 'Your address',
      'individual.dob.day' || 'individual.dob.month' || 'individual.dob.year' => 'Your date of birth',
      'external_account' => 'Your bank account',
      'business_profile.url' => 'A website or social profile',
      'business_profile.mcc' => 'What kind of work you do',
      'tos_acceptance.date' || 'tos_acceptance.ip' => 'Accepting Stripe\'s terms',
      _ => key.split('.').last.replaceAll('_', ' '),
    };
