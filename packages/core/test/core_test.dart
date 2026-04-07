import 'package:flutter_test/flutter_test.dart';

import 'package:core/core.dart';

void main() {
  test('core exports validators and result types', () {
    expect(InputValidators.email('test@example.com'), isNull);
    final success = AppResult.success<int>(1);
    expect(success.isSuccess, isTrue);
  });
}
