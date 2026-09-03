import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flavor.g.dart';

enum AppFlavor { client, pro }

/// Which flavor is running. Has no real default — main_client.dart and
/// main_pro.dart each override it via ProviderScope, so anything reading
/// this outside of an override is a wiring bug, not a fallback case.
@riverpod
AppFlavor currentFlavor(Ref ref) {
  throw UnimplementedError('currentFlavorProvider must be overridden in main_client.dart / main_pro.dart');
}
