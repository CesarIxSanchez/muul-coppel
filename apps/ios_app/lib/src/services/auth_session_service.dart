import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionService {
  AuthSessionService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _refreshKey = 'muul_refresh_token';

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Future<void> restoreSession() async {
    if (_client.auth.currentSession != null) return;
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null || refresh.isEmpty) return;

    try {
      await _client.auth.refreshSession(refresh);
    } catch (_) {
      await _storage.delete(key: _refreshKey);
    }
  }

  Future<void> saveSessionTokens() async {
    final refresh = _client.auth.currentSession?.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refresh);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    await saveSessionTokens();
  }

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
    await saveSessionTokens();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await _storage.delete(key: _refreshKey);
  }

  Future<String?> ensureValidAccessToken() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      if (DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 1)))) {
        final refresh = await _storage.read(key: _refreshKey);
        await _client.auth.refreshSession(refresh);
        await saveSessionTokens();
      }
    }

    return _client.auth.currentSession?.accessToken;
  }

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;
}
