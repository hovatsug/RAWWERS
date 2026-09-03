import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class GigsScreen extends StatelessWidget {
  const GigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gigs')),
      body: const REmptyState(title: 'Gigs comes in F-6'),
    );
  }
}
