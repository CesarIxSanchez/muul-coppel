import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _usersKey = 'muul.auth.users';
  static const _sessionUserIdKey = 'muul.auth.session_user_id';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<User?> getPersistedSession() async {
    final prefs = await _prefs;
    final sessionUserId = prefs.getString(_sessionUserIdKey);
    if (sessionUserId == null) {
      return null;
    }
    final users = await _readUsers();
    for (final user in users) {
      if (user.id == sessionUserId) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final users = await _readUsers();
    final normalizedEmail = email.trim().toLowerCase();
    final exists = users.any((user) => user.email.toLowerCase() == normalizedEmail);
    if (exists) {
      throw StateError('Ya existe una cuenta con este correo.');
    }

    final user = User(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: normalizedEmail,
      password: password,
      displayName: displayName.trim(),
    );
    users.add(user);
    await _saveUsers(users);

    final prefs = await _prefs;
    await prefs.setString(_sessionUserIdKey, user.id);
    return user;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final users = await _readUsers();
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in users) {
      final emailMatches = user.email.toLowerCase() == normalizedEmail;
      final passwordMatches = user.password == password;
      if (emailMatches && passwordMatches) {
        final prefs = await _prefs;
        await prefs.setString(_sessionUserIdKey, user.id);
        return user;
      }
    }

    throw StateError('Credenciales invalidas.');
  }

  @override
  Future<User> updateProfile(
    User user, {
    required String displayName,
    String? bio,
    required String preferredLanguage,
  }) async {
    final users = await _readUsers();
    final updatedUser = user.copyWith(
      displayName: displayName.trim(),
      bio: bio?.trim().isEmpty == true ? null : bio?.trim(),
      preferredLanguage: preferredLanguage,
    );

    final updatedUsers = users.map((item) {
      if (item.id == user.id) {
        return updatedUser;
      }
      return item;
    }).toList();

    await _saveUsers(updatedUsers);
    final prefs = await _prefs;
    await prefs.setString(_sessionUserIdKey, updatedUser.id);
    return updatedUser;
  }

  @override
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionUserIdKey);
  }

  Future<List<User>> _readUsers() async {
    final prefs = await _prefs;
    final encodedUsers = prefs.getString(_usersKey);
    if (encodedUsers == null || encodedUsers.isEmpty) {
      return <User>[];
    }
    final decoded = jsonDecode(encodedUsers) as List<dynamic>;
    return decoded
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }
}