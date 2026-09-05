import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/core/router/app_router_pro.dart';
import 'package:rawwers/design/theme_pro.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [currentFlavorProvider.overrideWithValue(AppFlavor.pro)],
      child: const RawwersProApp(),
    ),
  );
}

class RawwersProApp extends ConsumerWidget {
  const RawwersProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RAWWERS Pro',
      theme: buildProTheme(),
      routerConfig: ref.watch(proRouterProvider),
    );
  }
}
