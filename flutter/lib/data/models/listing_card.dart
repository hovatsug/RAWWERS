class MyProProfileModel {
  MyProProfileModel({
    required this.userId,
    required this.displayName,
    required this.headline,
    required this.coverMediaAssetId,
    required this.city,
    required this.country,
  });

  final String userId;
  final String? displayName;
  final String? headline;
  final String? coverMediaAssetId;
  final String? city;
  final String? country;

  factory MyProProfileModel.fromJson(Map<String, dynamic> json) {
    return MyProProfileModel(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      coverMediaAssetId: json['cover_media_asset_id'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}

class NicheOption {
  NicheOption({required this.slug, required this.name, required this.isActive});

  final String slug;
  final String name;
  final bool isActive;

  factory NicheOption.fromJson(Map<String, dynamic> json) {
    return NicheOption(
      slug: json['slug'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class MyNicheItem {
  MyNicheItem({required this.slug, required this.name, required this.declaredLevel, required this.isPrimary});

  final String slug;
  final String name;
  final String? declaredLevel;
  final bool isPrimary;

  factory MyNicheItem.fromJson(Map<String, dynamic> json) {
    return MyNicheItem(
      slug: json['slug'] as String,
      name: json['name'] as String,
      declaredLevel: json['declared_level'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}

class MyNichesModel {
  MyNichesModel({required this.primaryNicheSlug, required this.niches});

  final String? primaryNicheSlug;
  final List<MyNicheItem> niches;

  factory MyNichesModel.fromJson(Map<String, dynamic> json) {
    final items = (json['niches'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return MyNichesModel(
      primaryNicheSlug: json['primary_niche_slug'] as String?,
      niches: items.map(MyNicheItem.fromJson).toList(),
    );
  }
}

class PublicPackageModel {
  PublicPackageModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.includedPhotos,
    required this.extraPhotoPrice,
  });

  final String id;
  final String title;
  final num price;
  final String currency;
  final int includedPhotos;
  final num extraPhotoPrice;

  factory PublicPackageModel.fromJson(Map<String, dynamic> json) {
    return PublicPackageModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: json['price'] as num,
      currency: json['currency'] as String,
      includedPhotos: (json['included_photos'] as num?)?.toInt() ?? 0,
      extraPhotoPrice: json['extra_photo_price'] as num? ?? 0,
    );
  }
}

class PublicProProfileModel {
  PublicProProfileModel({
    required this.proUserId,
    required this.displayName,
    required this.headline,
    required this.coverMediaAssetId,
    required this.city,
    required this.country,
    required this.avgRating,
    required this.reviewCount,
    required this.packages,
  });

  final String proUserId;
  final String? displayName;
  final String? headline;
  final String? coverMediaAssetId;
  final String? city;
  final String? country;
  final num avgRating;
  final int reviewCount;
  final List<PublicPackageModel> packages;

  factory PublicProProfileModel.fromJson(Map<String, dynamic> json) {
    final items = (json['packages'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return PublicProProfileModel(
      proUserId: json['pro_user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      coverMediaAssetId: json['cover_media_asset_id'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      avgRating: json['avg_rating'] as num? ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      packages: items.map(PublicPackageModel.fromJson).toList(),
    );
  }
}
