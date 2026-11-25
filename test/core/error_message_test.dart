import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/error_message.dart';
import 'package:laternote/l10n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('errorMessage localizes app errors and hides the rest', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      errorMessage(
        context,
        AsyncError<void>(StateError('boom'), StackTrace.empty),
      ),
      en.errorUnexpected,
    );
    expect(
      errorMessage(
        context,
        const AsyncError<void>(NetworkError(), StackTrace.empty),
      ),
      en.errorNetwork,
    );
    expect(errorMessage(context, const AsyncData<void>(null)), isNull);
  });

  test('every app error has its own text', () {
    final errors = <AppError>[
      const NetworkError(),
      const UnexpectedError(),
      const InvalidFileError(),
      ...[for (final p in ValidationProblem.values) ValidationError(p)],
    ];
    final texts = errors.map((e) => appErrorText(en, e)).toSet();
    expect(texts, hasLength(errors.length));
  });

  test('length limits use grouped digits', () {
    expect(
      validationText(en, ValidationProblem.bodyTooLong),
      'Keep it under 20,000 characters.',
    );
  });
}
