import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/theme_client.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [currentFlavorProvider.overrideWithValue(AppFlavor.client)],
      child: const RawwersClientApp(),
    ),
  );
}

class RawwersClientApp extends StatelessWidget {
  const RawwersClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RAWWERS',
      theme: buildClientTheme(),
      routerConfig: clientRouter,
    );
  }
}
