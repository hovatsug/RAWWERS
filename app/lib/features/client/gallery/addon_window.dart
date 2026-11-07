/// How long is left to add photos after the selection closed, as the gallery
/// and the booking card say it: "6 days 4 h left", hours in the last day,
/// "Less than 1 h left" in the last hour, and null once it has ended.
String? addonTimeLeft(DateTime endsAt, {DateTime? now}) {
  final left = endsAt.difference(now ?? DateTime.now());
  if (left <= Duration.zero) return null;
  final days = left.inDays;
  final hours = left.inHours - days * 24;
  if (days >= 1) return '$days ${days == 1 ? 'day' : 'days'} $hours h left';
  if (left.inHours >= 1) return '${left.inHours} h left';
  return 'Less than 1 h left';
}

/// The banner over the gallery and on the booking card.
String addonBanner(DateTime endsAt, {DateTime? now}) {
  final left = addonTimeLeft(endsAt, now: now);
  return left == null ? 'Gallery closed' : 'Add more photos · $left';
}
