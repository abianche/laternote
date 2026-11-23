import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/core/ui/envelope.dart';
import 'package:laternote/core/ui/letter_paper.dart';
import 'package:laternote/core/ui/postmark.dart';
import 'package:laternote/core/ui/wax_seal.dart';
import 'package:laternote/core/ui/wordmark.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      localizationsDelegates: appLocalizationsDelegates,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('a seal paints whole, glowing and broken', (tester) async {
    for (final seal in const [
      WaxSeal(),
      WaxSeal(glow: 1),
      WaxSeal(crack: 0.5),
      WaxSeal(crack: 1, size: 96),
    ]) {
      await pump(tester, seal);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WaxSeal)), Size.square(seal.size));
    }
  });

  testWidgets('an envelope paints every state', (tester) async {
    for (final envelope in const [
      Envelope(),
      Envelope(flap: 1, crack: 1, stamped: true),
      Envelope(flap: 0.5, sealed: false, letter: 0.3),
      Envelope(width: 220, flap: 1, sealed: false, letter: 1, glow: 1),
    ]) {
      await pump(tester, envelope);
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(Envelope)),
        Size(envelope.width, envelope.width * Envelope.aspect),
      );
    }
  });

  testWidgets('drawings are decorative unless labelled', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WaxSeal(),
          Envelope(semanticLabel: 'Sealed envelope'),
        ],
      ),
    );

    expect(find.bySemanticsLabel('Sealed envelope'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(WaxSeal)).label,
      isNot(contains('L')),
    );
    semantics.dispose();
  });

  testWidgets('a postmark shows the day and year, or ?', (tester) async {
    await pump(tester, Postmark(date: DateTime(2030, 6, 1)));
    expect(find.text('Jun 1'), findsOneWidget);
    expect(find.text('2030'), findsOneWidget);

    await pump(tester, const Postmark(date: null));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('letter paper holds its child', (tester) async {
    await pump(tester, const LetterPaper(child: Text('Dear me')));
    expect(find.text('Dear me'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the wordmark is in Fraunces', (tester) async {
    await pump(tester, const Wordmark());
    final text = tester.widget<Text>(find.text('Laternote'));
    expect(text.style?.fontFamily, 'Fraunces');
  });
}
