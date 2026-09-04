import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/availability_exception_item.dart';
import 'package:rawwers/api/models/availability_exceptions_replace_request.dart';
import 'package:rawwers/api/models/availability_exception_view.dart';
import 'package:rawwers/api/models/availability_location_mode.dart';
import 'package:rawwers/api/models/availability_rule_item.dart';
import 'package:rawwers/api/models/availability_rules_replace_request.dart';
import 'package:rawwers/api/models/scheduling_availability_rule_view.dart';
import 'package:rawwers/api/models/scheduling_policy_update_request.dart';
import 'package:rawwers/api/models/scheduling_policy_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

part 'availability_controller.g.dart';

/// Weekly working hours.
///
/// Reads and writes /v1/pro/scheduling/* exclusively. The older
/// /v1/pro/me/availability/* pair is deprecated: it drops the timezone and
/// location mode it does not accept, so posting there silently resets them.
@riverpod
class WorkingHoursController extends _$WorkingHoursController {
  @override
  Future<List<SchedulingAvailabilityRuleView>> build() async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.getMyAvailabilityRulesV1ProSchedulingAvailabilityRulesGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value.items ?? const [],
      Err(:final failure) => throw failure,
    };
  }

  /// Replaces the whole week. The endpoint is a replace, not a merge, so
  /// the caller passes every rule it wants to survive.
  Future<String?> replace(List<AvailabilityRuleItem> rules) async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.putMyAvailabilityRulesV1ProSchedulingAvailabilityRulesPut(
        requestBody: AvailabilityRulesReplaceRequest(rules: rules),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value.items ?? const []);
        return null;
      case Err(:final failure):
        return _explain(failure, 'Could not save your working hours.');
    }
  }
}

/// Days blocked off.
///
/// Writes ProAvailabilityException, which every booking path now enforces.
@riverpod
class BlockedTimeController extends _$BlockedTimeController {
  @override
  Future<List<AvailabilityExceptionView>> build() async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.getMySchedulingExceptionsV1ProSchedulingExceptionsGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value.items ?? const [],
      Err(:final failure) => throw failure,
    };
  }

  Future<String?> block({required DateTime from, required DateTime to, String? reason}) {
    final existing = state.valueOrNull ?? const [];
    return _replace([
      ...existing.map(_toItem),
      AvailabilityExceptionItem(
        // The picker hands back local dates; the API is explicit that these
        // are UTC instants, and the day a photographer means by "the 3rd"
        // is their day, not Greenwich's.
        startAtUtc: from.toUtc(),
        endAtUtc: to.toUtc(),
        reason: (reason == null || reason.trim().isEmpty) ? null : reason.trim(),
      ),
    ]);
  }

  Future<String?> unblock(String id) {
    final existing = state.valueOrNull ?? const [];
    return _replace([
      for (final item in existing)
        if (item.id != id) _toItem(item),
    ]);
  }

  /// The endpoint replaces the whole set, so removing one block means
  /// sending back all the others. Getting this wrong would delete a
  /// photographer's remaining blocked time without saying so.
  Future<String?> _replace(List<AvailabilityExceptionItem> items) async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.putMySchedulingExceptionsV1ProSchedulingExceptionsPut(
        requestBody: AvailabilityExceptionsReplaceRequest(items: items),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value.items ?? const []);
        return null;
      case Err(:final failure):
        return _explain(failure, 'Could not save your blocked time.');
    }
  }

  AvailabilityExceptionItem _toItem(AvailabilityExceptionView view) => AvailabilityExceptionItem(
        startAtUtc: view.startAtUtc,
        endAtUtc: view.endAtUtc,
        reason: view.reason,
      );
}

/// Lead time and slot shape.
@riverpod
class SchedulingPolicyController extends _$SchedulingPolicyController {
  @override
  Future<SchedulingPolicyView> build() async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.getMySchedulingPolicyV1ProSchedulingPolicyGet(
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<String?> setAdvanceNoticeHours(int hours) async {
    final client = ref.read(schedulingClientProvider);
    final result = await apiCall(
      () => client.putMySchedulingPolicyV1ProSchedulingPolicyPut(
        requestBody: SchedulingPolicyUpdateRequest(advanceNoticeHours: hours),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok(:final value):
        state = AsyncData(value);
        return null;
      case Err(:final failure):
        return _explain(failure, 'Could not save your lead time.');
    }
  }
}

String _explain(ApiFailure failure, String fallback) => switch (failure) {
      NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
      BusinessError(:final message) => message,
      Validation(:final fieldErrors) =>
        fieldErrors.values.firstOrNull?.firstOrNull ?? fallback,
      _ => fallback,
    };

/// The IANA timezone to send with every rule.
///
/// Not `DateTime.now().timeZoneName`: that returns an abbreviation like
/// "WEST", and the backend validates with ZoneInfo and 422s on it - every
/// save of working hours would have failed. Dart's core library has no IANA
/// name, so this prefers what the pro has already chosen (their existing
/// rules), then the timezone the backend keeps on their notification
/// preferences, which is a real zone name.
@riverpod
Future<String> availabilityTimezone(Ref ref) async {
  final rules = await ref.watch(workingHoursControllerProvider.future);
  final existing = rules.firstOrNull?.timezone;
  if (existing != null && existing.isNotEmpty) return existing;

  final prefs = await ref.watch(notificationPreferencesControllerProvider.future);
  return prefs.timezone;
}

const defaultLocationMode = AvailabilityLocationMode.both;
