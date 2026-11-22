import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/core/deep_link.dart';
import 'package:laternote/features/auth/presentation/link_problem_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('explains each problem', (tester) async {
    for (final (problem, text) in [
      (LinkProblem.expired, 'This link has expired or was already used.'),
      (LinkProblem.invalid, "This link can't be used."),
      (LinkProblem.unrecognized, "Laternote doesn't recognize this link."),
      (LinkProblem.network, 'No connection.'),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          home: LinkProblemScreen(problem: problem),
        ),
      );

      expect(find.textContaining(text), findsOneWidget, reason: problem.name);
      expect(find.text('Continue'), findsOneWidget);
    }
  });
}
