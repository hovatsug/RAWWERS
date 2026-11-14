import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/features/client/credit/credit_controller.dart';
import 'package:rawwers/api/models/grant_marketing_consent_request.dart';
import 'package:rawwers/api/models/marketing_consent_offer_response.dart';
import 'package:rawwers/api/models/marketing_consent_view.dart';
import 'package:rawwers/api/models/renew_marketing_consent_request.dart';
import 'package:rawwers/api/models/withdraw_marketing_consent_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'marketing_consent_controllers.g.dart';

String _explain(ApiFailure failure) => switch (failure) {
      NetworkError() || Timeout() => 'Could not reach RAWWERS. Check your connection and try again.',
      BusinessError(:final message) => message,
      _ => 'That did not go through. Try again.',
    };

/// What a grant did: null [problem] when it went through, with the RAW
/// credit it earned (0 when none: already credited for this booking, or the
/// month's limit reached).
typedef GrantOutcome = ({String? problem, String creditAmount, String currency});

/// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
/// server says whether to offer it, the wording, the terms and the photos.
@riverpod
class MarketingOfferController extends _$MarketingOfferController {
  @override
  Future<MarketingConsentOfferResponse> build(String gigId) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).getMarketingConsentOfferV1GigsGigIdMarketingConsentOfferGet(
            gigId: gigId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<GrantOutcome> grant({required List<String> assetIds, required int termMonths, required bool peopleConfirmed}) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).grantMarketingConsentV1GigsGigIdMarketingConsentPost(
            gigId: gigId,
            requestBody: GrantMarketingConsentRequest(
              mediaAssetIds: assetIds,
              termMonths: termMonths,
              peopleConfirmed: peopleConfirmed,
            ),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (result) {
      case Ok(:final value):
        ref.invalidateSelf();
        ref.invalidate(myMarketingConsentsControllerProvider);
        ref.invalidate(myCreditProvider);
        return (problem: null, creditAmount: value.creditAmount, currency: value.currency);
      case Err(:final failure):
        return (problem: _explain(failure), creditAmount: '0.00', currency: 'EUR');
    }
  }
}

/// Settings > Marketing permissions: every photo the client has given, with
/// its end date; withdraw one or all, renew one ending soon.
@riverpod
class MyMarketingConsentsController extends _$MyMarketingConsentsController {
  @override
  Future<List<MarketingConsentView>> build() async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).listMyMarketingConsentsV1MeMarketingConsentsGet(
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => value.items,
      Err(:final failure) => throw failure,
    };
  }

  /// [consentIds] null withdraws all. Null when done, otherwise the problem.
  Future<String?> withdraw(List<String>? consentIds) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).withdrawMyMarketingConsentsV1MeMarketingConsentsWithdrawPost(
            requestBody: WithdrawMarketingConsentRequest(consentIds: consentIds, all: consentIds == null),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    ref.invalidateSelf();
    return switch (result) {
      Ok() => null,
      Err(:final failure) => _explain(failure),
    };
  }

  Future<String?> renew(List<String> consentIds, {int termMonths = 12}) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).renewMyMarketingConsentsV1MeMarketingConsentsRenewPost(
            requestBody: RenewMarketingConsentRequest(consentIds: consentIds, termMonths: termMonths),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    ref.invalidateSelf();
    return switch (result) {
      Ok() => null,
      Err(:final failure) => _explain(failure),
    };
  }
}
