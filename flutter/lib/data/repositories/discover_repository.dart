import 'package:dio/dio.dart';

import '../models/discover_models.dart';

class DiscoverRepository {
  DiscoverRepository(this._dio);

  final Dio _dio;

  Future<DiscoverResponse> discover({required String country, required String city}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/client/discover',
      queryParameters: {'country': country, 'city': city},
    );
    return DiscoverResponse.fromJson(response.data ?? {});
  }
}
