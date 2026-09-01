import 'package:dio/dio.dart';

import '../models/feature_flag.dart';

class FlagsRepository {
  FlagsRepository(this._dio);

  final Dio _dio;

  Future<Map<String, bool>> fetchFlags() async {
    try {
      final response = await _dio.get<List<dynamic>>('/feature-flags');
      final items = (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(FeatureFlag.fromJson)
          .toList();
      return {for (final item in items) item.key: item.isEnabled};
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
        return <String, bool>{};
      }
      rethrow;
    }
  }
}
