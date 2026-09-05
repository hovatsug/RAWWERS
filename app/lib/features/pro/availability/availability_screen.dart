import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/availability_exception_view.dart';
import 'package:rawwers/api/models/availability_rule_item.dart';
import 'package:rawwers/api/models/availability_rule_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/availability/availability_controller.dart';

/// When a photographer can be booked.
///
/// Three separate questions, kept visually separate because they fail
/// separately and mean different things: the hours you normally work, the
/// days you are away, and how much notice you need.
class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(workingHoursControllerProvider);
            ref.invalidate(blockedTimeControllerProvider);
            ref.invalidate(schedulingPolicyControllerProvider);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(RSpace.s16),
            children: const [
              _SectionLabel('Working hours'),
              _WorkingHours(),
              SizedBox(height: RSpace.s24),
              _SectionLabel('Time off'),
              _BlockedTime(),
              SizedBox(height: RSpace.s24),
              _SectionLabel('Notice'),
              _LeadTime(),
              SizedBox(height: RSpace.s32),
            ],
          ),
        ),
      ),
    );
  }
}

const _weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class _WorkingHours extends ConsumerWidget {
  const _WorkingHours();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(workingHoursControllerProvider);
    final theme = Theme.of(context);

    return switch (rules) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: RSpace.s12),
                  child: Text(
                    'You have not set any working hours. Clients cannot send '
                    'you a request until you do.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              for (var weekday = 0; weekday < 7; weekday++)
                _DayRow(
                  weekday: weekday,
                  rule: value.where((r) => r.weekday == weekday).firstOrNull,
                ),
            ],
          ),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load your working hours.',
          onRetry: () => ref.invalidate(workingHoursControllerProvider),
        ),
      _ => const RCard(child: RSkeleton(width: 240)),
    };
  }
}

class _DayRow extends ConsumerWidget {
  const _DayRow({required this.weekday, required this.rule});

  final int weekday;
  final AvailabilityRuleView? rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final on = rule != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSpace.s4),
      child: Row(
        children: [
          Expanded(child: Text(_weekdayNames[weekday], style: theme.textTheme.bodyMedium)),
          if (on)
            TextButton(
              onPressed: () => _editHours(context, ref),
              child: Text(_hoursLabel(rule!.startLocal, rule!.endLocal)),
            )
          else
            Text('Not working', style: theme.textTheme.bodySmall),
          Switch(
            value: on,
            onChanged: (enabled) => _toggle(context, ref, enabled),
          ),
        ],
      ),
    );
  }

  /// "09:00:00" reads as a duration; a photographer reads "09:00".
  String _short(String time) => time.length >= 5 ? time.substring(0, 5) : time;

  /// A shift ending at or before it starts runs into the next morning.
  /// Said outright, because "20:00 - 02:00" on its own reads as a
  /// data-entry mistake, and a photographer glancing at their week needs
  /// to tell a night shift from a typo without doing the arithmetic.
  String _hoursLabel(String start, String end) {
    final label = '${_short(start)} – ${_short(end)}';
    return _wrapsMidnight(start, end) ? '$label (next day)' : label;
  }

  bool _wrapsMidnight(String start, String end) => _minutes(_parse(end)) <= _minutes(_parse(start));

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool enabled) async {
    final current = ref.read(workingHoursControllerProvider).valueOrNull ?? const [];
    final timezone = await ref.read(availabilityTimezoneProvider.future);
    if (!context.mounted) return;

    final next = <AvailabilityRuleItem>[
      for (final r in current)
        if (r.weekday != weekday)
          AvailabilityRuleItem(
            weekday: r.weekday,
            startLocal: r.startLocal,
            endLocal: r.endLocal,
            timezone: r.timezone,
            locationMode: r.locationMode,
          ),
      if (enabled)
        AvailabilityRuleItem(
          weekday: weekday,
          startLocal: '09:00:00',
          endLocal: '17:00:00',
          timezone: timezone,
          locationMode: defaultLocationMode,
        ),
    ];

    final error = await ref.read(workingHoursControllerProvider.notifier).replace(next);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _editHours(BuildContext context, WidgetRef ref) async {
    final existing = rule;
    if (existing == null) return;

    final start = await showTimePicker(
      context: context,
      initialTime: _parse(existing.startLocal),
      helpText: 'Start of day',
    );
    if (start == null || !context.mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _parse(existing.endLocal),
      helpText: 'End of day',
    );
    if (end == null || !context.mounted) return;

    // No "end must be after start" check: an end at or before the start
    // means the shift runs into the next day, which is what night work is.
    // The backend still refuses one long enough to nearly lap itself.

    final current = ref.read(workingHoursControllerProvider).valueOrNull ?? const [];
    final next = [
      for (final r in current)
        AvailabilityRuleItem(
          weekday: r.weekday,
          startLocal: r.weekday == weekday ? _api(start) : r.startLocal,
          endLocal: r.weekday == weekday ? _api(end) : r.endLocal,
          timezone: r.timezone,
          locationMode: r.locationMode,
        ),
    ];

    final error = await ref.read(workingHoursControllerProvider.notifier).replace(next);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  TimeOfDay _parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.tryParse(parts.first) ?? 9, minute: int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0);
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _api(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}

class _BlockedTime extends ConsumerWidget {
  const _BlockedTime();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedTimeControllerProvider);
    final theme = Theme.of(context);

    return switch (blocked) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.isEmpty)
                Text('Nothing blocked off.', style: theme.textTheme.bodyMedium)
              else
                for (final item in value)
                  _BlockedRow(item: item, onRemove: () => _unblock(context, ref, item)),
              const SizedBox(height: RSpace.s12),
              RButton(
                label: 'Block off dates',
                variant: RButtonVariant.secondary,
                onPressed: () => _block(context, ref),
              ),
            ],
          ),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load your time off.',
          onRetry: () => ref.invalidate(blockedTimeControllerProvider),
        ),
      _ => const RCard(child: RSkeleton(width: 200)),
    };
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'Dates you are away',
    );
    if (range == null || !context.mounted) return;

    // Inclusive of the last day: someone blocking the 3rd to the 7th means
    // through the end of the 7th, not up to midnight as it begins.
    final from = DateTime(range.start.year, range.start.month, range.start.day);
    final to = DateTime(range.end.year, range.end.month, range.end.day).add(const Duration(days: 1));

    final error = await ref.read(blockedTimeControllerProvider.notifier).block(from: from, to: to);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _unblock(BuildContext context, WidgetRef ref, AvailabilityExceptionView item) async {
    final confirmed = await showRConfirmDialog(
      context,
      title: 'Unblock these dates?',
      message: 'Clients will be able to book you then.',
      confirmLabel: 'Unblock',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref.read(blockedTimeControllerProvider.notifier).unblock(item.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _BlockedRow extends StatelessWidget {
  const _BlockedRow({required this.item, required this.onRemove});

  final AvailabilityExceptionView item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = item.startAtUtc.toLocal();
    // The stored end is exclusive; show the last day the pro is actually away.
    final to = item.endAtUtc.toLocal().subtract(const Duration(days: 1));

    return Padding(
      padding: const EdgeInsets.only(bottom: RSpace.s8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_range(from, to), style: theme.textTheme.bodyMedium),
                if (item.reason != null)
                  Text(item.reason!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close), tooltip: 'Unblock'),
        ],
      ),
    );
  }

  String _range(DateTime from, DateTime to) {
    final f = _day(from);
    final t = _day(to);
    return f == t ? f : '$f – $t';
  }

  String _day(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _LeadTime extends ConsumerWidget {
  const _LeadTime();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(schedulingPolicyControllerProvider);
    final theme = Theme.of(context);

    return switch (policy) {
      AsyncData(:final value) => RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shortest notice you will take', style: theme.textTheme.bodyMedium),
              const SizedBox(height: RSpace.s4),
              Text(
                'A client cannot pick a time sooner than this.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: RSpace.s12),
              Wrap(
                spacing: RSpace.s8,
                runSpacing: RSpace.s8,
                children: [
                  for (final hours in const [2, 12, 24, 48, 72])
                    ChoiceChip(
                      label: Text(_leadLabel(hours)),
                      selected: value.advanceNoticeHours == hours,
                      onSelected: (_) => _set(context, ref, hours),
                    ),
                ],
              ),
            ],
          ),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load your notice period.',
          onRetry: () => ref.invalidate(schedulingPolicyControllerProvider),
        ),
      _ => const RCard(child: RSkeleton(width: 180)),
    };
  }

  String _leadLabel(int hours) => switch (hours) {
        2 => '2 hours',
        12 => '12 hours',
        24 => '1 day',
        48 => '2 days',
        _ => '3 days',
      };

  Future<void> _set(BuildContext context, WidgetRef ref, int hours) async {
    final error = await ref.read(schedulingPolicyControllerProvider.notifier).setAdvanceNoticeHours(hours);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RSpace.s8),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
