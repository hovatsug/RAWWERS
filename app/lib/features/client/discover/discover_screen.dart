import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: const REmptyState(title: 'Discover comes in F-7'),
    );
  }
}
