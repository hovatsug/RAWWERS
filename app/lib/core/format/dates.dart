import 'package:flutter/material.dart';

/// Every date and time the pro app shows, in one place.
///
/// The device's locale decides the order and the clock: a US device reads
/// "Oct 26, 2026" and "9:05 PM"; everywhere else - en-GB and Portuguese
/// first among them - reads "26 Oct 2026" and "21:05". The words stay the
/// app's own (English), so a Portuguese phone never gets a Portuguese month
/// inside an English sentence. Times arrive as UTC from the server and are
/// shown in the device's local time.
class RDates {
  const RDates._({required this.monthFirst, required this.twelveHour});

  /// The conventions for [locale].
  factory RDates.forLocale(Locale locale) {
    final us = locale.countryCode == 'US';
    return RDates._(monthFirst: us, twelveHour: us);
  }

  /// The conventions of the device this runs on.
  static RDates of(BuildContext context) => RDates.forLocale(View.of(context).platformDispatcher.locale);

  final bool monthFirst;
  final bool twelveHour;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// 26 Oct 2026 / Oct 26, 2026
  String date(DateTime at) {
    final d = at.toLocal();
    final month = _months[d.month - 1];
    return monthFirst ? '$month ${d.day}, ${d.year}' : '${d.day} $month ${d.year}';
  }

  /// Mon 26 Oct / Mon, Oct 26
  String dayDate(DateTime at) {
    final d = at.toLocal();
    final day = _days[d.weekday - 1];
    final month = _months[d.month - 1];
    return monthFirst ? '$day, $month ${d.day}' : '$day ${d.day} $month';
  }

  /// 26 Oct / Oct 26
  String dayMonth(DateTime at) {
    final d = at.toLocal();
    final month = _months[d.month - 1];
    return monthFirst ? '$month ${d.day}' : '${d.day} $month';
  }

  /// 26/10 / 10/26
  String numericDay(DateTime at) {
    final d = at.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return monthFirst ? '$month/$day' : '$day/$month';
  }

  /// 21:05 / 9:05 PM
  String time(DateTime at) {
    final d = at.toLocal();
    return timeOfDay(TimeOfDay(hour: d.hour, minute: d.minute));
  }

  /// A time with no date: working hours, a preparation time.
  String timeOfDay(TimeOfDay t) {
    final minute = t.minute.toString().padLeft(2, '0');
    if (!twelveHour) return '${t.hour.toString().padLeft(2, '0')}:$minute';
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Mon 26 Oct · 21:05
  String dateTime(DateTime at) => '${dayDate(at)} · ${time(at)}';

  /// 21:05–22:30
  String timeRange(DateTime from, DateTime to) => '${time(from)}–${time(to)}';

  /// How long ago, in a list: now, 5m, 3h, 2d - and the date from a week on.
  String relative(DateTime at, {DateTime? now}) {
    final delta = (now ?? DateTime.now()).difference(at.toLocal());
    if (delta.inMinutes < 1) return 'now';
    if (delta.inHours < 1) return '${delta.inMinutes}m';
    if (delta.inDays < 1) return '${delta.inHours}h';
    if (delta.inDays < 7) return '${delta.inDays}d';
    return dayDate(at);
  }
}
