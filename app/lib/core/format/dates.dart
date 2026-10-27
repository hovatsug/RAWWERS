import 'package:flutter/material.dart';

/// Every date and time the pro app shows, in one place.
///
/// One family, day first and 24-hour, whatever the device: "Tue 27 Oct"
/// for a day, "27 Oct 2026" for a dated record, "10:00" and "10:00–11:00"
/// for times. Never month first and never AM/PM - including on a phone set
/// to en-US, which is how the simulator and many travellers' phones come.
/// The locale is still read ([of]), so a language added later decides its
/// own words here and nowhere else; the words today are the app's own
/// (English), so a Portuguese phone never gets a Portuguese month inside an
/// English sentence. Times arrive as UTC and are shown in local time.
class RDates {
  const RDates._();

  /// The conventions for [locale]. Every locale the app supports - en-GB
  /// and Portuguese by default - writes dates the same way.
  factory RDates.forLocale(Locale locale) => const RDates._();

  /// The conventions of the device this runs on.
  static RDates of(BuildContext context) => RDates.forLocale(View.of(context).platformDispatcher.locale);

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// 26 Oct 2026
  String date(DateTime at) {
    final d = at.toLocal();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// Mon 26 Oct
  String dayDate(DateTime at) {
    final d = at.toLocal();
    return '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
  }

  /// 26 Oct
  String dayMonth(DateTime at) {
    final d = at.toLocal();
    return '${d.day} ${_months[d.month - 1]}';
  }

  /// 26/10
  String numericDay(DateTime at) {
    final d = at.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  /// 21:05
  String time(DateTime at) {
    final d = at.toLocal();
    return timeOfDay(TimeOfDay(hour: d.hour, minute: d.minute));
  }

  /// A time with no date: working hours, a preparation time.
  String timeOfDay(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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
