import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const REmptyState(title: 'Messages comes in F-7'),
    );
  }
}
