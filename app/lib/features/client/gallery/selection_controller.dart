import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gallery_item_view.dart';
import 'package:rawwers/api/models/save_selection_request.dart';
import 'package:rawwers/api/models/selection_quote_response.dart';
import 'package:rawwers/api/models/submit_selection_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';

part 'selection_controller.g.dart';

/// Where confirming a selection has got to.
///
/// Confirming is three server steps - save, submit, pay - and only the first
/// two are safely repeatable. Once submit has succeeded the server has fixed
/// the price and created the charge; the only thing left to retry is the
/// payment sheet, against the same intent. Modelling that as a phase rather
/// than a flag is what stops a retry from re-saving a selection and quietly
/// changing what the held charge is for.
sealed class ConfirmPhase {
  const ConfirmPhase();
}

/// Nothing submitted yet. The selection can still change.
final class ConfirmIdle extends ConfirmPhase {
  const ConfirmIdle();
}

/// Submitted, and the server is waiting on a payment. The selection is
/// frozen: it is what the charge below was computed from.
final class ConfirmAwaitingPayment extends ConfirmPhase {
  const ConfirmAwaitingPayment({required this.clientSecret, required this.amount, required this.currency});

  final String clientSecret;

  /// What the server says is owed, as the decimal string it sent.
  final String? amount;
  final String currency;
}

/// Confirmed, and paid if anything was owed.
final class ConfirmDone extends ConfirmPhase {
  const ConfirmDone({required this.paid});

  /// True when a payment sheet completed. Completion is recorded by the
  /// backend on a webhook, so the screen this returns to may take a moment
  /// to catch up.
  final bool paid;
}

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
    this.phase = const ConfirmIdle(),
    this.busy = false,
    this.confirmError,
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

  final ConfirmPhase phase;

  /// A save, submit or payment sheet is in flight.
  final bool busy;

  /// Why the last attempt to confirm did not finish. Cleared by the next one.
  final String? confirmError;

  /// Nothing may be ticked. Wider than [locked], which only knows what the
  /// server has already recorded: a submitted selection awaiting payment
  /// still reads as `published` there, and must not be editable meanwhile.
  bool get frozen => locked || busy || phase is! ConfirmIdle;

  /// Whether the confirm button should do anything.
  ///
  /// A stale or missing quote blocks it: the button and its dialog state the
  /// amount being committed to, and an out-of-date figure there is the same
  /// mistake as an out-of-date total, made at the moment it costs the most.
  bool get canConfirm {
    if (busy || phase is ConfirmDone) return false;
    if (phase is ConfirmAwaitingPayment) return true;
    final current = quote;
    return !locked && current != null && current.canSubmit && !quoteStale && !quoteFailed;
  }

  List<GalleryItemView> get items => gallery.items;

  int get selectedCount => selectedIds.length;

  bool isSelected(String assetId) => selectedIds.contains(assetId);

  SelectionState copyWith({
    Set<String>? selectedIds,
    SelectionQuoteResponse? quote,
    bool? quoteStale,
    bool? quoteFailed,
    bool? locked,
    ConfirmPhase? phase,
    bool? busy,
    String? confirmError,
    bool clearConfirmError = false,
  }) {
    return SelectionState(
      gallery: gallery,
      selectedIds: selectedIds ?? this.selectedIds,
      quote: quote ?? this.quote,
      quoteStale: quoteStale ?? this.quoteStale,
      quoteFailed: quoteFailed ?? this.quoteFailed,
      locked: locked ?? this.locked,
      phase: phase ?? this.phase,
      busy: busy ?? this.busy,
      confirmError: clearConfirmError ? null : (confirmError ?? this.confirmError),
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
    if (current == null || current.frozen) return;

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

  /// Locks the selection in and takes whatever payment it owes.
  ///
  /// save, then submit, then - only if the server returned a charge - the
  /// payment sheet. Every amount involved is the server's: the button and the
  /// dialog quote `amount_due`, submit recomputes it, and the sheet shows the
  /// intent's own figure.
  ///
  /// A failure before submit leaves the selection exactly as it was, so
  /// another tap simply tries again. A failure after submit does not repeat
  /// the first two steps: the charge already exists and is for this
  /// selection, so retry reopens the sheet against the same intent.
  Future<ConfirmOutcome> confirm({required String bookingId}) async {
    final current = state.valueOrNull;
    if (current == null || !current.canConfirm) return const ConfirmIgnored();

    final phase = current.phase;
    if (phase is ConfirmAwaitingPayment) return _pay(bookingId, phase);

    state = AsyncData(current.copyWith(busy: true, clearConfirmError: true));

    final saveFailure = await save();
    if (saveFailure != null) return _stayOnScreen(_confirmMessage(saveFailure));

    final submitted = await _submit();
    switch (submitted) {
      case Err(:final failure):
        return _stayOnScreen(_confirmMessage(failure));
      case Ok(:final value):
        // Difference first: a curve-priced gig only ever has one, and a flat
        // one only ever has an upsell, so this is a choice between two
        // spellings of "the charge", never two charges.
        final secret = value.differencePaymentIntentClientSecret ?? value.paymentIntentClientSecret;
        if (secret == null || secret.isEmpty) return _finish(bookingId, paid: false);

        final awaiting = ConfirmAwaitingPayment(
          clientSecret: secret,
          amount: value.differenceAmount ?? state.valueOrNull?.quote?.amountDue,
          currency: state.valueOrNull?.quote?.currency ?? 'EUR',
        );
        return _pay(bookingId, awaiting);
    }
  }

  Future<Result<SubmitSelectionResponse>> _submit() {
    final galleries = ref.read(proofGalleriesClientProvider);
    return apiCall(
      () => galleries.submitSelectionV1ProofGalleriesGalleryIdSelectionsSubmitPost(
        galleryId: galleryId,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
  }

  Future<ConfirmOutcome> _pay(String bookingId, ConfirmAwaitingPayment awaiting) async {
    final latest = state.valueOrNull;
    if (latest == null) return const ConfirmIgnored();
    state = AsyncData(latest.copyWith(phase: awaiting, busy: true, clearConfirmError: true));

    // The payment controller is auto-dispose and nothing else watches it
    // here, so hold it open for the length of the sheet.
    final subscription = ref.listen(bookingPaymentControllerProvider(bookingId), (_, _) {});
    try {
      await ref.read(bookingPaymentControllerProvider(bookingId).notifier).presentFor(awaiting.clientSecret);
      final progress = ref.read(bookingPaymentControllerProvider(bookingId));

      final after = state.valueOrNull;
      if (after == null) return const ConfirmIgnored();

      switch (progress) {
        case PaymentSucceeded():
          return _finish(bookingId, paid: true);
        case PaymentFailed(:final message):
          state = AsyncData(after.copyWith(busy: false, confirmError: message));
          return ConfirmFailed(message);
        default:
          // Cancelled: still owed, still frozen, nothing to apologise for.
          state = AsyncData(after.copyWith(busy: false));
          return const ConfirmPending();
      }
    } finally {
      subscription.close();
    }
  }

  ConfirmOutcome _finish(String bookingId, {required bool paid}) {
    final after = state.valueOrNull;
    if (after != null) {
      state = AsyncData(after.copyWith(phase: ConfirmDone(paid: paid), busy: false, clearConfirmError: true));
    }
    // The paid path is refreshed by the payment controller too; doing it here
    // as well is what covers the no-charge path, which never opens a sheet.
    ref.invalidate(bookingDetailProvider(bookingId));
    ref.invalidate(bookingsControllerProvider);
    return ConfirmCompleted(paid: paid);
  }

  ConfirmOutcome _stayOnScreen(String message) {
    final after = state.valueOrNull;
    if (after != null) {
      state = AsyncData(after.copyWith(busy: false, confirmError: message));
    }
    return ConfirmFailed(message);
  }

  String _confirmMessage(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Could not reach the server. Check your connection and try again.',
        // The backend's own sentence: "select at least 10 photos" is better
        // than anything worded here.
        BusinessError(:final message) => message,
        Forbidden() => 'This gallery is not yours to confirm.',
        Unauthorized() => 'Please sign in again.',
        RateLimited() => 'Too many attempts. Wait a moment and try again.',
        _ => 'Could not confirm your selection. Try again.',
      };
}

/// What a confirm attempt came to, for the screen to act on.
sealed class ConfirmOutcome {
  const ConfirmOutcome();
}

/// Selected, and paid if anything was owed. Time to leave.
final class ConfirmCompleted extends ConfirmOutcome {
  const ConfirmCompleted({required this.paid});

  final bool paid;
}

/// Something failed and the selection is intact. The message is already on
/// the state; it is repeated here so a caller need not read it back.
final class ConfirmFailed extends ConfirmOutcome {
  const ConfirmFailed(this.message);

  final String message;
}

/// The sheet was closed without paying. Not an error.
final class ConfirmPending extends ConfirmOutcome {
  const ConfirmPending();
}

/// Nothing happened: not confirmable right now.
final class ConfirmIgnored extends ConfirmOutcome {
  const ConfirmIgnored();
}
