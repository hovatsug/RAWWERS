import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_profile_package.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/booking_request/booking_request_controller.dart';

/// Asks for the one thing the client actually has to decide: when.
///
/// Everything else the request needs is already known - the package fixes the
/// duration and the niche, the profile fixes the photographer and the city -
/// so the form does not ask for it. The end time is derived from the
/// package's `duration_minutes` rather than picked, because a client choosing
/// an end time that contradicts the package they just chose is a
/// contradiction the form should not allow in the first place.
Future<String?> showBookingRequestSheet(
  BuildContext context, {
  required String proUserId,
  required String proName,
  required ClientProfilePackage package,
  String? defaultLocation,
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
  });

  final String proUserId;
  final String proName;
  final ClientProfilePackage package;
  final String? defaultLocation;

  @override
  ConsumerState<_BookingRequestForm> createState() => _BookingRequestFormState();
}

class _BookingRequestFormState extends ConsumerState<_BookingRequestForm> {
  late final TextEditingController _location = TextEditingController(text: widget.defaultLocation ?? '');
  final _notes = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime? get _startAt {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime? get _endAt {
    final start = _startAt;
    if (start == null) return null;
    return start.add(Duration(minutes: widget.package.durationMinutes));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      // A shoot in the past is not a request anyone means to send.
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final start = _startAt;
    final end = _endAt;
    if (start == null || end == null) {
      setState(() => _error = 'Pick a date and a start time.');
      return;
    }
    if (start.isBefore(DateTime.now())) {
      setState(() => _error = 'That time has already passed. Pick a later one.');
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
    final start = _startAt;
    final end = _endAt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request ${widget.package.title}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'with ${widget.proName} · €${widget.package.price} · ${_duration(widget.package.durationMinutes)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s24),
          _PickerRow(
            label: 'Date',
            value: _date == null ? 'Choose a date' : _formatDate(_date!),
            onTap: _pickDate,
          ),
          const SizedBox(height: RSpace.s12),
          _PickerRow(
            label: 'Start time',
            value: _time == null ? 'Choose a time' : _time!.format(context),
            onTap: _pickTime,
          ),
          if (start != null && end != null) ...[
            const SizedBox(height: RSpace.s8),
            Text(
              'Ends around ${_formatTime(end)}, based on the package length.',
              style: theme.textTheme.bodySmall,
            ),
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

class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RSpace.s12),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(value, style: theme.textTheme.bodyMedium),
            const SizedBox(width: RSpace.s8),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
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

String _formatDate(DateTime date) => '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

String _formatTime(DateTime at) =>
    '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
