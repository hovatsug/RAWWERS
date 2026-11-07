import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/addon_quote_response.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/start_addon_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/client/bookings/booking_detail_controller.dart';
import 'package:rawwers/features/client/bookings/booking_payment_controller.dart';
import 'package:rawwers/features/client/bookings/bookings_controller.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';

part 'addon_controller.g.dart';

/// Adding photos after the selection closed, while its window is open.
///
/// What is already chosen is fixed: greyed, not selectable, not removable.
/// The rest may be picked; the price is always the server's (the curve's
/// total for all the photos, less what was already paid), fetched for the
/// current pick before anything is confirmed.
class AddonState {
  const AddonState({
    required this.gallery,
    required this.picked,
    this.quote,
    this.quoting = false,
    this.busy = false,
    this.error,
    this.requestId,
  });

  final GalleryDetailResponse gallery;
  final Set<String> picked;
  final AddonQuoteResponse? quote;

  /// A quote for the current pick is on its way; the old one is not shown.
  final bool quoting;
  final bool busy;
  final String? error;

  /// One id per add-on attempt: retrying after a closed sheet is the same one.
  final String? requestId;

  Set<String> get chosen => {...?gallery.chosenMediaAssetIds};
  bool get open => gallery.addonOpen;
  bool isChosen(String id) => chosen.contains(id);
  bool isPicked(String id) => picked.contains(id);
  int get unchosen => gallery.items.where((i) => !isChosen(i.mediaAssetId)).length;

  /// Confirmable: something picked, a current quote for exactly that pick.
  bool get canConfirm => open && !busy && !quoting && picked.isNotEmpty && quote?.adding == picked.length;

  AddonState copyWith({
    Set<String>? picked,
    AddonQuoteResponse? quote,
    bool clearQuote = false,
    bool? quoting,
    bool? busy,
    String? error,
    bool clearError = false,
    String? requestId,
    bool clearRequestId = false,
  }) =>
      AddonState(
        gallery: gallery,
        picked: picked ?? this.picked,
        quote: clearQuote ? null : (quote ?? this.quote),
        quoting: quoting ?? this.quoting,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        requestId: clearRequestId ? null : (requestId ?? this.requestId),
      );
}

String _newRequestId([Random? random]) {
  final r = random ?? Random.secure();
  return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}

/// What a confirm came to.
enum AddonOutcome { added, pending, failed, ignored }

@riverpod
class AddonController extends _$AddonController {
  @override
  Future<AddonState> build(String galleryId) async {
    final result = await apiCall(
      () => ref.read(proofGalleriesClientProvider).getGalleryV1ProofGalleriesGalleryIdGet(
            galleryId: galleryId,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    return switch (result) {
      Ok(:final value) => AddonState(gallery: value, picked: const {}),
      Err(:final failure) => throw failure,
    };
  }

  /// Pick or unpick a photo not yet chosen. Chosen ones never change.
  Future<void> toggle(String assetId) async {
    final current = state.valueOrNull;
    if (current == null || !current.open || current.busy || current.isChosen(assetId)) return;
    final picked = {...current.picked};
    if (!picked.remove(assetId)) picked.add(assetId);
    state = AsyncData(current.copyWith(picked: picked, quoting: picked.isNotEmpty, clearQuote: true, clearError: true, clearRequestId: true));
    if (picked.isNotEmpty) await _quote(picked.length);
  }

  Future<void> _quote(int adding) async {
    final result = await apiCall(
      () => ref.read(proofGalleriesClientProvider).getAddonQuoteV1ProofGalleriesGalleryIdAddonQuoteGet(
            galleryId: galleryId,
            adding: adding,
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    final after = state.valueOrNull;
    if (after == null || after.picked.length != adding) return;
    state = AsyncData(switch (result) {
      Ok(:final value) => after.copyWith(quote: value, quoting: false),
      Err(:final failure) => after.copyWith(quoting: false, error: _message(failure)),
    });
  }

  /// Start the add-on and pay for it. Added at once when nothing is owed.
  Future<AddonOutcome> confirm({required String bookingId}) async {
    final current = state.valueOrNull;
    if (current == null || !current.canConfirm) return AddonOutcome.ignored;
    final requestId = current.requestId ?? _newRequestId();
    state = AsyncData(current.copyWith(busy: true, clearError: true, requestId: requestId));

    final started = await apiCall(
      () => ref.read(proofGalleriesClientProvider).startAddonV1ProofGalleriesGalleryIdAddonsPost(
            galleryId: galleryId,
            requestBody: StartAddonRequest(mediaAssetIds: current.picked.toList(), clientRequestId: requestId),
            authorization: null,
            xMinusUserMinusId: null,
          ),
    );
    switch (started) {
      case Err(:final failure):
        state = AsyncData(state.requireValue.copyWith(busy: false, error: _message(failure)));
        return AddonOutcome.failed;
      case Ok(:final value):
        final secret = value.paymentIntentClientSecret;
        if (secret == null || secret.isEmpty) return _done(bookingId);
        final subscription = ref.listen(bookingPaymentControllerProvider(bookingId), (_, _) {});
        try {
          await ref.read(bookingPaymentControllerProvider(bookingId).notifier).presentFor(secret);
          final progress = ref.read(bookingPaymentControllerProvider(bookingId));
          switch (progress) {
            case PaymentSucceeded():
              return _done(bookingId);
            case PaymentFailed(:final message):
              state = AsyncData(state.requireValue.copyWith(busy: false, error: message));
              return AddonOutcome.failed;
            default:
              state = AsyncData(state.requireValue.copyWith(busy: false));
              return AddonOutcome.pending;
          }
        } finally {
          subscription.close();
        }
    }
  }

  AddonOutcome _done(String bookingId) {
    ref.invalidateSelf();
    ref.invalidate(deliveredControllerProvider(galleryId));
    ref.invalidate(bookingDetailProvider(bookingId));
    ref.invalidate(bookingsControllerProvider);
    return AddonOutcome.added;
  }

  String _message(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Could not reach the server. Check your connection and try again.',
        BusinessError(:final message) => message,
        _ => 'Could not add those photos. Try again.',
      };
}
