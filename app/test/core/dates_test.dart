// Every date and time in the pro app goes through RDates: the device locale
// decides the order and the clock; the words are the app's (English).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/format/dates.dart';

final _at = DateTime(2026, 10, 26, 21, 5); // a Monday, local time
final _end = DateTime(2026, 10, 26, 22, 30);

void main() {
  group('en-GB: day first, 24-hour', () {
    final d = RDates.forLocale(const Locale('en', 'GB'));
    test('date', () => expect(d.date(_at), '26 Oct 2026'));
    test('day and date', () => expect(d.dayDate(_at), 'Mon 26 Oct'));
    test('time', () => expect(d.time(_at), '21:05'));
    test('date and time', () => expect(d.dateTime(_at), 'Mon 26 Oct · 21:05'));
    test('a time range', () => expect(d.timeRange(_at, _end), '21:05–22:30'));
    test('a time of day', () => expect(d.timeOfDay(const TimeOfDay(hour: 9, minute: 0)), '09:00'));
    test('a numeric day', () => expect(d.numericDay(_at), '26/10'));
    test('day and month', () => expect(d.dayMonth(_at), '26 Oct'));
  });

  group('pt-PT: day first, 24-hour, in the app\'s words', () {
    final d = RDates.forLocale(const Locale('pt', 'PT'));
    test('date', () => expect(d.date(_at), '26 Oct 2026'));
    test('time', () => expect(d.time(_at), '21:05'));
    test('a numeric day', () => expect(d.numericDay(_at), '26/10'));
  });

  test('pt with no country is day first too', () {
    expect(RDates.forLocale(const Locale('pt')).time(_at), '21:05');
  });

  group('en-US: month first, 12-hour', () {
    final d = RDates.forLocale(const Locale('en', 'US'));
    test('date', () => expect(d.date(_at), 'Oct 26, 2026'));
    test('day and date', () => expect(d.dayDate(_at), 'Mon, Oct 26'));
    test('time', () => expect(d.time(_at), '9:05 PM'));
    test('noon and midnight', () {
      expect(d.time(DateTime(2026, 1, 1, 12, 0)), '12:00 PM');
      expect(d.time(DateTime(2026, 1, 1, 0, 30)), '12:30 AM');
    });
    test('a time of day', () => expect(d.timeOfDay(const TimeOfDay(hour: 9, minute: 0)), '9:00 AM'));
    test('a numeric day', () => expect(d.numericDay(_at), '10/26'));
    test('day and month', () => expect(d.dayMonth(_at), 'Oct 26'));
  });

  test('times in UTC are shown in the device\'s local time', () {
    final d = RDates.forLocale(const Locale('en', 'GB'));
    final utc = DateTime.utc(2026, 10, 26, 12);
    expect(d.time(utc), d.time(utc.toLocal()));
  });

  group('relative', () {
    final d = RDates.forLocale(const Locale('en', 'GB'));
    final now = DateTime(2026, 10, 26, 12);
    test('now, minutes, hours, days', () {
      expect(d.relative(now.subtract(const Duration(seconds: 20)), now: now), 'now');
      expect(d.relative(now.subtract(const Duration(minutes: 5)), now: now), '5m');
      expect(d.relative(now.subtract(const Duration(hours: 3)), now: now), '3h');
      expect(d.relative(now.subtract(const Duration(days: 2)), now: now), '2d');
    });
    test('a week or more is the date', () {
      expect(d.relative(DateTime(2026, 10, 12, 9), now: now), 'Mon 12 Oct');
    });
  });

  testWidgets('RDates.of reads the device locale', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    late String shown;
    await tester.pumpWidget(Builder(builder: (context) {
      shown = RDates.of(context).time(_at);
      return const SizedBox();
    }));
    expect(shown, '9:05 PM');
  });

  test('no pro or shared screen builds a date or time by hand', () {
    // Dates are made in lib/core/format/dates.dart and nowhere else in the
    // pro app. The shared reviews list is the client app's too and is left
    // for its own redesign.
    final pattern = RegExp(r"\.(day|month|year)\}|_months\b|\.(hour|minute)\.toString\(\)\.padLeft|formatMediumDate|formatTimeOfDay|TimeOfDay\.fromDateTime\([^)]*\)\.format");
    final offenders = <String>[];
    for (final root in ['lib/features/pro', 'lib/features/shared/meet', 'lib/features/shared/chat']) {
      for (final f in Directory(root).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart') || f.path.endsWith('.g.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (pattern.hasMatch(lines[i]) && !lines[i].contains('// wire format')) offenders.add('${f.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
