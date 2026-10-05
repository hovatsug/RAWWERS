import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_availability_day.dart';
import 'package:rawwers/api/models/client_availability_response.dart';
import 'package:rawwers/api/models/client_availability_start.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/pro_profile/availability_controller.dart';

/// A start time the client picked, with what is needed to show it again
/// without asking: the photographer's local date and zone.
class PickedStart {
  const PickedStart({required this.day, required this.start, required this.timezone});

  /// The photographer's local date, as the server sent it.
  final DateTime day;
  final ClientAvailabilityStart start;
  final String timezone;

  /// "Mon 12 Oct at 10:00"
  String get label => '${availabilityDayLabel(day)} at ${start.localTime}';
}

/// When a client can book one package with one photographer.
///
/// Every open day and start time is the server's (the rule all booking paths
/// enforce); the calendar decides nothing about availability. It only stops
/// a client picking what the server did not offer: a closed day, a day in
/// the past, a month past the horizon.
class AvailabilityCalendar extends ConsumerStatefulWidget {
  const AvailabilityCalendar({
    required this.proUserId,
    required this.proName,
    required this.packageId,
    required this.onPick,
    super.key,
  });

  final String proUserId;
  final String proName;
  final String packageId;
  final void Function(PickedStart pick) onPick;

  @override
  ConsumerState<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends ConsumerState<AvailabilityCalendar> {
  late final DateTime _today = ref.read(availabilityTodayProvider);
  late DateTime _month = DateTime.utc(_today.year, _today.month);
  DateTime? _selected;

  bool get _canGoBack => _month.isAfter(DateTime.utc(_today.year, _today.month));
  bool get _canGoForward {
    final next = DateTime.utc(_month.year, _month.month + 1);
    return !next.isAfter(availabilityLastDay(_today));
  }

  void _move(int months) => setState(() {
        _month = DateTime.utc(_month.year, _month.month + months);
        _selected = null;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availability = ref.watch(proAvailabilityProvider(widget.proUserId, widget.packageId, _month));

    // Said before the grid is drawn: a month of closed days would read as
    // "fully booked", which is a different and wrong message.
    if (availability case AsyncData(value: ClientAvailabilityResponse(hasSchedule: false))) {
      return Text(
        "${widget.proName} hasn't set their working hours yet, so there are no times to book. "
        'Check back soon.',
        style: theme.textTheme.bodyMedium,
      );
    }

    final response = availability.valueOrNull;
    final days = {for (final day in response?.days ?? const <ClientAvailabilityDay>[]) _key(day.date): day};
    final selectedDay = _selected == null ? null : days[_key(_selected!)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: _canGoBack ? () => _move(-1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${_monthNames[_month.month - 1]} ${_month.year}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: _canGoForward ? () => _move(1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: RSpace.s8),
        Row(
          children: [
            for (final name in _weekdayInitials)
              Expanded(
                child: ExcludeSemantics(
                  child: Text(name, textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: RSpace.s4),
        switch (availability) {
          AsyncError() => Padding(
              padding: const EdgeInsets.symmetric(vertical: RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Could not load the calendar.', style: theme.textTheme.bodyMedium),
                  RTextLink(
                    label: 'Try again',
                    onPressed: () => ref.invalidate(proAvailabilityProvider(widget.proUserId, widget.packageId, _month)),
                  ),
                ],
              ),
            ),
          AsyncData() => _Grid(
              today: _today,
              month: _month,
              days: days,
              selected: _selected,
              onSelect: (day) => setState(() => _selected = day),
            ),
          _ => const RSkeleton(height: 6 * (rMinTouchTarget + RSpace.s4)),
        },
        if (response != null) ...[
          const SizedBox(height: RSpace.s12),
          Text(
            'Times are ${timezoneCity(response.timezone)} time. '
            'Books at least ${response.noticeHours} hours ahead.',
            style: theme.textTheme.bodySmall,
          ),
        ],
        if (selectedDay != null && response != null) ...[
          const SizedBox(height: RSpace.s16),
          Text('Start times on ${availabilityDayLabel(selectedDay.date)}', style: theme.textTheme.labelLarge),
          const SizedBox(height: RSpace.s8),
          Wrap(
            spacing: RSpace.s8,
            runSpacing: RSpace.s8,
            children: [
              for (final start in selectedDay.startTimes ?? const <ClientAvailabilityStart>[])
                RFilterChip(
                  label: start.localTime,
                  selected: false,
                  onPressed: () => widget.onPick(
                    PickedStart(day: selectedDay.date, start: start, timezone: response.timezone),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.today,
    required this.month,
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final DateTime today;
  final DateTime month;
  final Map<String, ClientAvailabilityDay> days;
  final DateTime? selected;
  final void Function(DateTime day) onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime.utc(month.year, month.month);
    final count = DateTime.utc(month.year, month.month + 1).difference(first).inDays;
    final leading = first.weekday - 1; // Monday first

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: RSpace.s4,
      children: [
        for (var i = 0; i < leading; i++) const SizedBox.shrink(),
        for (var d = 0; d < count; d++)
          () {
            final date = first.add(Duration(days: d));
            final day = days[_key(date)];
            // Open only when the server says so, and never in the past -
            // even if a server answer said otherwise, a day gone is gone.
            final open = !date.isBefore(today) && (day?.open ?? false) && (day?.startTimes?.isNotEmpty ?? false);
            return _DayCell(
              key: ValueKey('day-${_key(date)}'),
              date: date,
              open: open,
              isToday: date == today,
              isSelected: selected == date,
              onTap: open ? () => onSelect(date) : null,
            );
          }(),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.open,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final DateTime date;
  final bool open;
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final textColor = isSelected
        ? RInk.i050
        : open
            ? onSurface
            : theme.colorScheme.onSurfaceVariant;

    // Read aloud in words, so "closed" never depends on seeing a colour.
    final status = open ? 'available' : 'no times';
    final label = '${availabilityDayLabel(date)}, $status${isToday ? ', today' : ''}';

    return Semantics(
      label: label,
      button: open,
      selected: isSelected,
      // Its own tap, because excluding the children's semantics also drops
      // the InkWell's - a screen reader would hear "available" and be unable
      // to choose it.
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: rMinTouchTarget, minHeight: rMinTouchTarget),
          child: Center(
            child: Container(
              width: rMinTouchTarget,
              height: rMinTouchTarget,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? RAccent.meter700 : null,
                border: isToday && !isSelected ? Border.all(color: onSurface) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: open ? FontWeight.w700 : FontWeight.w400,
                      fontFeatures: RType.tabularFigures,
                    ),
                  ),
                  // A mark under every open day: a shape, not only a colour.
                  SizedBox(
                    height: 6,
                    child: open
                        ? Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: textColor),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Europe/Lisbon" -> "Lisbon". The zone's city reads as a place; the full
/// identifier is a database key.
String timezoneCity(String zone) => zone.split('/').last.replaceAll('_', ' ');

String availabilityDayLabel(DateTime date) =>
    '${_weekdayNames[date.weekday - 1]} ${date.day} ${_monthShort[date.month - 1]}';

String _key(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
