import 'package:dio/dio.dart';

import '../models/onboarding_checks.dart';

class ProOnboardingRepository {
  ProOnboardingRepository(this._dio);

  final Dio _dio;

  Future<OnboardingChecksModel> getChecks() async {
    final response = await _dio.get<Map<String, dynamic>>('/pro/onboarding/checks');
    return OnboardingChecksModel.fromJson(response.data ?? {});
  }
}
