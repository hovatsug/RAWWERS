import 'package:flutter/material.dart';
import 'package:rawwers/features/shared/home/placeholder_scaffold.dart';

class ProHomeScreen extends StatelessWidget {
  const ProHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'RAWWERS Pro',
      subtitle: 'Pro app — F-1 scaffold. Onboarding comes in F-6.',
    );
  }
}
