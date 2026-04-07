import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_session_service.dart';

class SessionController extends ChangeNotifier {
  SessionController({AuthSessionService? authService}) : _authService = authService ?? AuthSessionService();

  final AuthSessionService _authService;
  StreamSubscription<AuthState>? _sub;

  bool _ready = false;
  bool _loading = false;
  String? _error;

  bool get ready => _ready;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;
  User? get currentUser => _authService.currentUser;

  Future<void> bootstrap() async {
    _setLoading(true);
    try {
      await _authService.restoreSession();
      await _authService.saveSessionTokens();
      _sub = _authService.authChanges.listen((_) async {
        await _authService.saveSessionTokens();
        notifyListeners();
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _ready = true;
      _setLoading(false);
    }
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUp(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> ensureValidAccessToken() => _authService.ensureValidAccessToken();

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
