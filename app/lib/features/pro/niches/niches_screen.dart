import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_niche_view.dart';
import 'package:rawwers/api/models/update_my_niches_response.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/niches/my_niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';

/// Choosing and managing niches (BETA_SCOPE "Pro app: choose and manage
/// niches", owner's addition of 2026-11-17).
///
/// Onboarding needs at least one niche, and until this screen the only ways
/// to get one were the Lightroom plug-in and an API route no screen called.
/// Here a photographer sees their niches, adds one from the active list,
/// removes one and chooses the main one. The rules are the server's (the
/// maximum, the minimum, one main niche, no removal while a booking in that
/// niche is not finished); when one refuses, its sentence is shown as it is.
class NichesScreen extends ConsumerStatefulWidget {
  const NichesScreen({super.key});

  @override
  ConsumerState<NichesScreen> createState() => _NichesScreenState();
}

class _NichesScreenState extends ConsumerState<NichesScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<String?> Function() change) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await change();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  Future<void> _add(UpdateMyNichesResponse mine) async {
    final slug = await showRSheet<String>(
      context,
      builder: (context) => _AddNicheSheet(owned: {for (final n in mine.niches ?? const <ProNicheView>[]) n.slug}),
    );
    if (slug == null || !mounted) return;
    await _run(() => ref.read(myNichesControllerProvider.notifier).add(slug));
  }

  Future<void> _remove(ProNicheView niche) async {
    final confirmed = await showRConfirmDialog(
      context,
      title: 'Remove ${niche.name}?',
      message: 'Clients will no longer find you under ${niche.name}. '
          'Your photos tagged ${niche.name} stay in your portfolio, and your packages stay as they are. '
          'A Lightroom collection that publishes to ${niche.name} will stop until you choose another niche for it. '
          'You can add ${niche.name} back later.',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref.read(myNichesControllerProvider.notifier).remove(niche.slug));
  }

  @override
  Widget build(BuildContext context) {
    final mine = ref.watch(myNichesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your niches')),
      body: SafeArea(
        child: switch (mine) {
          AsyncData(:final value) => _List(
              mine: value,
              busy: _busy,
              error: _error,
              onAdd: () => _add(value),
              onRemove: _remove,
              onMakeMain: (niche) => _run(() => ref.read(myNichesControllerProvider.notifier).makeMain(niche.slug)),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your niches.',
              onRetry: () => ref.invalidate(myNichesControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: RSize.lineLong), SizedBox(height: RSpace.s16), RSkeleton(width: RSize.lineMedium)],
              ),
            ),
        },
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.mine,
    required this.busy,
    required this.error,
    required this.onAdd,
    required this.onRemove,
    required this.onMakeMain,
  });

  final UpdateMyNichesResponse mine;
  final bool busy;
  final String? error;
  final VoidCallback onAdd;
  final ValueChanged<ProNicheView> onRemove;
  final ValueChanged<ProNicheView> onMakeMain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final niches = [...?mine.niches]..sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final maximum = mine.maximum;
    final minimum = mine.minimum ?? 1;
    final canAdd = maximum == null || niches.length < maximum;

    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        Text(
          'The kinds of shoot clients find you under. Your main niche comes first on your profile.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: RSpace.s8),
        Text(
          [
            if (maximum != null) 'You can have up to $maximum.',
            'You need at least $minimum.',
          ].join(' '),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: RSpace.s16),
        if (error != null) ...[
          Text(error!, key: const Key('niches-error'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s16),
        ],
        if (niches.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: RSpace.s16),
            child: Text('No niches yet. Add the kind of shoot you do.', style: theme.textTheme.bodyMedium),
          ),
        for (final niche in niches)
          Padding(
            padding: const EdgeInsets.only(bottom: RSpace.s12),
            child: RCard(
              child: Row(
                children: [
                  Expanded(child: Text(niche.name, style: theme.textTheme.titleSmall)),
                  if (niche.isPrimary)
                    const RStatusChip(label: 'Main', kind: RStatusChipKind.inProgress)
                  else
                    TextButton(
                      onPressed: busy ? null : () => onMakeMain(niche),
                      child: const Text('Make main'),
                    ),
                  IconButton(
                    onPressed: busy ? null : () => onRemove(niche),
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove ${niche.name}',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: RSpace.s8),
        if (canAdd)
          RButton(label: 'Add a niche', onPressed: busy ? null : onAdd, loading: busy)
        else
          Text('You have the most niches you can ($maximum). Remove one to add another.', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// The active niches the photographer does not have yet; tapping one
/// returns its slug.
class _AddNicheSheet extends ConsumerWidget {
  const _AddNicheSheet({required this.owned});

  final Set<String> owned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final all = ref.watch(nichesControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add a niche', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s12),
          switch (all) {
            AsyncData(:final value) => Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final niche in value.where((n) => !owned.contains(n.slug)))
                      ListTile(
                        title: Text(niche.name),
                        trailing: const Icon(Icons.add),
                        onTap: () => Navigator.of(context).pop(niche.slug),
                      ),
                  ],
                ),
              ),
            AsyncError() => const Text('Could not load the list of niches.'),
            _ => const RSkeleton(width: RSize.lineLong),
          },
        ],
      ),
    );
  }
}
