class ProProfileModel {
  ProProfileModel({
    required this.proUserId,
    required this.displayName,
    required this.headline,
    required this.city,
    required this.country,
    required this.bio,
  });

  final String proUserId;
  final String? displayName;
  final String? headline;
  final String? city;
  final String? country;
  final String? bio;

  factory ProProfileModel.fromJson(Map<String, dynamic> json) {
    return ProProfileModel(
      proUserId: json['pro_user_id'] as String,
      displayName: json['display_name'] as String?,
      headline: json['headline'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
