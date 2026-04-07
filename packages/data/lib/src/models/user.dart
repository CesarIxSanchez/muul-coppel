class User {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.password,
    this.bio,
    this.preferredLanguage = 'es',
  });

  final String id;
  final String email;
  final String displayName;
  final String password;
  final String? bio;
  final String preferredLanguage;

  User copyWith({
    String? displayName,
    String? password,
    String? bio,
    String? preferredLanguage,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'password': password,
      'bio': bio,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      password: json['password'] as String,
      bio: json['bio'] as String?,
      preferredLanguage: (json['preferredLanguage'] as String?) ?? 'es',
    );
  }
}