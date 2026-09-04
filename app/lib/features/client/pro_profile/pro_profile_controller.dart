import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/discover/discover_controller.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';

part 'pro_profile_controller.g.dart';

/// One photographer's public profile.
///
/// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
/// parameters and gates on them: the city rollout check runs before the
/// profile is loaded at all, so a profile is not reachable outside a city
/// we operate in. That means the browse location is a precondition here in
/// exactly the way it is for Discover, and a cleared location surfaces as
/// [LocationNotSet] rather than as a 403 the user cannot act on.
@riverpod
Future<ClientProProfileResponse> proProfile(Ref ref, String proUserId) async {
  final location = await ref.watch(locationControllerProvider.future);
  if (location == null) throw const LocationNotSet();

  final client = ref.read(clientLaunchClientProvider);
  final result = await apiCall(
    () => client.clientProProfileV1ClientProsProUserIdGet(
      proUserId: proUserId,
      country: location.country,
      city: location.city,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
