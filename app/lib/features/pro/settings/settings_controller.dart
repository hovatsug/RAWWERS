import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/notification_preference_view.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/api_wrappers/notification_preference_update.dart';

part 'settings_controller.g.dart';

/// The pro profile, as Settings needs it: name, KYC state, whether the
/// listing is live.
@Riverpod(keepAlive: true)
class ProProfileController extends _$ProProfileController {
  @override
  Future<ProProfileView> build() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.getMyProProfileV1ProMeProfileGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Adopts a profile the server has already returned.
  ///
  /// Used after a save, so every screen watching this provider updates from
  /// the response that just succeeded rather than a refetch that might not.
  void replaceWith(ProProfileView profile) => state = AsyncData(profile);
}

/// Where payouts would land. Read-only here - entering bank details is
/// deferred (F-6), so this reports status rather than offering a form.
@riverpod
Future<PayoutAccountView> payoutAccount(Ref ref) async {
  final client = ref.read(payoutsClientProvider);
  final result = await apiCall(
    () => client.getMyPayoutAccountV1ProPayoutsAccountGet(authorization: null, xMinusUserMinusId: null),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

@riverpod
class NotificationPreferencesController extends _$NotificationPreferencesController {
  @override
  Future<NotificationPreferenceView> build() async {
    final client = ref.read(notificationsClientProvider);
    final result = await apiCall(
      () => client.getMyNotificationPreferencesV1MeNotificationPreferencesGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Toggles one channel.
  ///
  /// Built from the full current preferences via the wrapper, then copied
  /// with only the edited field: the endpoint overwrites every field it is
  /// given, so sending a body with just this toggle would wipe the
  /// timezone and quiet hours alongside it.
  Future<String?> setChannel({bool? email, bool? inApp}) async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final optimistic = current.copyWith(
      channelEmailEnabled: email ?? current.channelEmailEnabled,
      channelInappEnabled: inApp ?? current.channelInappEnabled,
    );
    state = AsyncData(optimistic);

    final client = ref.read(notificationsClientProvider);
    final result = await apiCall(
      () => client.putMyNotificationPreferencesV1MeNotificationPreferencesPut(
        requestBody: buildNotificationPreferenceUpdateRequest(optimistic),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        // Put the switch back where it was: a toggle that stays flipped
        // after a failed save tells the pro they are reachable when they
        // are not.
        state = AsyncData(current);
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not save that. Check your connection.',
          _ => 'Could not save that setting.',
        };
    }
  }
}
