import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({required this.settingsPath, super.key});

  final String settingsPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
            onPressed: () => context.push(settingsPath),
          ),
        ],
      ),
      body: const REmptyState(title: 'Today comes in F-6'),
    );
  }
}
