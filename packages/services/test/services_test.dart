import 'package:flutter_test/flutter_test.dart';

import 'package:data/data.dart';
import 'package:services/services.dart';

void main() {
  test('auth service can be instantiated', () {
    final service = AuthService(LocalAuthRepository());
    expect(service, isNotNull);
  });
}
