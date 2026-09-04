import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_niche_pricing_preview_response.dart';
import 'package:rawwers/api/models/pro_package_create_request.dart';
import 'package:rawwers/api/models/pro_package_update_request.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'pricing_controller.g.dart';

/// The pro's own packages, one per niche they price.
@riverpod
class PackagesController extends _$PackagesController {
  @override
  Future<List<ProPackageView>> build() async {
    final me = switch (ref.watch(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };
    if (me == null) return const [];

    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.listProPackagesV1ProProUserIdPackagesGet(proUserId: me.userId),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<String?> createOrUpdate({
    String? packageId,
    required String nicheSlug,
    required String title,
    required String price,
    required int includedPhotos,
    required String extraPhotoPrice,
    required int durationMinutes,
    String? description,
  }) async {
    final client = ref.read(proOnboardingClientProvider);

    final result = packageId == null
        ? await apiCall(
            () => client.createPackageV1ProMePackagesPost(
              requestBody: ProPackageCreateRequest(
                title: title,
                nicheSlug: nicheSlug,
                description: description,
                durationMinutes: durationMinutes,
                // Money stays a string the whole way. The generated
                // parameter is `dynamic` because the schema accepts a
                // number or a string; sending the string is what keeps
                // 12.10 from becoming 12.099999999999999.
                price: price,
                includedPhotos: includedPhotos,
                extraPhotoPrice: extraPhotoPrice,
              ),
              authorization: null,
              xMinusUserMinusId: null,
            ),
          )
        : await apiCall(
            () => client.updatePackageV1ProMePackagesPackageIdPut(
              packageId: packageId,
              requestBody: ProPackageUpdateRequest(
                nicheSlug: nicheSlug,
                title: title,
                description: description,
                durationMinutes: durationMinutes,
                price: price,
                includedPhotos: includedPhotos,
                extraPhotoPrice: extraPhotoPrice,
              ),
              authorization: null,
              xMinusUserMinusId: null,
            ),
          );

    switch (result) {
      case Ok():
        ref.invalidateSelf();
        await future;
        // The listing card reads the discovery index, which the backend
        // recomputes on every package write - so the preview has to be
        // refetched or "editing pricing changes the card" is not true.
        ref.invalidate(proProfileControllerProvider);
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          // A price outside the platform's cap comes back as a specific
          // sentence naming the limit; replacing it with a generic message
          // would leave the pro guessing at a number.
          BusinessError(:final message) => message,
          Validation(:final fieldErrors) =>
            fieldErrors.values.firstOrNull?.firstOrNull ?? 'Some of that could not be saved.',
          _ => 'Could not save that package.',
        };
    }
  }

  Future<String?> disable(String packageId) async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.disablePackageV1ProMePackagesPackageIdDisablePost(
        packageId: packageId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        ref.invalidateSelf();
        await future;
        ref.invalidate(proProfileControllerProvider);
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not remove that package.',
        };
    }
  }
}

/// What a client would pay at 10/25/50/100/200 photos, for a price the pro
/// is still typing.
///
/// Keyed on (niche, price) so the curve recomputes as the number changes.
/// The public preview endpoint reads existing packages and 404s for a pro
/// pricing something for the first time; this one takes the proposed rate
/// as a parameter and reports the cap rather than enforcing it.
@riverpod
Future<ProNichePricingPreviewResponse> pricingPreview(
  Ref ref, {
  required String nicheId,
  required String entryPrice,
}) async {
  final client = ref.read(proOnboardingClientProvider);
  final result = await apiCall(
    () => client.getMyNichePricingPreviewV1ProMePricingNichesNicheIdGet(
      nicheId: nicheId,
      entryPrice: entryPrice,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
