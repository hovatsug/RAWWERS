import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/problem_report_reason.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/gallery/unlock_controller.dart';

/// What "Report a problem" offers, in this order, in the client's words.
const problemReasonLabels = {
  ProblemReportReason.photosMissing: 'Photos are missing',
  ProblemReportReason.wrongPhotos: "These aren't my photos",
  ProblemReportReason.quality: "The quality isn't right",
  ProblemReportReason.notAsAgreed: "It's not what we agreed",
  ProblemReportReason.other: 'Something else',
};

/// The review gate, in the delivered gallery: "Rate your photographer to
/// unlock your photos". One tap on a star unlocks them; "Report a problem"
/// unlocks them too. [onUnlocked] runs once the server has accepted either.
class UnlockPanel extends ConsumerWidget {
  const UnlockPanel({required this.galleryId, required this.gigId, this.onUnlocked, super.key});

  final String galleryId;
  final String gigId;
  final VoidCallback? onUnlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sending = ref.watch(unlockControllerProvider(galleryId));

    Future<void> rate(int stars) async {
      final messenger = ScaffoldMessenger.of(context);
      final problem = await ref.read(unlockControllerProvider(galleryId).notifier).rate(gigId: gigId, stars: stars);
      if (problem != null) {
        messenger.showSnackBar(SnackBar(content: Text(problem)));
      } else {
        onUnlocked?.call();
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Rate your photographer to unlock your photos', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: RSpace.s8),
        Text('One tap is enough.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: RSpace.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var stars = 1; stars <= 5; stars++)
              IconButton(
                key: ValueKey('unlock-star-$stars'),
                tooltip: stars == 1 ? '1 star' : '$stars stars',
                iconSize: 40,
                icon: Icon(Icons.star_border_rounded, color: theme.colorScheme.primary),
                onPressed: sending ? null : () => rate(stars),
              ),
          ],
        ),
        const SizedBox(height: RSpace.s8),
        TextButton(
          onPressed: sending
              ? null
              : () async {
                  final reported = await showReportProblemSheet(context, galleryId: galleryId, gigId: gigId);
                  if (reported) onUnlocked?.call();
                },
          child: const Text('Report a problem'),
        ),
      ],
    );
  }
}

/// The same panel in a sheet, for "Save all": true once the photos are
/// unlocked, so the save can carry on.
Future<bool> showUnlockSheet(BuildContext context, {required String galleryId, required String gigId}) async {
  final unlocked = await showRSheet<bool>(
    context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: UnlockPanel(
        galleryId: galleryId,
        gigId: gigId,
        onUnlocked: () => Navigator.of(sheetContext).pop(true),
      ),
    ),
  );
  return unlocked ?? false;
}

/// "Report a problem": a reason from the list and an optional note. True
/// once sent - the photos are unlocked and an admin looks at it.
Future<bool> showReportProblemSheet(BuildContext context, {required String galleryId, required String gigId}) async {
  final sent = await showRSheet<bool>(
    context,
    builder: (sheetContext) => _ReportProblemForm(galleryId: galleryId, gigId: gigId),
  );
  return sent ?? false;
}

class _ReportProblemForm extends ConsumerStatefulWidget {
  const _ReportProblemForm({required this.galleryId, required this.gigId});

  final String galleryId;
  final String gigId;

  @override
  ConsumerState<_ReportProblemForm> createState() => _ReportProblemFormState();
}

class _ReportProblemFormState extends ConsumerState<_ReportProblemForm> {
  final _note = TextEditingController();
  ProblemReportReason? _reason;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    final problem = await ref
        .read(unlockControllerProvider(widget.galleryId).notifier)
        .report(gigId: widget.gigId, reason: reason, note: _note.text);
    if (!mounted) return;
    if (problem == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = problem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sending = ref.watch(unlockControllerProvider(widget.galleryId));
    return Padding(
      padding: EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, RSpace.s16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Report a problem', style: theme.textTheme.titleMedium),
            const SizedBox(height: RSpace.s4),
            Text(
              'Your photos unlock now. RAWWERS looks into it, and the photographer is not paid for this booking until we have.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: RSpace.s12),
            for (final MapEntry(key: reason, value: label) in problemReasonLabels.entries)
              ListTile(
                title: Text(label),
                selected: _reason == reason,
                trailing: _reason == reason ? const Icon(Icons.check_rounded) : null,
                onTap: sending ? null : () => setState(() => _reason = reason),
              ),
            const SizedBox(height: RSpace.s8),
            RInput(label: 'Anything to add (optional)', controller: _note, maxLines: 3),
            if (_error != null) ...[
              const SizedBox(height: RSpace.s8),
              Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: RSpace.s16),
            RButton(label: 'Send and unlock my photos', onPressed: _reason == null || sending ? null : _send, loading: sending),
          ],
        ),
      ),
    );
  }
}
