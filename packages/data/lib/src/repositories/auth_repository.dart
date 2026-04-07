import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> getPersistedSession();

  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> updateProfile(
    User user, {
    required String displayName,
    String? bio,
    required String preferredLanguage,
  });

  Future<void> logout();
}