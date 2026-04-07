import 'package:core/core.dart';
import 'package:data/data.dart';

class AuthService {
  const AuthService(this._repository);

  final AuthRepository _repository;

  Future<AppResult<User?>> restoreSession() async {
    try {
      final user = await _repository.getPersistedSession();
      return AppResult.success(user);
    } on Exception {
      return AppResult.failure('No se pudo restaurar la sesion.');
    }
  }

  Future<AppResult<User>> login({
    required String email,
    required String password,
  }) async {
    final emailError = InputValidators.email(email);
    if (emailError != null) {
      return AppResult.failure(emailError);
    }

    final passwordError = InputValidators.password(password);
    if (passwordError != null) {
      return AppResult.failure(passwordError);
    }

    try {
      final user = await _repository.login(email: email, password: password);
      return AppResult.success(user);
    } on StateError catch (error) {
      return AppResult.failure(error.message);
    } on Exception {
      return AppResult.failure('Error al iniciar sesion.');
    }
  }

  Future<AppResult<User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final displayNameError = InputValidators.displayName(displayName);
    if (displayNameError != null) {
      return AppResult.failure(displayNameError);
    }

    final emailError = InputValidators.email(email);
    if (emailError != null) {
      return AppResult.failure(emailError);
    }

    final passwordError = InputValidators.password(password);
    if (passwordError != null) {
      return AppResult.failure(passwordError);
    }

    try {
      final user = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return AppResult.success(user);
    } on StateError catch (error) {
      return AppResult.failure(error.message);
    } on Exception {
      return AppResult.failure('Error al registrar usuario.');
    }
  }

  Future<AppResult<User>> updateProfile(
    User user, {
    required String displayName,
    String? bio,
    required String preferredLanguage,
  }) async {
    final displayNameError = InputValidators.displayName(displayName);
    if (displayNameError != null) {
      return AppResult.failure(displayNameError);
    }

    try {
      final updatedUser = await _repository.updateProfile(
        user,
        displayName: displayName,
        bio: bio,
        preferredLanguage: preferredLanguage,
      );
      return AppResult.success(updatedUser);
    } on Exception {
      return AppResult.failure('No se pudo actualizar el perfil.');
    }
  }

  Future<AppResult<void>> logout() async {
    try {
      await _repository.logout();
      return AppResult.success(null);
    } on Exception {
      return AppResult.failure('No se pudo cerrar sesion.');
    }
  }
}