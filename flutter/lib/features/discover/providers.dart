import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../data/api/client.dart';
import '../../data/models/discover_models.dart';
import '../../data/repositories/discover_repository.dart';

final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepository(ref.watch(apiDioProvider));
});

final discoverProvider = FutureProvider<DiscoverResponse>((ref) async {
  try {
    return await ref.read(discoverRepositoryProvider).discover(country: AppConfig.defaultCountry, city: AppConfig.defaultCity);
  } on DioException catch (e) {
    throw Exception(e.error?.toString() ?? e.message ?? 'Failed to load discover');
  }
});
