class InputValidators {
  const InputValidators._();

  static String? email(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'El correo es obligatorio.';
    }

    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(normalized)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return 'La contrasena es obligatoria.';
    }
    if (value.length < 8) {
      return 'La contrasena debe tener al menos 8 caracteres.';
    }
    return null;
  }

  static String? displayName(String value) {
    if (value.trim().isEmpty) {
      return 'El nombre es obligatorio.';
    }
    return null;
  }
}