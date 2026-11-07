import 'package:flutter/material.dart';
import 'package:rawwers/features/shared/notifications/notification_bell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({required this.verifyEmailPath, this.marketingPermissionsPath, this.notificationsPath, this.creditPath, super.key});

  /// Account > My credit.
  final String? creditPath;

  /// Where the bell opens; no bell without it.
  final String? notificationsPath;

  final String verifyEmailPath;

  /// Photos the client has let RAWWERS feature; null hides the link.
  final String? marketingPermissionsPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = switch (ref.watch(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [if (notificationsPath != null) NotificationBell(onOpen: () => context.push(notificationsPath!))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(RSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (me?.email != null) Text(me!.email!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: RSpace.s16),
            RTextLink(label: 'Verify email', onPressed: () => context.push(verifyEmailPath)),
            if (creditPath case final path?) ...[
              const SizedBox(height: RSpace.s12),
              RTextLink(label: 'My credit', onPressed: () => context.push(path)),
            ],
            if (marketingPermissionsPath case final path?) ...[
              const SizedBox(height: RSpace.s12),
              RTextLink(label: 'Marketing permissions', onPressed: () => context.push(path)),
            ],
            const Spacer(),
            RButton(label: 'Log out', onPressed: () => ref.read(authControllerProvider.notifier).logout()),
          ],
        ),
      ),
    );
  }
}
