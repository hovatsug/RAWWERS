import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../design/theme.dart';
import 'router.dart';

class RawwersApp extends ConsumerWidget {
  const RawwersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appDisplayName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: router,
    );
  }
}
