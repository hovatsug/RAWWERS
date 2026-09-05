import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:rawwers/api/models/pro_onboarding_checks_response.dart';
import 'package:rawwers/api/models/pro_onboarding_status_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'onboarding_controller.g.dart';

/// One requirement, as the checklist needs it.
@immutable
class OnboardingStep {
  const OnboardingStep({
    required this.key,
    required this.title,
    required this.detail,
    required this.done,
    this.route,
  });

  final String key;
  final String title;
  final String detail;
  final bool done;

  /// Where the pro goes to satisfy it. Null for steps with no screen of
  /// their own - identity checks are handled inline.
  final String? route;
}

/// Progress toward going live, read from the server every time.
///
/// Deliberately has no local notion of "which step am I on". The backend
/// already computes exactly that from real state, so a photographer who
/// gets halfway, closes the app for a week and comes back finds the
/// checklist where they left it - and a photographer who deletes six
/// portfolio photos sees the step reopen, which a stored step index would
/// never do.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  Future<ProOnboardingChecksResponse> build() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.getOnboardingChecksV1ProOnboardingChecksGet(
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
  }

  /// Tells the backend which stages are now satisfied.
  ///
  /// The checks endpoint computes readiness from live state, but the
  /// onboarding *status* only moves when a stage endpoint is called - and
  /// that status is what the admin panel shows. Without this, every
  /// photographer reads as "started" to whoever is approving them by hand,
  /// however far along they actually are.
  ///
  /// Called in transition order; a stage that is not yet eligible returns
  /// 422, which is an expected answer here rather than a failure.
  Future<void> syncStages() async {
    final checks = state.valueOrNull?.checks;
    if (checks == null) return;
    final client = ref.read(proOnboardingClientProvider);

    Future<void> advance(
      String key,
      Future<HttpResponse<ProOnboardingStatusResponse>> Function() call,
    ) async {
      if (checks[key] != true) return;
      // A 422 here means the backend does not consider the stage eligible
      // yet - an answer, not a failure, and not worth surfacing.
      await apiCall(call);
    }

    await advance('profile_completed',
        () => client.completeProfileOnboardingStageV1ProOnboardingCompleteProfilePost(
              authorization: null, xMinusUserMinusId: null));
    await advance('portfolio_uploaded',
        () => client.completePortfolioOnboardingStageV1ProOnboardingUploadPortfolioPost(
              authorization: null, xMinusUserMinusId: null));
    await advance('packages_configured',
        () => client.completePackagesOnboardingStageV1ProOnboardingConfigurePackagesPost(
              authorization: null, xMinusUserMinusId: null));
    await advance('niches_selected',
        () => client.completeNichesOnboardingStageV1ProOnboardingSelectNichesPost(
              authorization: null, xMinusUserMinusId: null));

    await refresh();
  }

  /// Starts the identity check. The backend moves KYC from unsubmitted to
  /// pending; a person reviews it from there.
  Future<String?> submitKyc() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.submitKycOnboardingStageV1ProOnboardingSubmitKycPost(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        // The profile carries kyc_status, which Settings and the listing
        // preview both read - refreshed here so they agree immediately.
        ref.invalidate(proProfileControllerProvider);
        await refresh();
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not start your identity check.',
        };
    }
  }

  /// Opens the listing to clients. Refused until KYC is approved, which is
  /// a person's decision, not a delay.
  Future<String?> goLive() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.activateProV1ProMeActivatePost(authorization: null, xMinusUserMinusId: null),
    );
    switch (result) {
      case Ok():
        ref.invalidate(proProfileControllerProvider);
        await refresh();
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not put your listing live.',
        };
    }
  }
}

/// `checks` is a free-form dict on the wire with no response schema, so
/// every read is defensive: a missing or oddly-typed key reads as "not
/// done" rather than throwing the whole screen away.
bool checkDone(Map<String, dynamic>? checks, String key) => checks?[key] == true;

int checkCount(Map<String, dynamic>? checks, String key, {int fallback = 0}) {
  final value = checks?[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}
