import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/client_availability_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'availability_controller.g.dart';

/// How far ahead the calendar looks. The server refuses a range past it
/// (AVAILABILITY_HORIZON_DAYS), so asking beyond it would only fail.
const availabilityHorizonDays = 90;

/// Today as the server counts it: a UTC date. A device a few hours behind UTC
/// would otherwise ask about "today" after the server's today has ended, and
/// be refused for asking about the past.
///
/// A provider so a test can fix the date: what "past" and "beyond the
/// horizon" mean depends on it, and a test that only works mid-month is a
/// test that quietly skips its checks on the 1st.
@riverpod
DateTime availabilityToday(Ref ref) {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day);
}

DateTime availabilityLastDay(DateTime today) => today.add(const Duration(days: availabilityHorizonDays));

/// One month of a photographer's calendar for one package, clamped to what
/// can be booked at all: from today, up to the horizon. Null for a month
/// entirely outside that.
///
/// Which days are open and when a shoot can start are the server's answer -
/// the rule every booking path enforces - so this asks and does not compute.
@riverpod
Future<ClientAvailabilityResponse?> proAvailability(
  Ref ref,
  String proUserId,
  String packageId,
  DateTime month,
) async {
  final today = ref.watch(availabilityTodayProvider);
  final first = DateTime.utc(month.year, month.month);
  final last = DateTime.utc(month.year, month.month + 1).subtract(const Duration(days: 1));
  final from = first.isBefore(today) ? today : first;
  final to = last.isAfter(availabilityLastDay(today)) ? availabilityLastDay(today) : last;
  if (to.isBefore(from)) return null;

  final client = ref.read(clientLaunchClientProvider);
  final result = await apiCall(
    () => client.clientProAvailabilityV1ClientProsProUserIdAvailabilityGet(
      proUserId: proUserId,
      packageId: packageId,
      from: from,
      to: to,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
