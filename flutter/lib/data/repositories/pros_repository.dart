import 'package:dio/dio.dart';

import '../models/pro_profile.dart';

class ProsRepository {
  ProsRepository(this._dio);

  final Dio _dio;

  Future<ProProfileModel> getProProfile({required String proUserId, required String country, required String city}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/client/pros/$proUserId',
      queryParameters: {'country': country, 'city': city},
    );
    return ProProfileModel.fromJson(response.data ?? {});
  }
}
