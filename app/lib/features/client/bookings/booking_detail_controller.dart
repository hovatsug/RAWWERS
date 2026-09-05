import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'booking_detail_controller.g.dart';

/// One booking, with its transition history.
@riverpod
Future<ClientBookingStatusResponse> bookingDetail(Ref ref, String bookingId) async {
  final client = ref.read(clientLaunchClientProvider);
  final result = await apiCall(
    () => client.clientBookingStatusV1ClientBookingsBookingIdGet(
      bookingId: bookingId,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// One entry in a booking's history.
///
/// `timeline` is `list[dict]` in the schema - untyped, like
/// `ClientPreferenceView.location` and `top_niches` (see
/// docs/BACKEND_GAPS.md). The backend writes `at`, `from`, `to` and `reason`;
/// this reads them defensively and drops any row it cannot make sense of
/// rather than rendering "null → null".
class BookingTimelineEntry {
  const BookingTimelineEntry({required this.at, required this.to, this.from, this.reason});

  final DateTime at;
  final String to;
  final String? from;
  final String? reason;

  static BookingTimelineEntry? tryParse(Map<String, dynamic> raw) {
    final at = raw['at'];
    final to = raw['to'];
    if (at is! String || to is! String || to.isEmpty) return null;
    final parsed = DateTime.tryParse(at);
    if (parsed == null) return null;
    final from = raw['from'];
    final reason = raw['reason'];
    return BookingTimelineEntry(
      at: parsed.toLocal(),
      to: to,
      from: from is String && from.isNotEmpty ? from : null,
      reason: reason is String && reason.isNotEmpty ? reason : null,
    );
  }
}

List<BookingTimelineEntry> parseTimeline(List<Map<String, dynamic>>? raw) {
  if (raw == null) return const [];
  return [
    for (final entry in raw) ?BookingTimelineEntry.tryParse(entry),
  ];
}
