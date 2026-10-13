import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/accept_booking_request.dart';
import 'package:rawwers/api/models/booking_decision_request.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/booking_request_status.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/cursor_page.dart';

part 'requests_controller.g.dart';

/// Which slice of the queue the Requests tab is showing.
///
/// `pending` is the default because it is the only status that needs a
/// decision - the rest are history, and a photographer opening this tab is
/// answering "what needs me", not browsing.
enum RequestsFilter {
  pending(BookingRequestStatus.pending, 'Pending'),
  accepted(BookingRequestStatus.accepted, 'Accepted'),
  declined(BookingRequestStatus.declined, 'Declined'),
  expired(BookingRequestStatus.expired, 'Expired');

  const RequestsFilter(this.status, this.label);

  final BookingRequestStatus status;
  final String label;
}

@riverpod
class RequestsFilterController extends _$RequestsFilterController {
  @override
  RequestsFilter build() => RequestsFilter.pending;

  void select(RequestsFilter filter) => state = filter;
}

@riverpod
class RequestsController extends _$RequestsController {
  @override
  Future<CursorPage<BookingRequestListItem>> build() async {
    // Watched, not read: changing the filter chip rebuilds this provider and
    // refetches from page one, which is correct - a cursor from the pending
    // list is meaningless against the declined list.
    final filter = ref.watch(requestsFilterControllerProvider);
    final result = await _fetch(status: filter.status, cursor: null);
    return switch (result) {
      Ok(:final value) => CursorPage(items: value.items, nextCursor: value.nextCursor),
      Err(:final failure) => throw failure,
    };
  }

  Future<Result<CursorFetchResult<BookingRequestListItem>>> _fetch({
    required BookingRequestStatus status,
    required String? cursor,
  }) async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.listBookingRequestsV1BookingRequestsGet(
        status: status,
        cursor: cursor,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => Ok(CursorFetchResult(items: value.items ?? const [], nextCursor: value.nextCursor)),
      Err(:final failure) => Err(failure),
    };
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final filter = ref.read(requestsFilterControllerProvider);

    state = AsyncData(current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    final next = await appendNextPage(current, (cursor) => _fetch(status: filter.status, cursor: cursor));
    state = AsyncData(next);
  }

  /// Reloads from page one.
  ///
  /// Also the correct response to a countdown reaching zero. The server
  /// expires pending requests on a sweep that runs every 15 minutes, so
  /// between the deadline passing and the sweep running there is a window
  /// where the client believes a request is dead and the server would still
  /// accept it. Rendering "expired" locally would show the photographer a
  /// closed door that is in fact still open; asking the server instead means
  /// the state on screen is the state that will be enforced.
  Future<void> refresh() async {
    ref.invalidateSelf();
    // An answer changes what is waiting; the badge says so now, not at the
    // next poll.
    ref.invalidate(pendingRequestsControllerProvider);
    await future;
  }

  /// Returns null on success, a user-facing message otherwise.
  ///
  /// [clientCreditPercent] overrides this photographer's standing setting for
  /// this booking only - for being more generous on one large job without
  /// changing how they price everything else. Null means use their default,
  /// which is not the same as zero.
  Future<String?> accept(String requestId, {int? clientCreditPercent}) async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.acceptBookingRequestV1BookingRequestsRequestIdAcceptPost(
        requestId: requestId,
        requestBody: AcceptBookingRequest(clientCreditPercent: clientCreditPercent),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        return _decisionMessage(failure);
    }
  }

  Future<String?> decline(String requestId, {String? reason}) async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.declineBookingRequestV1BookingRequestsRequestIdDeclinePost(
        requestId: requestId,
        requestBody: BookingDecisionRequest(reason: reason),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        return _decisionMessage(failure);
    }
  }
}

/// What the Requests tab's badge shows: how many requests are waiting on an
/// answer, and whether there are more than one page holds.
class PendingRequests {
  const PendingRequests(this.count, {this.more = false});

  final int count;
  final bool more;

  String get label => more ? '$count+' : '$count';

  @override
  bool operator ==(Object other) => other is PendingRequests && other.count == count && other.more == more;

  @override
  int get hashCode => Object.hash(count, more);
}

/// Requests waiting on the photographer, for the Requests tab's badge.
///
/// Polled every 30 seconds while the app is running: with no push yet, this
/// is how a photographer with the app open learns a request arrived - and a
/// short-notice one has only 30 minutes to be answered. Read from the first
/// page of the same pending list the tab shows, so the two cannot disagree;
/// a request past its deadline that the sweep has not reached yet is not
/// counted. When the count changes the list is refetched too, so a new
/// request is already there when the tab is opened.
@Riverpod(keepAlive: true)
class PendingRequestsController extends _$PendingRequestsController {
  static const pollEvery = Duration(seconds: 30);
  Timer? _timer;

  @override
  Future<PendingRequests> build() async {
    _timer ??= Timer.periodic(pollEvery, (_) => ref.invalidateSelf());
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    final before = state.valueOrNull;
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.listBookingRequestsV1BookingRequestsGet(
        status: BookingRequestStatus.pending,
        cursor: null,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        final now = DateTime.now();
        final waiting = (value.items ?? const []).where((r) => r.expiresAt.isAfter(now)).length;
        final pending = PendingRequests(waiting, more: value.nextCursor != null);
        if (before != null && before != pending) ref.invalidate(requestsControllerProvider);
        return pending;
      // A badge that cannot load keeps what it had rather than an error on
      // every tab.
      case Err():
        return before ?? const PendingRequests(0);
    }
  }
}

/// True when a failure is the KYC gate rather than a generic error.
///
/// Accepting a booking requires an approved KYC status, and a new pro starts
/// at `unsubmitted` - `submit-kyc` only moves them to `pending`, and approval
/// is admin-only. So every photographer hits this on their first request; it
/// is the normal path, not an exception, and needs to read like onboarding.
bool isKycRequired(ApiFailure failure) =>
    failure is BusinessError && failure.code == 'kyc_required';

String _decisionMessage(ApiFailure failure) {
  if (isKycRequired(failure)) {
    return 'Your identity check needs to be approved before you can accept bookings. '
        'Submit it from Settings and we\'ll confirm as soon as it\'s reviewed.';
  }
  return switch (failure) {
    // The request moved under the photographer - expired on the sweep, or
    // cancelled by the client while this screen was open.
    BusinessError(:final message) => message,
    NotFound() => 'That request is no longer available.',
    NetworkError() => 'No connection - check your network and try again.',
    Timeout() => 'That took too long - try again.',
    _ => 'Something went wrong. Please try again.',
  };
}
