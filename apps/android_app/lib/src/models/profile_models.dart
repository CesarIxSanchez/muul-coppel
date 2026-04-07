enum UserGender { male, female, notSpecified }

extension UserGenderX on UserGender {
  String get dbValue {
    switch (this) {
      case UserGender.male:
        return 'male';
      case UserGender.female:
        return 'female';
      case UserGender.notSpecified:
        return 'not_specified';
    }
  }

  String get label {
    switch (this) {
      case UserGender.male:
        return 'Masculino';
      case UserGender.female:
        return 'Femenino';
      case UserGender.notSpecified:
        return 'Prefiero no decir';
    }
  }

  static UserGender fromDb(dynamic value) {
    switch (value) {
      case 'male':
        return UserGender.male;
      case 'female':
        return UserGender.female;
      default:
        return UserGender.notSpecified;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.gender,
    required this.language,
    required this.lastUsernameChangeDate,
    required this.avatarUrl,
  });

  final String id;
  final String username;
  final UserGender gender;
  final String language;
  final DateTime? lastUsernameChangeDate;
  final String? avatarUrl;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: (map['username'] as String?) ?? '@usuario',
      gender: UserGenderX.fromDb(map['gender']),
      language: (map['language'] as String?) ?? 'es-MX',
      lastUsernameChangeDate: map['last_username_change_date'] == null
          ? null
          : DateTime.tryParse(map['last_username_change_date'] as String),
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class BusinessProfile {
  const BusinessProfile({
    required this.id,
    required this.businessName,
    required this.address,
    required this.language,
    required this.avatarUrl,
  });

  final String id;
  final String businessName;
  final String address;
  final String language;
  final String? avatarUrl;

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      businessName: map['business_name'] as String,
      address: map['address'] as String,
      language: (map['language'] as String?) ?? 'es-MX',
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
