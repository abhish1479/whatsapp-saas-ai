class AuthResponse {
  final String accessToken;
  final String tokenType;
  final User user;
  final int tenantId;
  final String onboardingProcess;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.tenantId,
    required this.onboardingProcess,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      user: User.fromJson(json['user']),
      tenantId: json['tenant_id'],
      onboardingProcess: json['onboarding_process'],
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final String provider;
  final String providerId;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.provider,
    required this.providerId,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      provider: json['provider'],
      providerId: json['provider_id'],
      role: json['role'],
    );
  }
}