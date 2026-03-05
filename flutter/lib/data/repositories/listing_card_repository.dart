import 'package:dio/dio.dart';

import '../models/listing_card.dart';

class ListingCardRepository {
  ListingCardRepository(this._dio);

  final Dio _dio;

  Future<MyProProfileModel> getMyProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/pro/me/profile');
    return MyProProfileModel.fromJson(response.data ?? {});
  }

  Future<MyProProfileModel> updateMyProfile({required String headline, required String? coverMediaAssetId}) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/pro/me/profile',
      data: {
        'headline': headline.trim().isEmpty ? null : headline.trim(),
        'cover_media_asset_id': (coverMediaAssetId == null || coverMediaAssetId.trim().isEmpty) ? null : coverMediaAssetId.trim(),
      },
    );
    return MyProProfileModel.fromJson(response.data ?? {});
  }

  Future<MyNichesModel> getMyNiches() async {
    final response = await _dio.get<Map<String, dynamic>>('/pro/niches/mine');
    return MyNichesModel.fromJson(response.data ?? {});
  }

  Future<MyNichesModel> putMyNiches({required List<MyNicheItem> previous, required List<String> selected}) async {
    final previousBySlug = {for (final row in previous) row.slug: row};
    final slugs = selected.toSet().take(5).toList();
    final response = await _dio.put<Map<String, dynamic>>(
      '/pro/niches/mine',
      data: {
        'primary_niche_slug': slugs.isEmpty ? null : slugs.first,
        'niches': slugs
            .asMap()
            .entries
            .map(
              (entry) => {
                'slug': entry.value,
                'declared_level': previousBySlug[entry.value]?.declaredLevel,
                'is_primary': entry.key == 0,
              },
            )
            .toList(),
      },
    );
    return MyNichesModel.fromJson(response.data ?? {});
  }

  Future<List<NicheOption>> listNiches() async {
    final response = await _dio.get<List<dynamic>>('/niches');
    final rows = (response.data ?? []).cast<Map<String, dynamic>>();
    return rows.map(NicheOption.fromJson).where((row) => row.isActive).toList();
  }

  Future<PublicProProfileModel> getPublicProfile(String proUserId) async {
    final response = await _dio.get<Map<String, dynamic>>('/pros/$proUserId/public');
    return PublicProProfileModel.fromJson(response.data ?? {});
  }

  Future<Map<String, dynamic>?> findSearchCard({required String city, required String country, required String proUserId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/pros',
      queryParameters: {
        'city': city,
        'country': country,
        'limit': 50,
      },
    );
    final items = (response.data?['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final item in items) {
      if (item['id'] == proUserId) {
        return item;
      }
    }
    return null;
  }
}
