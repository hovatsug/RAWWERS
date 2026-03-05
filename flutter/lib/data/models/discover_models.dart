class DiscoverCardModel {
  DiscoverCardModel({
    required this.proUserId,
    required this.displayName,
    required this.headline,
    required this.coverMediaAssetId,
    required this.city,
    required this.country,
    required this.minPrice,
    required this.currency,
    required this.avgRating,
    required this.reviewCount,
    required this.topNiches,
  });

  final String proUserId;
  final String? displayName;
  final String? headline;
  final String? coverMediaAssetId;
  final String? city;
  final String? country;
  final num? minPrice;
  final String? currency;
  final num? avgRating;
  final int? reviewCount;
  final List<String> topNiches;

  factory DiscoverCardModel.fromJson(Map<String, dynamic> json) {
    return DiscoverCardModel(
      proUserId: json['pro_user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      coverMediaAssetId: json['cover_media_asset_id'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      minPrice: json['min_price'] as num?,
      currency: json['currency'] as String?,
      avgRating: json['avg_rating'] as num?,
      reviewCount: (json['review_count'] as num?)?.toInt(),
      topNiches: ((json['top_niches'] as List<dynamic>? ?? [])
          .map((e) {
            if (e is Map<String, dynamic>) {
              final slug = e['slug'] as String?;
              return slug ?? '';
            }
            return '';
          })
          .where((e) => e.isNotEmpty)
          .toList()),
    );
  }
}

class DiscoverResponse {
  DiscoverResponse({required this.items, required this.total, required this.guestLimited});

  final List<DiscoverCardModel> items;
  final int total;
  final bool guestLimited;

  factory DiscoverResponse.fromJson(Map<String, dynamic> json) {
    final rows = (json['items'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return DiscoverResponse(
      items: rows.map(DiscoverCardModel.fromJson).toList(),
      total: (json['total'] as num?)?.toInt() ?? rows.length,
      guestLimited: json['guest_limited'] as bool? ?? false,
    );
  }
}
