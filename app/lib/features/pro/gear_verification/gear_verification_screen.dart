import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/gear_category.dart';
import 'package:rawwers/api/models/gear_floor_view.dart';
import 'package:rawwers/api/models/gear_verification_view.dart';
import 'package:rawwers/api/models/verification_status.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gear_verification/gear_verification_controller.dart';

/// Proving the camera and lens that qualify a photographer to take bookings.
///
/// Not the "Your kit" screen: that records what someone owns, for insurance and
/// repairs, and may legitimately hold a crop body. This is what qualifies them,
/// so the two are kept apart the way the server keeps them apart.
///
/// The screen leads with where they stand and what is left, because the
/// alternative - a list of uploads - leaves someone unable to tell whether
/// they are done, waiting, or stuck.
class GearVerificationScreen extends ConsumerWidget {
  const GearVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gear = ref.watch(gearVerificationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your gear')),
      body: SafeArea(
        child: switch (gear) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(gearVerificationControllerProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(RSpace.s16),
                children: [
                  _Explainer(),
                  const SizedBox(height: RSpace.s16),
                  _FloorSummary(floor: value.floor),
                  const SizedBox(height: RSpace.s16),
                  const _SendFile(),
                  const SizedBox(height: RSpace.s24),
                  if ((value.items ?? const []).isNotEmpty) ...[
                    Text('On record', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: RSpace.s12),
                    for (final item in value.items!) ...[
                      _GearRow(item: item),
                      const SizedBox(height: RSpace.s12),
                    ],
                  ],
                  const SizedBox(height: RSpace.s8),
                  RButton(
                    label: 'Add lighting',
                    variant: RButtonVariant.secondary,
                    onPressed: () => _openLighting(context),
                  ),
                  const SizedBox(height: RSpace.s8),
                  Text(
                    'Needed for weddings, product and food. A photograph cannot show what lit it, '
                    'so this is recorded as what you told us, and shown that way.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your gear.',
              onRetry: () => ref.invalidate(gearVerificationControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: 240), SizedBox(height: RSpace.s16), RSkeleton(width: 200)],
              ),
            ),
        },
      ),
    );
  }

  Future<void> _openLighting(BuildContext context) async {
    await showRSheet<void>(
      context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: RSpace.s16,
          right: RSpace.s16,
          top: RSpace.s24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + RSpace.s24,
        ),
        child: const SingleChildScrollView(child: _LightingEditor()),
      ),
    );
  }
}

class _Explainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('One file from your camera', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s8),
          Text(
            // What to send, and what not to, before they pick a 50 MB file.
            'Send the RAW file, or the original JPEG, straight from your camera. '
            'It shows which body and lens made it, so one file proves both. '
            'Screenshots and exports from an editing app will not work.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s8),
          Text(
            'Requirement: one full-frame body, and one lens that is a prime or holds a fixed maximum aperture.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Where they stand against the floor, in the order they would do it.
class _FloorSummary extends StatelessWidget {
  const _FloorSummary({required this.floor});

  final GearFloorView floor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final waiting = floor.awaitingReview > 0;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            floor.meetsFloor ? 'Your gear meets the requirement' : 'Where you stand',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: RSpace.s12),
          _Line(done: floor.hasFullFrameBody, label: 'A full-frame camera body'),
          const SizedBox(height: RSpace.s8),
          _Line(done: floor.hasQualifyingLens, label: 'A prime or fixed-aperture lens'),
          if (floor.lightingRequired) ...[
            const SizedBox(height: RSpace.s8),
            _Line(
              done: floor.hasLighting,
              label: floor.lightingIsDeclared && floor.hasLighting ? 'Lighting (as you described it)' : 'Lighting',
            ),
          ],
          if (waiting) ...[
            const SizedBox(height: RSpace.s12),
            // The wait is the platform's, and the wording says so: nothing here
            // is left for the photographer to do.
            Text(
              floor.awaitingReview == 1
                  ? 'One item is being checked by hand. Nothing more for you to do - we will let you know.'
                  : '${floor.awaitingReview} items are being checked by hand. Nothing more for you to do - we will let you know.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 20,
          color: done ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: RSpace.s12),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// The button, and what its attempt is doing.
class _SendFile extends ConsumerWidget {
  const _SendFile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(gearSubmitControllerProvider);
    final notifier = ref.read(gearSubmitControllerProvider.notifier);
    final busy = state is GearSubmitUploading || state is GearSubmitReading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RButton(
          label: 'Send a file from your camera',
          loading: busy,
          onPressed: busy ? null : notifier.pickAndSend,
        ),
        const SizedBox(height: RSpace.s8),
        switch (state) {
          GearSubmitUploading(:final fraction) => Text(
              'Uploading ${(fraction * 100).round()}%',
              style: theme.textTheme.bodySmall,
            ),
          GearSubmitReading() => Text('Reading your file…', style: theme.textTheme.bodySmall),
          GearSubmitFailed(:final message) => Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          GearSubmitDone(:final notes) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Done. Here is what that file showed.', style: theme.textTheme.bodySmall),
                for (final note in notes) Text(note, style: theme.textTheme.bodySmall),
              ],
            ),
          GearSubmitIdle() => const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _GearRow extends ConsumerWidget {
  const _GearRow({required this.item});

  final GearVerificationView item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (label, kind) = _statusFor(item.status);
    final name = [item.make, item.model].whereType<String>().where((p) => p.isNotEmpty).join(' ');

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name.isEmpty ? _categoryLabel(item.category) : name, style: theme.textTheme.titleSmall),
              ),
              RStatusChip(label: label, kind: kind),
            ],
          ),
          const SizedBox(height: RSpace.s4),
          Text(
            [_categoryLabel(item.category), if (item.serialHint != null) 'Serial ${item.serialHint}'].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
          if (item.status == VerificationStatus.pendingReview) ...[
            const SizedBox(height: RSpace.s8),
            Text(
              // Not the machine's reason verbatim: "published no serial" is
              // true and reads like an accusation. What matters to them is
              // that a person is looking and they have nothing to do.
              'A person at RAWWERS is checking this by hand. You do not need to do anything.',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (item.status == VerificationStatus.rejected && (item.reviewReason ?? '').isNotEmpty) ...[
            const SizedBox(height: RSpace.s8),
            Text(item.reviewReason!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ],
          if (item.status == VerificationStatus.declared) ...[
            const SizedBox(height: RSpace.s8),
            Text('Recorded from your description. It cannot be checked from a photo.', style: theme.textTheme.bodySmall),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _remove(context, ref, name),
              child: Text(item.status == VerificationStatus.rejected ? 'Remove and try again' : 'Remove'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, String name) async {
    final confirmed = await showRConfirmDialog(
      context,
      title: 'Remove this?',
      message: name.isEmpty
          ? 'It will no longer count toward your requirement.'
          : '$name will no longer count toward your requirement.',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref.read(gearVerificationControllerProvider.notifier).release(item.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

(String, RStatusChipKind) _statusFor(VerificationStatus status) => switch (status) {
      VerificationStatus.verified => ('Verified', RStatusChipKind.positive),
      VerificationStatus.declared => ('As you described', RStatusChipKind.inProgress),
      VerificationStatus.pendingReview => ('Being checked', RStatusChipKind.inProgress),
      VerificationStatus.rejected => ('Not accepted', RStatusChipKind.stopped),
    };

String _categoryLabel(GearCategory category) => switch (category) {
      GearCategory.cameraBody => 'Camera body',
      GearCategory.lens => 'Lens',
      GearCategory.lighting => 'Lighting',
      _ => 'Equipment',
    };

class _LightingEditor extends ConsumerStatefulWidget {
  const _LightingEditor();

  @override
  ConsumerState<_LightingEditor> createState() => _LightingEditorState();
}

class _LightingEditorState extends ConsumerState<_LightingEditor> {
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_make, _model, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_model.text.trim().isEmpty) {
      setState(() => _error = 'Say which lighting you use.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref
        .read(gearVerificationControllerProvider.notifier)
        .declareLighting(make: _make.text, model: _model.text, notes: _notes.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your lighting', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s8),
        Text(
          'A photograph cannot show what lit it, so we record what you tell us and say so.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Brand (optional)', controller: _make),
        const SizedBox(height: RSpace.s12),
        RInput(label: 'Model', controller: _model),
        const SizedBox(height: RSpace.s12),
        RInput(label: 'Anything else (optional)', controller: _notes, maxLines: 2),
        if (_error != null) ...[
          const SizedBox(height: RSpace.s12),
          Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: RSpace.s16),
        RButton(label: 'Save', loading: _saving, onPressed: _saving ? null : _save),
      ],
    );
  }
}
