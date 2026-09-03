import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: const REmptyState(title: 'Requests comes in F-6'),
    );
  }
}
