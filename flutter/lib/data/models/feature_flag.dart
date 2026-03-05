class FeatureFlag {
  FeatureFlag({required this.key, required this.isEnabled});

  final String key;
  final bool isEnabled;

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      key: json['key'] as String? ?? json['name'] as String,
      isEnabled: (json['is_enabled'] as bool?) ?? (json['enabled'] as bool? ?? false),
    );
  }
}
