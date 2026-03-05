class DiscoverCardModel {
  DiscoverCardModel({
    required this.proUserId,
    required this.displayName,
    required this.city,
    required this.country,
    required this.minPrice,
    required this.currency,
  });

  final String proUserId;
  final String? displayName;
  final String? city;
  final String? country;
  final num? minPrice;
  final String? currency;

  factory DiscoverCardModel.fromJson(Map<String, dynamic> json) {
    return DiscoverCardModel(
      proUserId: json['pro_user_id'] as String,
      displayName: json['display_name'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      minPrice: json['min_price'] as num?,
      currency: json['currency'] as String?,
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
