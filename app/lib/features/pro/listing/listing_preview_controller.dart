import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_listing_preview_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'listing_preview_controller.g.dart';

/// The pro's own listing, exactly as a client sees it.
///
/// The endpoint recomputes the discovery index before building the card,
/// and builds it with the same function that builds the Discover feed - so
/// this cannot drift from the real thing.
///
/// Watches the profile and package providers rather than only fetching
/// once: editing pricing has to visibly change the card, and that is only
/// true if changing a package invalidates this.
@riverpod
class ListingPreviewController extends _$ListingPreviewController {
  @override
  Future<ProListingPreviewResponse> build() async {
    ref.watch(proProfileControllerProvider);
    ref.watch(packagesControllerProvider);

    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.proListingPreviewV1ProMeListingPreviewGet(
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
}

/// Why the listing is not reachable in Discover, in words.
///
/// The API returns machine codes; a photographer needs the sentence and,
/// where there is one, somewhere to go and fix it.
({String text, String? route}) blockingReasonDisplay(
  String reason, {
  required String onboardingPath,
  required String pricingPath,
  required String profilePath,
}) =>
    switch (reason) {
      'kyc_not_approved' => (
          text: 'Your identity check has not been approved yet.',
          route: onboardingPath,
        ),
      'not_accepting_bookings' => (
          text: 'You have not put your listing live.',
          route: onboardingPath,
        ),
      'profile_incomplete' => (
          text: 'Your profile is not complete enough yet.',
          route: profilePath,
        ),
      'no_active_package' => (
          text: 'You have not priced anything yet.',
          route: pricingPath,
        ),
      // An unknown code is still worth showing: silence would leave the pro
      // staring at a card that is not live with nothing to explain it.
      _ => (text: reason.replaceAll('_', ' '), route: null),
    };
