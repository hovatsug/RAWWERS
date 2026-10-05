import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_home_response.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';

part 'home_controller.g.dart';

/// What the home screen is showing.
///
/// "We do not know where you are" and "nobody is here" are different facts
/// and must not collapse into one empty list. Rendering the second when the
/// truth is the first tells a client this city has no photographers when no
/// city was ever chosen - the same class of dishonesty as a count that
/// reports zero because the request failed.
sealed class HomeState {
  const HomeState();
}

/// No browsing city has been chosen yet, so nothing has been asked of the
/// server. The screen prompts for one rather than reporting an absence it
/// cannot know about.
class HomeNeedsLocation extends HomeState {
  const HomeNeedsLocation();
}

class HomeRows extends HomeState {
  const HomeRows(this.rows);
  final List<ClientHomeRow> rows;
}

/// The browsing home screen.
///
/// Rows arrive composed by the server, titles included. That is deliberate
/// and not laziness: what belongs in a row is a fairness rule - what counts
/// as "new", why a row is absent rather than empty, and the prohibition on
/// quietly boosting newcomers into a row named for experience - and a rule
/// implemented in two places drifts. This app renders what it is given and
/// decides none of it.
///
/// The practical consequence is that this controller is almost empty, which
/// is the point. Any logic here would be a second opinion about fairness.
@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeState> build() async {
    final location = await ref.watch(locationControllerProvider.future);
    if (location == null) return const HomeNeedsLocation();

    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.clientHomeV1ClientHomeGet(
        country: location.country,
        city: location.city,
        nicheSlug: null,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    return switch (result) {
      Ok(:final ClientHomeResponse value) => HomeRows(value.rows ?? const []),
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
