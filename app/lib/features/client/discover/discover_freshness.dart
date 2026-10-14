import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_freshness.g.dart';

/// How old Discover's rows may be when the client comes back to them before
/// they are fetched again.
///
/// The "Available now" and "Online now" rows change by the minute - the
/// server works them out on every request - so rows a client fetched before
/// leaving the screen can show someone who has since switched off or closed
/// the app. Coming back to Discover fetches again, at most this often. The
/// ranked rows come from the server's cache, so a fetch is cheap.
const discoverStaleAfter = Duration(seconds: 15);

/// Counts the times Discover came back into view: the app resumed, the
/// Discover tab was selected, or a page above it (a profile, a niche) was
/// popped. The home and niche controllers listen and fetch again when what
/// they hold is older than [discoverStaleAfter].
@Riverpod(keepAlive: true)
class DiscoverReturns extends _$DiscoverReturns {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Tells [DiscoverReturns] when a page in the Discover branch is popped,
/// uncovering the one beneath.
///
/// Deferred: the router pops pages while the navigator is being rebuilt, and
/// a provider must not change during a build.
class DiscoverPopObserver extends NavigatorObserver {
  DiscoverPopObserver(this.onReturn);

  final VoidCallback onReturn;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => Future(onReturn);
}

/// For a controller holding Discover rows: fetch again when Discover comes
/// back into view and what is held is stale. Call from `build`.
void refetchWhenDiscoverReturns(
  Ref ref, {
  required DateTime fetchedAt,
  required void Function() refetch,
  DateTime Function() clock = DateTime.now,
}) {
  ref.listen(discoverReturnsProvider, (_, _) {
    if (clock().difference(fetchedAt) >= discoverStaleAfter) refetch();
  });
}
