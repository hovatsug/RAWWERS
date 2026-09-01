import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../data/api/client.dart';
import '../../data/models/pro_profile.dart';
import '../../data/repositories/pros_repository.dart';

final prosRepositoryProvider = Provider<ProsRepository>((ref) {
  return ProsRepository(ref.watch(apiDioProvider));
});

final proProfileProvider = FutureProvider.family<ProProfileModel, String>((ref, id) {
  return ref.read(prosRepositoryProvider).getProProfile(
        proUserId: id,
        country: AppConfig.defaultCountry,
        city: AppConfig.defaultCity,
      );
});
