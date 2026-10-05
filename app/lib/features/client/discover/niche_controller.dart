import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_home_niche.dart';
import 'package:rawwers/api/models/client_home_response.dart';
import 'package:rawwers/api/models/client_home_row.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';

part 'niche_controller.g.dart';

/// What a niche's page is showing.
///
/// Four facts that must not collapse into one another: no city chosen, no
/// such niche, a real niche nobody here works in, and the page itself. The
/// last two are both [NichePage] - an empty one is an honest absence, and the
/// niche still has a name to say it with.
sealed class NicheState {
  const NicheState();
}

class NicheNeedsLocation extends NicheState {
  const NicheNeedsLocation();
}

/// The slug names no niche - a stale or mistyped link. Not an error to retry,
/// and not an empty niche: retrying would get the same answer, and "nobody
/// here yet" would claim a category exists that does not.
class NicheNotFound extends NicheState {
  const NicheNotFound();
}

class NichePage extends NicheState {
  const NichePage({required this.niche, required this.rows});

  final ClientHomeNiche niche;
  final List<ClientHomeRow> rows;
}

/// One niche's page: the home screen's rows, narrowed by the server.
///
/// The same request as the home screen with one more parameter, and the same
/// division of labour - which rows exist, who is in them, what they are called
/// and whether an empty one is sent at all are all decided server-side. This
/// controller asks and reports; it holds no opinion about fairness.
@riverpod
class NicheController extends _$NicheController {
  @override
  Future<NicheState> build(String nicheSlug) async {
    final location = await ref.watch(locationControllerProvider.future);
    if (location == null) return const NicheNeedsLocation();

    final client = ref.read(clientLaunchClientProvider);
    final result = await apiCall(
      () => client.clientHomeV1ClientHomeGet(
        country: location.country,
        city: location.city,
        nicheSlug: nicheSlug,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    return switch (result) {
      Ok(:final ClientHomeResponse value) => switch (value.niche) {
          final niche? => NichePage(niche: niche, rows: value.rows ?? const []),
          // Asked for a niche and got the home screen back: the server did
          // not honour the request, and showing its rows under this niche's
          // name would be showing the wrong page.
          null => throw const ServerError('The niche page came back without its niche'),
        },
      Err(failure: NotFound()) => const NicheNotFound(),
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
