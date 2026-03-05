import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import '../../data/models/onboarding_checks.dart';
import '../../data/repositories/pro_onboarding_repository.dart';

final proOnboardingRepositoryProvider = Provider<ProOnboardingRepository>((ref) {
  return ProOnboardingRepository(ref.watch(apiDioProvider));
});

final proOnboardingChecksProvider = FutureProvider<OnboardingChecksModel>((ref) {
  return ref.read(proOnboardingRepositoryProvider).getChecks();
});
