import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_discover_card.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/offset_page.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';

part 'discover_controller.g.dart';

/// Free-text search and niche filter for Discover.
///
/// Held separately from the results provider so typing doesn't rebuild the
/// list on every keystroke - the search screen commits the query on submit.
class DiscoverFilters {
  const DiscoverFilters({this.query, this.nicheSlug});

  final String? query;
  final String? nicheSlug;

  DiscoverFilters copyWith({String? query, String? nicheSlug, bool clearNiche = false}) {
    return DiscoverFilters(
      query: query ?? this.query,
      nicheSlug: clearNiche ? null : (nicheSlug ?? this.nicheSlug),
    );
  }
}

@riverpod
class DiscoverFiltersController extends _$DiscoverFiltersController {
  @override
  DiscoverFilters build() => const DiscoverFilters();

  void setQuery(String? query) {
    state = state.copyWith(query: (query == null || query.trim().isEmpty) ? null : query.trim());
  }

  void setNiche(String? slug) {
    state = slug == null ? state.copyWith(clearNiche: true) : state.copyWith(nicheSlug: slug);
  }
}

/// Thrown when Discover is asked to load with no browse location set.
///
/// `GET /v1/client/discover` requires country and city, so this is a real
/// state rather than an error - the screen shows a location prompt instead
/// of a failure.
class LocationNotSet implements Exception {
  const LocationNotSet();
}

@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  Future<OffsetPage<ClientDiscoverCard>> build() async {
    // Watched: changing either the location or the filters restarts the list
    // from offset 0, which is correct - an offset into the Lisbon results
    // means nothing against the Porto ones.
    final location = await ref.watch(locationControllerProvider.future);
    if (location == null) throw const LocationNotSet();
    ref.watch(discoverFiltersControllerProvider);

    final result = await _fetch(offset: 0);
    return switch (result) {
      Ok(:final value) => OffsetPage(items: value.items, total: value.total),
      Err(:final failure) => throw failure,
    };
  }

  Future<Result<OffsetFetchResult<ClientDiscoverCard>>> _fetch({required int offset}) async {
    final location = await ref.read(locationControllerProvider.future);
    // Unreachable in practice: build() checks first, and loadMore() only runs
    // once a page exists, which required a location. Surfaced as a failure
    // rather than asserted so a cleared location mid-scroll degrades to a
    // retryable message instead of crashing the tab.
    if (location == null) return const Err(NetworkError());
    final filters = ref.read(discoverFiltersControllerProvider);
    final client = ref.read(clientLaunchClientProvider);

    final result = await apiCall(
      () => client.clientDiscoverV1ClientDiscoverGet(
        country: location.country,
        city: location.city,
        nicheSlug: filters.nicheSlug,
        q: filters.query,
        // Price filters are typed `double?` by the generator. Deliberately
        // left null rather than exposed: these are money, and a double-typed
        // filter is the one place a cent could drift into a query. A price
        // filter belongs behind the Decimal wrappers if it's added later.
        minPrice: null,
        maxPrice: null,
        offset: offset,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => Ok(OffsetFetchResult(items: value.items ?? const [], total: value.total)),
      Err(:final failure) => Err(failure),
    };
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    state = AsyncData(await appendNextOffsetPage(current, (offset) => _fetch(offset: offset)));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
