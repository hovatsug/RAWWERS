import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/delivery_device_view.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/lightroom/connect_lightroom_controller.dart';

/// Settings > Connect Lightroom: a one-time code for the Lightroom Classic
/// plug-in, and the devices already connected, each with Revoke.
///
/// The plug-in never sees the photographer's password: they type this code
/// into Lightroom's Export dialog once, and that Mac can deliver photos into
/// their gigs until it is revoked here (or goes 90 days unused).
class ConnectLightroomScreen extends ConsumerWidget {
  const ConnectLightroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final devices = ref.watch(lightroomDevicesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Lightroom')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(lightroomDevicesControllerProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(RSpace.s16),
            children: [
              Text(
                'Deliver a gig’s photos straight from Lightroom Classic: File > Export, Export To: RAWWERS. '
                'Photos arrive in the gig’s delivery; nothing reaches the client until you send it from here.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: RSpace.s16),
              const _PairingCodeCard(),
              const SizedBox(height: RSpace.s24),
              Text('Connected devices', style: theme.textTheme.titleMedium),
              const SizedBox(height: RSpace.s8),
              switch (devices) {
                AsyncData(:final value) when value.items.isEmpty => Text(
                    'No device is connected yet.',
                    style: theme.textTheme.bodySmall,
                  ),
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final device in value.items) ...[
                        _DeviceRow(device: device),
                        const SizedBox(height: RSpace.s8),
                      ],
                      Text(
                        'Up to ${value.maxDevices} devices. A device unused for 90 days is disconnected on its own.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                AsyncError() => RErrorState(
                    message: 'Could not load your devices.',
                    onRetry: () => ref.invalidate(lightroomDevicesControllerProvider),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.all(RSpace.s16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _PairingCodeCard extends ConsumerWidget {
  const _PairingCodeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(pairingCodeControllerProvider);
    final notifier = ref.read(pairingCodeControllerProvider.notifier);
    final code = state.valueOrNull;
    final loading = state.isLoading;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pairing code', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          if (code != null) ...[
            Semantics(
              label: 'Pairing code ${code.code.split('').join(' ')}',
              child: SelectableText(
                code.code,
                key: const ValueKey('pairing-code'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFeatures: RType.tabularFigures,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: RSpace.s8),
            Text(
              'Type it into Lightroom’s Export dialog, in the RAWWERS section. '
              'It works once, until ${RDates.of(context).time(code.expiresAt)} '
              '(${code.validMinutes} minutes).',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: RSpace.s8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code.code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied.')));
              },
              icon: const Icon(Icons.copy, size: RIcon.inline),
              label: const Text('Copy code'),
            ),
          ] else
            Text(
              'Get a code, then type it into Lightroom Classic. You only do this once per Mac.',
              style: theme.textTheme.bodySmall,
            ),
          if (state case AsyncError(:final error)) ...[
            const SizedBox(height: RSpace.s8),
            Text('$error', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: RSpace.s12),
          RButton(
            label: code == null ? 'Get a pairing code' : 'Get a new code',
            loading: loading,
            variant: code == null ? RButtonVariant.primary : RButtonVariant.secondary,
            onPressed: loading ? null : notifier.issue,
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends ConsumerStatefulWidget {
  const _DeviceRow({required this.device});

  final DeliveryDeviceView device;

  @override
  ConsumerState<_DeviceRow> createState() => _DeviceRowState();
}

class _DeviceRowState extends ConsumerState<_DeviceRow> {
  bool _busy = false;

  Future<void> _revoke() async {
    final device = widget.device;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Revoke ${device.deviceName}?'),
        content: const Text(
          'It stops delivering at once, mid-export too. Photos already uploaded stay in their gigs. '
          'To use it again, connect it with a new code.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Revoke')),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final problem = await ref.read(lightroomDevicesControllerProvider.notifier).revoke(device.id);
    if (mounted) setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(problem ?? '${device.deviceName} was revoked.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final device = widget.device;
    final dates = RDates.of(context);
    final version = device.pluginVersion;
    return RCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.deviceName, style: theme.textTheme.bodyMedium),
                const SizedBox(height: RSpace.s4),
                Text(
                  'Last used ${dates.dateTime(device.lastUsedAt)}'
                  '${version == null ? '' : ' · plug-in $version'} · ${device.tokenPrefix}…',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: RSpace.s12),
          ConstrainedBox(
            // RButton takes an infinite minimum width from the theme.
            constraints: const BoxConstraints(maxWidth: 110),
            child: RButton(
              label: 'Revoke',
              variant: RButtonVariant.secondary,
              loading: _busy,
              onPressed: _busy ? null : _revoke,
            ),
          ),
        ],
      ),
    );
  }
}
