import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/account/application/account_deletion.dart';

void main() {
  test('deletion request mails support with the account email', () {
    final uri = deletionRequestUri('a@b.co');
    expect(uri.scheme, 'mailto');
    expect(uri.path, deletionRequestEmail);
    expect(uri.query, contains('Account%20deletion%20request'));
    expect(uri.query, contains('a%40b.co'));
  });
}
