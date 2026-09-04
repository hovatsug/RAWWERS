import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_profile_update_request.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'profile_editor_controller.g.dart';

/// Saves edits to the pro profile.
///
/// Writes through [ProProfileController] rather than holding a second copy:
/// Settings, the listing preview and this screen all read that provider, so
/// a save has to update the one everything watches or the card the pro just
/// changed keeps showing the old value.
@riverpod
class ProfileEditorController extends _$ProfileEditorController {
  @override
  Future<void> build() async {}

  /// Returns null on success, or a sentence to show the pro.
  ///
  /// Only sends fields that changed. The endpoint ignores nulls, so sending
  /// the whole form would be harmless today - but it would also overwrite
  /// anything a future field adds before this screen knows about it.
  Future<String?> save({
    required ProProfileView current,
    String? displayName,
    String? headline,
    String? bio,
    String? city,
    String? country,
    int? travelRadiusKm,
    List<String>? languages,
    List<String>? styles,
  }) async {
    state = const AsyncLoading();

    final request = ProProfileUpdateRequest(
      displayName: _changed(displayName, current.displayName),
      headline: _changed(headline, current.headline),
      bio: _changed(bio, current.bio),
      city: _changed(city, current.city),
      country: _changed(country, current.country),
      travelRadiusKm: travelRadiusKm == current.travelRadiusKm ? null : travelRadiusKm,
      languages: _listChanged(languages, current.languages),
      styles: _listChanged(styles, current.styles),
    );

    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.updateMyProProfileV1ProMeProfilePut(
        requestBody: request,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    switch (result) {
      case Ok(:final value):
        // Hand the saved profile straight to the shared provider so every
        // screen watching it updates without a refetch that could fail.
        ref.read(proProfileControllerProvider.notifier).replaceWith(value);
        state = const AsyncData(null);
        return null;
      case Err(:final failure):
        state = const AsyncData(null);
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not save. Check your connection and try again.',
          // The backend's own sentence: a cap or rule rejection says
          // something specific that a generic message would throw away.
          BusinessError(:final message) => message,
          Validation(:final fieldErrors) => fieldErrors.values.firstOrNull?.firstOrNull ?? 'Some of that could not be saved.',
          _ => 'Could not save your profile.',
        };
    }
  }

  String? _changed(String? next, String? current) {
    final trimmed = next?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed == current ? null : trimmed;
  }

  List<String>? _listChanged(List<String>? next, List<String>? current) {
    if (next == null) return null;
    final a = List<String>.from(next)..sort();
    final b = List<String>.from(current ?? const [])..sort();
    if (a.length == b.length && List.generate(a.length, (i) => a[i] == b[i]).every((x) => x)) {
      return null;
    }
    return next;
  }
}
