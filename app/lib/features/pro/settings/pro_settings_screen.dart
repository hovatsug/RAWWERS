import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

class ProSettingsScreen extends ConsumerWidget {
  const ProSettingsScreen({required this.verifyEmailPath, super.key});

  final String verifyEmailPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = switch (ref.watch(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(RSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (me?.email != null) Text(me!.email!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: RSpace.s16),
            RTextLink(label: 'Verify email', onPressed: () => context.go(verifyEmailPath)),
            const Spacer(),
            RButton(label: 'Log out', onPressed: () => ref.read(authControllerProvider.notifier).logout()),
          ],
        ),
      ),
    );
  }
}
