import 'package:flutter_test/flutter_test.dart';

import 'package:data/data.dart';

void main() {
  test('user model serializes and deserializes', () {
    const user = User(
      id: '1',
      email: 'test@example.com',
      displayName: 'Test',
      password: '12345678',
    );
    final json = user.toJson();
    final restored = User.fromJson(json);
    expect(restored.email, user.email);
  });
}
