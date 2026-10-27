import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/finding_view.dart';
import 'package:rawwers/api/models/my_findings_response.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/findings/findings_controller.dart';

/// Findings about photos sold but not delivered, on the You tab, where the
/// photographer will see them - with the strike count, any pause and its
/// reason, and a way to respond. Only their own; never shown to clients.
///
/// Absent when there is nothing to say: no findings, no pause.
class FindingsCard extends ConsumerWidget {
  const FindingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(findingsControllerProvider);
    return switch (state) {
      AsyncData(:final MyFindingsResponse value) when value.items.isEmpty && value.pause == null => const SizedBox.shrink(),
      AsyncData(:final MyFindingsResponse value) => _Card(data: value),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.data});

  final MyFindingsResponse data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Findings on your account', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s4),
          Text(
            // The window strikes count over is policy, so it is not stated here.
            data.strikes == 0 ? 'No strikes.' : '${data.strikes} ${data.strikes == 1 ? 'strike' : 'strikes'} counting now.',
            style: theme.textTheme.bodySmall,
          ),
          if (data.pause case final pause?) ...[
            const SizedBox(height: RSpace.s12),
            Text('New bookings are paused', style: theme.textTheme.titleSmall),
            Text(pause.reason, style: theme.textTheme.bodyMedium),
          ],
          for (final finding in data.items) ...[
            const SizedBox(height: RSpace.s12),
            _FindingTile(finding: finding),
          ],
        ],
      ),
    );
  }
}

class _FindingTile extends ConsumerStatefulWidget {
  const _FindingTile({required this.finding});

  final FindingView finding;

  @override
  ConsumerState<_FindingTile> createState() => _FindingTileState();
}

class _FindingTileState extends ConsumerState<_FindingTile> {
  @override
  void initState() {
    super.initState();
    // The window to respond starts when they first see it - which is now.
    if (widget.finding.firstSeenAt == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(findingsControllerProvider.notifier).markSeen(widget.finding.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = widget.finding;
    final pending = f.status == 'pending';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.reason, style: theme.textTheme.titleSmall),
        Text(f.note, style: theme.textTheme.bodyMedium),
        const SizedBox(height: RSpace.s4),
        Text(_statusLine(RDates.of(context), f), style: theme.textTheme.bodySmall),
        if (f.response != null) Text('You said: ${f.response}', style: theme.textTheme.bodySmall),
        if (pending && f.response == null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => _respond(context), child: const Text('Respond')),
          ),
      ],
    );
  }

  String _statusLine(RDates dates, FindingView f) {
    final by = dates.dayMonth(DateTime.parse(f.windowEndsAt));
    return switch (f.status) {
      'pending' => 'Nothing takes effect before $by. You can respond until then.',
      'withdrawn' => 'Withdrawn. No strike.',
      _ => switch (f.consequence) {
          'warning' => 'Confirmed: a warning.',
          'booking_pause' => 'Confirmed: new bookings paused.',
          'suspension_review' => 'Confirmed: your account is under review.',
          _ => 'Confirmed. It takes effect on $by.',
        },
    };
  }

  Future<void> _respond(BuildContext context) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your response'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'What happened'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text), child: const Text('Send')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !context.mounted) return;
    final error = await ref.read(findingsControllerProvider.notifier).respond(widget.finding.id, text.trim());
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
