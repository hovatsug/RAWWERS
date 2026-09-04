import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/core/api_wrappers/client_preference_update.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'location_controller.g.dart';

/// Where the client is browsing.
///
/// `GET /v1/client/discover` requires `country` and `city` — there is no
/// "everywhere" mode — so nothing in the client app renders until this is
/// known. It is stored server-side on the client preference rather than
/// locally, so it survives a reinstall and matches on both apps.
class BrowseLocation {
  const BrowseLocation({required this.country, required this.city});

  final String country;
  final String city;

  /// The preference's `location` is a free-form JSON object with no schema
  /// (`additionalProperties: true`), so these keys are a convention shared
  /// with the backend's own seed data (`{"country": "US", "city": "New
  /// York"}`) rather than anything the API enforces. Reading defensively
  /// because nothing stops another writer putting something else there.
  static BrowseLocation? fromPreferenceLocation(Map<String, dynamic>? location) {
    final country = location?['country'];
    final city = location?['city'];
    if (country is! String || city is! String) return null;
    if (country.isEmpty || city.isEmpty) return null;
    return BrowseLocation(country: country, city: city);
  }

  Map<String, dynamic> toPreferenceLocation() => {'country': country, 'city': city};
}

/// The stored browse location, or null if the client hasn't set one.
@Riverpod(keepAlive: true)
class LocationController extends _$LocationController {
  @override
  Future<BrowseLocation?> build() async {
    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.getClientPreferenceV1MeClientPreferenceGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => BrowseLocation.fromPreferenceLocation(value.location),
      // A missing preference is "not set yet", not an error worth blocking
      // the whole app on - the user is about to be asked anyway.
      Err() => null,
    };
  }

  /// Persists the location onto the client preference.
  ///
  /// Sends the whole preference back, not just `location`: the endpoint is a
  /// PUT over the full record, so omitting the other fields would wipe the
  /// client's niches, budget and consent default.
  Future<String?> setLocation(BrowseLocation location) async {
    final client = ref.read(clientLaunchClientProvider);

    final current = await apiCall(
      () => client.getClientPreferenceV1MeClientPreferenceGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (current case Err()) {
      return 'Could not save your location. Check your connection and try again.';
    }
    final existing = (current as Ok).value;

    final result = await apiCall(
      () => client.putClientPreferenceV1MeClientPreferencePut(
        // Full-state wrapper, not a hand-built request: this PUT overwrites
        // every field, so constructing it by hand risks wiping the client's
        // niches and budget the next time someone adds a preference field.
        requestBody: buildClientPreferenceUpdateRequest(existing)
            .copyWith(location: location.toPreferenceLocation()),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        state = AsyncData(location);
        return null;
      case Err():
        return 'Could not save your location. Check your connection and try again.';
    }
  }
}
