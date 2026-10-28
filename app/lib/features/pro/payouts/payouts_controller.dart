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
/// The API returns requirement keys like `individual.dob.day`. Left raw
/// they read as a database schema; the point of showing them at all is
/// that they are actionable. Related keys share one label (the three parts
/// of a date of birth are one thing to fill in), and a key not listed here
/// gets a plain catch-all rather than its own name.
String requirementLabel(String key) {
  for (final (prefix, label) in _requirementLabels) {
    if (key == prefix || key.startsWith('$prefix.')) return label;
  }
  return _otherRequirement;
}

/// One row per thing to do, in the order Stripe first lists it: the keys
/// mapped to labels, then duplicates dropped. Stripe lists a key in both
/// currently_due and past_due once it is overdue, and splits one field
/// into several keys.
List<String> requirementRows(Iterable<String> keys) => {for (final key in keys) requirementLabel(key)}.toList();

const _otherRequirement = 'Other details in Stripe\'s form';

/// Most specific first: a key takes the first entry it starts with.
const _requirementLabels = [
  ('individual.first_name', 'Your name'),
  ('individual.last_name', 'Your name'),
  ('individual.full_name_aliases', 'Your name'),
  ('individual.dob', 'Your date of birth'),
  ('individual.address', 'Your home address'),
  ('individual.registered_address', 'Your home address'),
  ('individual.email', 'Your email address'),
  ('individual.phone', 'Your phone number'),
  ('individual.id_number', 'Your ID number'),
  ('individual.ssn_last_4', 'Your ID number'),
  ('individual.verification.additional_document', 'A second identity document'),
  ('individual.verification.document', 'A photo of your ID'),
  ('individual.verification.proof_of_liveness', 'A quick selfie check'),
  ('individual.political_exposure', 'A question about public office'),
  ('individual.nationality', 'Your nationality'),
  ('external_account', 'Your bank account'),
  ('business_profile.url', 'A website or social profile'),
  ('business_profile.product_description', 'A short description of your work'),
  ('business_profile.mcc', 'What kind of work you do'),
  ('business_profile.support_phone', 'A phone number clients can reach you on'),
  ('business_type', 'Whether you work as an individual or a company'),
  ('tos_acceptance', 'Accepting Stripe\'s terms'),
];
