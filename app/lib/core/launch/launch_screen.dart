import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rawwers/design/tokens.dart';

/// Shown for AuthState.Unknown - the window between reading session storage
/// and GET /v1/me returning is real and visible on a slow connection.
/// Deliberate, not a flash of whatever the router would otherwise render.
///
/// Always dark, in both flavors: it is the first Flutter frame, and the
/// native launch screen before it is Ink 950 on iOS and Android, so the two
/// read as one screen. The spinner stays under the name: on a slow
/// connection it is the only sign that something is happening.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({required this.title, super.key});

  /// The ground both native launch screens paint (tools/brand writes the
  /// same token into the storyboards and the Android launch_ground).
  static const ground = RInk.i950;

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.displayMedium?.copyWith(color: RInk.i050)),
              const SizedBox(height: RSpace.s24),
              const SizedBox(
                width: RIcon.standard,
                height: RIcon.standard,
                child: CircularProgressIndicator(strokeWidth: 2, color: RAccent.meter500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
