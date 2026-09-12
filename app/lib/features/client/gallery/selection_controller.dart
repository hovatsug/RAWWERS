import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/api/models/save_selection_request.dart';
import 'package:rawwers/api/models/selection_quote_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'selection_controller.g.dart';

/// What the selection screen shows, in one place.
///
/// The grid and the full-screen viewer are two views onto this single object
/// rather than two screens each tracking their own idea of what is chosen.
/// That is the whole reason it exists: a photo ticked full screen and then
/// seen unticked in the grid is the kind of bug that makes someone distrust
/// the entire basket, and no amount of care in two implementations prevents
/// it as reliably as not having two.
class SelectionState {
  const SelectionState({
    required this.gallery,
    required this.selectedIds,
    this.quote,
    this.quoteStale = false,
    this.quoteFailed = false,
    this.locked = false,
  });

  final GalleryDetailResponse gallery;

  /// Ordered by the gallery's own order, not by when each was tapped, so the
  /// count and the grid always agree.
  final Set<String> selectedIds;

  /// Server-computed, always. Null only before the first one arrives.
  ///
  /// Never recomputed locally while a new one is in flight: the curve, the
  /// deposit already paid and the clamp at zero are backend rules, and an app
  /// that approximates them will eventually show a number the client is not
  /// charged. A stale-but-true total beats a fresh guess.
  final SelectionQuoteResponse? quote;

  /// A newer quote is on the way and [quote] describes an older count.
  final bool quoteStale;

  /// The last quote request failed. The total is hidden rather than guessed.
  final bool quoteFailed;

  /// The gallery is no longer open for selection - already submitted, or
  /// waiting on a payment. Tapping must not appear to work.
  final bool locked;

  List<GalleryItemView> get items => gallery.items;

  int get selectedCount => selectedIds.length;

  bool isSelected(String assetId) => selectedIds.contains(assetId);

  SelectionState copyWith({
    Set<String>? selectedIds,
    SelectionQuoteResponse? quote,
    bool? quoteStale,
    bool? quoteFailed,
    bool? locked,
  }) {
    return SelectionState(
      gallery: gallery,
      selectedIds: selectedIds ?? this.selectedIds,
      quote: quote ?? this.quote,
      quoteStale: quoteStale ?? this.quoteStale,
      quoteFailed: quoteFailed ?? this.quoteFailed,
      locked: locked ?? this.locked,
    );
  }
}

/// Choosing photographs, and being told what it costs.
///
/// Tapping is answered locally and immediately - a tick that waits on a round
/// trip feels broken - but every number on screen comes from the server. The
/// two are reconciled by debouncing: taps update the set at once, and a quote
/// is requested once the tapping stops. Until it lands the previous total is
/// shown marked as stale rather than replaced by a local estimate, so the
/// figure never jumps to something invented and then corrects itself.
@riverpod
class SelectionController extends _$SelectionController {
  Timer? _debounce;
  int _inFlight = 0;

  /// Long enough to swallow a run of taps, short enough that a decision does
  /// not sit in front of an out-of-date price.
  static const quoteDebounce = Duration(milliseconds: 350);

  @override
  Future<SelectionState> build(String galleryId) async {
    ref.onDispose(() => _debounce?.cancel());

    final galleries = ref.read(proofGalleriesClientProvider);
    final detail = switch (await apiCall(
      () => galleries.getGalleryV1ProofGalleriesGalleryIdGet(
        galleryId: galleryId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    final status = detail.gallery.status.name;
    final locked = status != 'published';

    final state = SelectionState(
      gallery: detail,
      selectedIds: const {},
      locked: locked,
    );

    // The opening total, so the screen never renders a blank where money goes.
    final quote = await _fetchQuote(galleryId, 0);
    return state.copyWith(quote: quote, quoteFailed: quote == null);
  }

  Future<SelectionQuoteResponse?> _fetchQuote(String galleryId, int count) async {
    final galleries = ref.read(proofGalleriesClientProvider);
    final result = await apiCall(
      () => galleries.getSelectionQuoteV1ProofGalleriesGalleryIdSelectionQuoteGet(
        galleryId: galleryId,
        selectedCount: count,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  /// Tick or untick one photo. Answered locally; the price follows.
  void toggle(String assetId) {
    final current = state.valueOrNull;
    if (current == null || current.locked) return;

    final next = Set<String>.from(current.selectedIds);
    if (!next.remove(assetId)) next.add(assetId);

    state = AsyncData(current.copyWith(selectedIds: next, quoteStale: true, quoteFailed: false));
    _scheduleQuote(next.length);
  }

  void _scheduleQuote(int count) {
    _debounce?.cancel();
    _debounce = Timer(quoteDebounce, () => refreshQuote(count));
  }

  /// Ask the server what this many photos costs.
  ///
  /// Late replies are dropped. Without that, a slow quote for 11 photos
  /// arriving after a fast one for 14 would overwrite the correct total with
  /// an older, cheaper one - and the client would be looking at a price that
  /// no longer matches what they have chosen.
  Future<void> refreshQuote(int count) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final ticket = ++_inFlight;
    final quote = await _fetchQuote(galleryId, count);
    if (ticket != _inFlight) return;

    final latest = state.valueOrNull;
    if (latest == null) return;
    if (quote == null) {
      state = AsyncData(latest.copyWith(quoteStale: false, quoteFailed: true));
      return;
    }
    state = AsyncData(latest.copyWith(quote: quote, quoteStale: false, quoteFailed: false));
  }

  /// Persist the chosen photos without submitting them.
  Future<ApiFailure?> save() async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final galleries = ref.read(proofGalleriesClientProvider);
    final result = await apiCall(
      () => galleries.saveSelectionV1ProofGalleriesGalleryIdSelectionsPost(
        galleryId: galleryId,
        requestBody: SaveSelectionRequest(mediaAssetIds: current.selectedIds.toList()),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok() => null,
      Err(:final failure) => failure,
    };
  }
}
