class OnboardingChecksModel {
  OnboardingChecksModel({
    required this.status,
    required this.checks,
    required this.missing,
  });

  final String status;
  final Map<String, bool> checks;
  final List<String> missing;

  factory OnboardingChecksModel.fromJson(Map<String, dynamic> json) {
    final rawChecks = (json['checks'] as Map<String, dynamic>? ?? {});
    return OnboardingChecksModel(
      status: json['status'] as String? ?? 'unknown',
      checks: rawChecks.map((key, value) => MapEntry(key, value as bool? ?? false)),
      missing: ((json['missing'] as List<dynamic>?) ?? []).map((e) => e as String).toList(),
    );
  }
}
