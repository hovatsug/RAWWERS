import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/client/gallery/addon_window.dart';

void main() {
  final now = DateTime.utc(2026, 11, 7, 12);

  test('days and hours while more than a day is left', () {
    expect(addonBanner(now.add(const Duration(days: 6, hours: 4, minutes: 30)), now: now), 'Add more photos · 6 days 4 h left');
    expect(addonTimeLeft(now.add(const Duration(days: 1, minutes: 5)), now: now), '1 day 0 h left');
  });

  test('hours in the last day, then under an hour', () {
    expect(addonTimeLeft(now.add(const Duration(hours: 23, minutes: 59)), now: now), '23 h left');
    expect(addonTimeLeft(now.add(const Duration(hours: 1)), now: now), '1 h left');
    expect(addonTimeLeft(now.add(const Duration(minutes: 59)), now: now), 'Less than 1 h left');
  });

  test('closed at and after the end', () {
    expect(addonTimeLeft(now, now: now), isNull);
    expect(addonBanner(now.subtract(const Duration(days: 1)), now: now), 'Gallery closed');
  });
}
