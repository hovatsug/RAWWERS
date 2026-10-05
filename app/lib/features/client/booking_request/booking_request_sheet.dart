import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_package_price.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/booking_request/booking_request_controller.dart';
import 'package:rawwers/features/client/pro_profile/availability_calendar.dart';

/// Asks for the one thing the client actually has to decide: when.
///
/// Everything else the request needs is already known - the package fixes the
/// duration and the niche, the profile fixes the photographer and the city -
/// so the form does not ask for it. The end time is derived from the
/// package's `duration_minutes` rather than picked, because a client choosing
/// an end time that contradicts the package they just chose is a
/// contradiction the form should not allow in the first place.
///
/// "When" is chosen from the photographer's real availability, never a bare
/// date picker: the server refuses any time it did not offer. A time already
/// picked on the profile arrives as [initialPick] and is not asked again.
Future<String?> showBookingRequestSheet(
  BuildContext context, {
  required String proUserId,
  required String proName,
  required ClientProfilePackage package,
  String? defaultLocation,
  PickedStart? initialPick,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _BookingRequestForm(
        proUserId: proUserId,
        proName: proName,
        package: package,
        defaultLocation: defaultLocation,
        initialPick: initialPick,
      ),
    ),
  );
}

class _BookingRequestForm extends ConsumerStatefulWidget {
  const _BookingRequestForm({
    required this.proUserId,
    required this.proName,
    required this.package,
    this.defaultLocation,
    this.initialPick,
  });

  final String proUserId;
  final String proName;
  final ClientProfilePackage package;
  final String? defaultLocation;
  final PickedStart? initialPick;

  @override
  ConsumerState<_BookingRequestForm> createState() => _BookingRequestFormState();
}

class _BookingRequestFormState extends ConsumerState<_BookingRequestForm> {
  late final TextEditingController _location = TextEditingController(text: widget.defaultLocation ?? '');
  final _notes = TextEditingController();

  late PickedStart? _pick = widget.initialPick;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// The instant the server offered - parsed, not rebuilt from a local date
  /// and time, so it cannot drift by the phone's time zone.
  DateTime? get _startAt => _pick?.start.startAt;

  DateTime? get _endAt => _startAt?.add(Duration(minutes: widget.package.durationMinutes));

  Future<void> _submit() async {
    final start = _startAt;
    final end = _endAt;
    if (start == null || end == null) {
      setState(() => _error = 'Pick a start time.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    final outcome = await ref.read(bookingRequestControllerProvider.notifier).submit(
          proUserId: widget.proUserId,
          packageId: widget.package.id,
          nicheSlug: widget.package.nicheSlug,
          startAt: start,
          endAt: end,
          location: _location.text,
          notes: _notes.text,
        );

    if (!mounted) return;

    switch (outcome) {
      case BookingRequestSent(:final bookingId):
        Navigator.of(context).pop(bookingId);
      case BookingRequestFailed(:final message):
        setState(() {
          _sending = false;
          _error = message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pick = _pick;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request ${widget.package.title}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'with ${widget.proName} · ${_duration(widget.package.durationMinutes)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s12),
          // The last screen before someone commits, so the price has to be
          // the real one. It previously showed package.price here too - the
          // per-photo rate, presented as the cost of the booking.
          RPackagePrice(
            entryRate: widget.package.entryRate,
            minimumPhotos: widget.package.minimumPhotos,
            startingTotal: widget.package.startingTotal,
            currency: widget.package.currency,
          ),
          const SizedBox(height: RSpace.s24),
          if (pick == null)
            AvailabilityCalendar(
              proUserId: widget.proUserId,
              proName: widget.proName,
              packageId: widget.package.id,
              onPick: (picked) => setState(() {
                _pick = picked;
                _error = null;
              }),
            )
          else ...[
            Text(pick.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: RSpace.s4),
            Text(
              '${timezoneCity(pick.timezone)} time · ends around '
              '${_endsAround(pick.start.localTime, widget.package.durationMinutes)}, based on the package length.',
              style: theme.textTheme.bodySmall,
            ),
            RTextLink(label: 'Change time', onPressed: () => setState(() => _pick = null)),
          ],
          const SizedBox(height: RSpace.s16),
          RInput(label: 'Where is the shoot?', controller: _location),
          const SizedBox(height: RSpace.s12),
          RInput(label: 'Anything they should know? (optional)', controller: _notes, maxLines: 3),
          if (_error != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: RShade.shade600)),
          ],
          const SizedBox(height: RSpace.s16),
          Text(
            '${widget.proName} has 24 hours to reply. You only pay once they accept.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: RSpace.s16),
          RButton(label: 'Send request', loading: _sending, onPressed: _sending ? null : _submit),
        ],
      ),
    );
  }
}

String _duration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  final hourLabel = hours == 1 ? '1 hour' : '$hours hours';
  return rest == 0 ? hourLabel : '$hourLabel $rest min';
}

/// The local end time, from the local start: "10:00" + 90 min -> "11:30".
/// Wall-clock arithmetic in the photographer's day, which is what they and
/// the client both read.
String _endsAround(String localStart, int minutes) {
  final parts = localStart.split(':');
  final total = (int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes) % (24 * 60);
  return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
}
