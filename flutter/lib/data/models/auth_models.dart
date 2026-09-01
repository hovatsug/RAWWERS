class TokenResponse {
  TokenResponse({required this.accessToken, required this.refreshToken, required this.expiresIn});

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );
  }
}

class MeResponse {
  MeResponse({
    required this.userId,
    required this.email,
    required this.roles,
    required this.locale,
  });

  final String userId;
  final String email;
  final List<String> roles;
  final String locale;

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      roles: ((json['roles'] as List<dynamic>?) ?? []).map((e) => e as String).toList(),
      locale: (json['locale'] as String?) ?? 'en-GB',
    );
  }
}
