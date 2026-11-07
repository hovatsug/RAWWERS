import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/booking_credit_preview.dart';
import 'package:rawwers/api/models/my_credit_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'credit_controller.g.dart';

/// The client's credit, in euros, with its history newest first.
@riverpod
Future<MyCreditResponse> myCredit(Ref ref) async {
  final result = await apiCall(
    () => ref.read(clientCreditClientProvider).myCreditV1MeCreditGet(authorization: null, xMinusUserMinusId: null),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// What credit would take off this booking's payment. Null when it cannot
/// be had: the switch is simply not shown.
@riverpod
Future<BookingCreditPreview?> bookingCredit(Ref ref, String bookingId) async {
  final result = await apiCall(
    () => ref.read(clientCreditClientProvider).bookingCreditV1ClientBookingsBookingIdCreditGet(
          bookingId: bookingId,
          authorization: null,
          xMinusUserMinusId: null,
        ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err() => null,
  };
}
