import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

/// The first thing a photographer sees after registering on the pro app -
/// every account starts as client-only (checked against the real backend:
/// register always grants the client role, never pro), so this is a real
/// step everyone who signs up here takes, not an edge case.
class UpgradeToProScreen extends ConsumerStatefulWidget {
  const UpgradeToProScreen({super.key});

  @override
  ConsumerState<UpgradeToProScreen> createState() => _UpgradeToProScreenState();
}

class _UpgradeToProScreenState extends ConsumerState<UpgradeToProScreen> {
  String? _error;
  bool _submitting = false;

  Future<void> _upgrade() async {
    setState(() {
      _error = null;
      _submitting = true;
    });

    final error = await ref.read(authControllerProvider.notifier).upgradeToPro();

    if (!mounted) return;
    setState(() {
      _error = error;
      _submitting = false;
    });
    // On success the router's redirect reacts to the role now being
    // present on the refreshed /v1/me - no explicit navigation here.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RSpace.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Set up your pro account', style: theme.textTheme.displaySmall),
              const SizedBox(height: RSpace.s24),
              const _Point(text: 'Enter at a tier that reflects the work you\'ve already done, not a fresh start.'),
              const SizedBox(height: RSpace.s16),
              const _Point(text: 'Work new niches without touching your own brand or portfolio.'),
              const SizedBox(height: RSpace.s16),
              const _Point(text: 'Earnings convert toward gear - cameras, lenses, the kit you actually need.'),
              const SizedBox(height: RSpace.s32),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                const SizedBox(height: RSpace.s16),
              ],
              RButton(label: 'Set up my pro account', onPressed: _submitting ? null : _upgrade, loading: _submitting),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyLarge);
  }
}
