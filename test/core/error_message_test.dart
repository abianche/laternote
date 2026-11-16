import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/error_message.dart';

void main() {
  test('errorMessage hides non-app errors behind a generic message', () {
    expect(
      errorMessage(AsyncError<void>(StateError('boom'), StackTrace.empty)),
      const UnexpectedError().message,
    );
    expect(
      errorMessage(const AsyncError<void>(NetworkError(), StackTrace.empty)),
      const NetworkError().message,
    );
    expect(errorMessage(const AsyncData<void>(null)), isNull);
  });
}
