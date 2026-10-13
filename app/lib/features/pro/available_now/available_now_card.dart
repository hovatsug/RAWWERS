import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/available_now_view.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/available_now/available_now_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';

/// Said every time it is switched on: with no push or email yet, a request
/// reaches the photographer only through the open app.
const listedOnlyWhileOpen = "You're listed only while the app is open.";

/// "Available now" on the photographer's dashboard: can shoot within the
/// next day at short notice. Off, on until a time, and the preparation time
/// that replaces their usual notice. Switching on with no package that may be
/// booked at short notice asks which should - never a toggle that books
/// nothing.
class AvailableNowCard extends ConsumerWidget {
  const AvailableNowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availableNowControllerProvider);
    return switch (state) {
      AsyncData(:final value) => _Card(view: value),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox(height: 72),
    };
  }
}

class _Card extends ConsumerStatefulWidget {
  const _Card({required this.view});

  final AvailableNowView view;

  @override
  ConsumerState<_Card> createState() => _CardState();
}

class _CardState extends ConsumerState<_Card> {
  bool _busy = false;

  Future<void> _set({required bool on, int? prepHours}) async {
    setState(() => _busy = true);
    final notifier = ref.read(availableNowControllerProvider.notifier);
    String? error;
    try {
      error = await notifier.set(on: on, prepHours: prepHours);
    } on NoShortNoticePackages {
      if (!mounted) return;
      final chosen = await showModalBottomSheet<bool>(context: context, builder: (_) => const _ChoosePackages());
      if (chosen == true) error = await notifier.set(on: true, prepHours: prepHours);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = widget.view;
    final until = view.availableUntil;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available now'),
            subtitle: Text(
              view.switchedOn && until != null
                  ? 'Clients can book you at ${view.prepHours} hours’ notice until ${TimeOfDay.fromDateTime(until.toLocal()).format(context)}. $listedOnlyWhileOpen'
                  : 'Take bookings in the next day at short notice, for up to ${view.lastsHours} hours.',
              style: theme.textTheme.bodySmall,
            ),
            value: view.switchedOn,
            onChanged: _busy ? null : (on) => _set(on: on),
          ),
          Row(
            children: [
              Text('Ready in about', style: theme.textTheme.bodySmall),
              const SizedBox(width: RSpace.s8),
              DropdownButton<int>(
                value: view.prepHours,
                items: [for (var h = 1; h <= 6; h++) DropdownMenuItem(value: h, child: Text(h == 1 ? '1 hour' : '$h hours'))],
                onChanged: _busy ? null : (h) => h == null ? null : _set(on: view.switchedOn, prepHours: h),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Which packages may be booked at short notice. Shown when switching on
/// would otherwise do nothing; saving at least one lets it switch on.
class _ChoosePackages extends ConsumerStatefulWidget {
  const _ChoosePackages();

  @override
  ConsumerState<_ChoosePackages> createState() => _ChoosePackagesState();
}

class _ChoosePackagesState extends ConsumerState<_ChoosePackages> {
  final Set<String> _chosen = {};
  bool _saving = false;

  Future<void> _save(List<ProPackageView> packages) async {
    setState(() => _saving = true);
    final packagesController = ref.read(packagesControllerProvider.notifier);
    var ok = true;
    for (final package in packages.where((p) => _chosen.contains(p.id))) {
      if (await packagesController.setShortNotice(package, ok: true) != null) ok = false;
    }
    if (mounted) Navigator.of(context).pop(ok && _chosen.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packages = ref.watch(packagesControllerProvider).valueOrNull ?? const <ProPackageView>[];
    final active = packages.where((p) => p.isActive).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(RSpace.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Which packages can be booked at short notice?', style: theme.textTheme.titleMedium),
            const SizedBox(height: RSpace.s8),
            Text('A full day or a planned block usually cannot. You can change this per package in Pricing.', style: theme.textTheme.bodySmall),
            const SizedBox(height: RSpace.s12),
            for (final package in active)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(package.title),
                subtitle: Text('${package.durationMinutes} min', style: theme.textTheme.bodySmall),
                value: _chosen.contains(package.id),
                onChanged: (on) => setState(() => on == true ? _chosen.add(package.id) : _chosen.remove(package.id)),
              ),
            const SizedBox(height: RSpace.s12),
            FilledButton(
              onPressed: _saving || _chosen.isEmpty ? null : () => _save(active),
              child: const Text('Save and switch on'),
            ),
          ],
        ),
      ),
    );
  }
}
