import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/booking_marketing_settings_view.dart';
import 'package:rawwers/api/models/pro_marketing_agreement_view.dart';
import 'package:rawwers/api/models/update_booking_marketing_settings_request.dart';
import 'package:rawwers/api/models/update_pro_marketing_agreement_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'marketing_controllers.g.dart';

String _explain(ApiFailure failure) => switch (failure) {
      NetworkError() || Timeout() => 'Could not reach RAWWERS. Check your connection and try again.',
      BusinessError(:final message) => message,
      _ => 'That did not save. Try again.',
    };

/// The marketing clause of the photographer's agreement: an account-level
/// opt-in, off until they turn it on, recorded with the wording shown and
/// when. Turning it off stops new offers and withdraws nothing.
@riverpod
class MarketingAgreementController extends _$MarketingAgreementController {
  @override
  Future<ProMarketingAgreementView> build() async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).getMyMarketingAgreementV1ProMeMarketingAgreementGet(
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Null when saved, otherwise what to tell the photographer.
  Future<String?> set(bool optedIn) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).setMyMarketingAgreementV1ProMeMarketingAgreementPut(
            requestBody: UpdateProMarketingAgreementRequest(optedIn: optedIn),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        return _explain(failure);
    }
  }
}

/// One booking's "Allow marketing use" (the photographer's veto) and
/// "Includes children" (no consent is offered). Both fixed once the client
/// has given permission.
@riverpod
class BookingMarketingController extends _$BookingMarketingController {
  @override
  Future<BookingMarketingSettingsView> build(String gigId) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).getBookingMarketingSettingsV1ProGigsGigIdMarketingSettingsGet(
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

  Future<String?> set({bool? allowMarketing, bool? includesChildren}) async {
    final result = await apiCall(
      () => ref.read(marketingConsentClientProvider).setBookingMarketingSettingsV1ProGigsGigIdMarketingSettingsPut(
            gigId: gigId,
            requestBody: UpdateBookingMarketingSettingsRequest(
              allowMarketing: allowMarketing,
              includesChildren: includesChildren,
            ),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        // Locked meanwhile (the client has just said yes): show what is true.
        ref.invalidateSelf();
        return _explain(failure);
    }
  }
}
