import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_profile_update_request.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

/// How much of their own earnings a photographer passes back to the client.
///
/// Sits above the package list rather than inside a package: it is one
/// standing decision about how they work, not a property of any one shoot.
/// A photographer can still be more generous on a particular booking when
/// they accept it.
///
/// The money is explicitly theirs, not the platform's, and the copy says so.
/// The alternative reading - that this is a discount the platform funds - is
/// the one a photographer would be annoyed to discover later.
///
/// The cap comes from the server alongside the value. The app does not carry
/// its own copy of a limit an admin can change.
class ClientCreditCard extends ConsumerWidget {
  const ClientCreditCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(proProfileControllerProvider);

    return switch (profile) {
      AsyncData(:final ProProfileView value) => _Editor(profile: value),
      AsyncError() => const SizedBox.shrink(),
      _ => const RCard(child: RSkeleton(height: 72)),
    };
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.profile});

  final ProProfileView profile;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late int _percent = widget.profile.clientCreditPercent;
  bool _saving = false;
  String? _error;

  int get _cap => widget.profile.maxClientCreditPercent;

  Future<void> _save(int next) async {
    setState(() {
      _percent = next;
      _saving = true;
      _error = null;
    });

    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.updateMyProProfileV1ProMeProfilePut(
        requestBody: ProProfileUpdateRequest(clientCreditPercent: next),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        ref.read(proProfileControllerProvider.notifier).replaceWith(value);
        setState(() => _saving = false);
      case Err():
        setState(() {
          _saving = false;
          // Back to what the server still holds, so the control never shows a
          // number that was not saved.
          _percent = widget.profile.clientCreditPercent;
          _error = 'Could not save that. Check your connection and try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Give clients credit', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'A share of what you earn, returned to your client as RAWW credit '
            'they can spend on their next shoot. It comes out of your payment, '
            'not the platform fee.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: RSpace.s12),
          Row(
            children: [
              Text(
                '$_percent%',
                style: theme.textTheme.headlineSmall?.copyWith(fontFeatures: RType.tabularFigures),
              ),
              const SizedBox(width: RSpace.s12),
              Expanded(
                child: Slider(
                  value: _percent.toDouble(),
                  min: 0,
                  // Whole points only. A photographer cannot tell 7% from
                  // 7.5% on an invoice, and the server rejects fractions.
                  divisions: _cap,
                  max: _cap.toDouble(),
                  label: '$_percent%',
                  onChanged: _saving ? null : (v) => setState(() => _percent = v.round()),
                  onChangeEnd: _saving ? null : (v) => _save(v.round()),
                ),
              ),
            ],
          ),
          Text(
            _percent == 0
                // Never phrased as a failing. Zero is a normal choice and the
                // client is never told a photographer gives nothing.
                ? 'You keep your full payment.'
                : 'On a €1,000 booking your client gets €${(_percent * 10)} in credit.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (_error != null) ...[
            const SizedBox(height: RSpace.s8),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: RShade.shade600)),
          ],
        ],
      ),
    );
  }
}
