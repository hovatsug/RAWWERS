import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Shown for AuthState.Unknown - the window between reading session storage
/// and GET /v1/me returning is real and visible on a slow connection.
/// Deliberate, not a flash of whatever the router would otherwise render.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.displayMedium),
            const SizedBox(height: RSpace.s24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
