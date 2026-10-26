import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/available_now_view.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_switch.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/available_now/available_now_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';

/// Said every time it is switched on: with no push or email yet, a request
/// reaches the photographer only through the open app.
const listedOnlyWhileOpen = "You're listed only while the app is open.";

/// A preparation time as the photographer reads it: 90 -> "1.5 hours".
String prepLabel(int minutes) {
  final hours = minutes / 60;
  final number = hours == hours.roundToDouble() ? hours.round().toString() : hours.toString();
  return '$number ${hours == 1 ? 'hour' : 'hours'}';
}

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
      // Never nothing: a card that silently disappears reads as a feature
      // that does not exist, and the photographer cannot switch on.
      AsyncError() => _LoadFailed(onRetry: () => ref.invalidate(availableNowControllerProvider)),
      _ => const SizedBox(height: 72),
    };
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available now', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s4),
          Text('Could not load whether you are available now.', style: theme.textTheme.bodySmall),
          const SizedBox(height: RSpace.s8),
          RButton(label: 'Retry', variant: RButtonVariant.secondary, onPressed: onRetry),
        ],
      ),
    );
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

  Future<void> _set({required bool on, int? prepMinutes}) async {
    setState(() => _busy = true);
    final notifier = ref.read(availableNowControllerProvider.notifier);
    String? error;
    try {
      error = await notifier.set(on: on, prepMinutes: prepMinutes);
    } on NoShortNoticePackages {
      if (!mounted) return;
      final chosen = await showModalBottomSheet<bool>(context: context, builder: (_) => const _ChoosePackages());
      if (chosen == true) error = await notifier.set(on: true, prepMinutes: prepMinutes);
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
          // The same control as before - on, off, busy - drawn as the pro
          // app's rectangular switch.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available now', style: theme.textTheme.titleMedium),
                    const SizedBox(height: RSpace.s4),
                    Text(
                      view.switchedOn && until != null
                          ? 'Clients can book you at ${prepLabel(view.prepMinutes)}’ notice until ${TimeOfDay.fromDateTime(until.toLocal()).format(context)}. $listedOnlyWhileOpen'
                          : 'Take bookings in the next day at short notice, for up to ${view.lastsHours} hours.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RSpace.s8),
              RSwitch(
                value: view.switchedOn,
                semanticLabel: 'Available now',
                onChanged: _busy ? null : (on) => _set(on: on),
              ),
            ],
          ),
          Row(
            children: [
              Flexible(child: Text('Ready in about', style: theme.textTheme.bodySmall)),
              const SizedBox(width: RSpace.s8),
              // The server's options - the minimum is a rule there, not here.
              DropdownButton<int>(
                value: view.prepMinutes,
                items: [
                  for (final minutes in view.prepOptionsMinutes)
                    DropdownMenuItem(value: minutes, child: Text(prepLabel(minutes))),
                ],
                onChanged: _busy ? null : (m) => m == null ? null : _set(on: view.switchedOn, prepMinutes: m),
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
