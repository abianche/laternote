import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/core/ui/envelope.dart';
import 'package:laternote/core/ui/letter_paper.dart';
import 'package:laternote/core/ui/stitches.dart';
import 'package:laternote/core/ui/date_patch.dart';
import 'package:laternote/core/ui/button_seal.dart';
import 'package:laternote/core/ui/wordmark.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final (mode, theme) in [('light', appTheme), ('dark', appDarkTheme)]) {
    group(mode, () => drawnWidgetTests(theme));
  }
}

void drawnWidgetTests(ThemeData theme) {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      theme: theme,
      localizationsDelegates: appLocalizationsDelegates,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('a button paints sewn on, glowing and coming undone', (
    tester,
  ) async {
    for (final seal in const [
      ButtonSeal(),
      ButtonSeal(glow: 1),
      ButtonSeal(undone: 0.5),
      ButtonSeal(undone: 1, size: 96),
    ]) {
      await pump(tester, seal);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ButtonSeal)), Size.square(seal.size));
    }
  });

  testWidgets('an envelope paints every state', (tester) async {
    for (final envelope in const [
      Envelope(),
      Envelope(flap: 1, undone: 1, stamped: true),
      Envelope(calm: true, glow: 0.5),
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
          ButtonSeal(),
          Envelope(semanticLabel: 'Sealed envelope'),
        ],
      ),
    );

    expect(find.bySemanticsLabel('Sealed envelope'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(ButtonSeal)).label,
      isNot(contains('L')),
    );
    semantics.dispose();
  });

  testWidgets('a date patch shows the day and year, or ?', (tester) async {
    await pump(tester, DatePatch(date: DateTime(2030, 6, 1)));
    expect(find.text('Jun 1'), findsOneWidget);
    expect(find.text('2030'), findsOneWidget);

    await pump(tester, const DatePatch(date: null));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('letter paper holds its child', (tester) async {
    await pump(tester, const LetterPaper(child: Text('Dear me')));
    expect(find.text('Dear me'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the wordmark is in Fredoka', (tester) async {
    await pump(tester, const Wordmark());
    final text = tester.widget<Text>(find.text('Laternote'));
    expect(text.style?.fontFamily, 'Fredoka');
  });

  testWidgets('the button sits where the envelope says', (tester) async {
    const width = 220.0;
    final centre = Envelope.buttonCenter(width);
    expect(centre.dx, width / 2);
    expect(centre.dy, lessThan(width * Envelope.aspect));
    expect(Envelope.buttonRadius(width), greaterThan(0));
  });

  testWidgets('stitched shapes paint on screens with a woven background', (
    tester,
  ) async {
    await pump(
      tester,
      const SizedBox(
        width: 300,
        height: 300,
        child: Woven(
          child: Card(
            child: Padding(padding: EdgeInsets.all(24), child: Text('Hi')),
          ),
        ),
      ),
    );
    expect(find.text('Hi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
