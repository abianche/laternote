import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/core/ui/stitches.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('fills the screen body when the content is short', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: Woven(child: SingleChildScrollView(child: Text('short'))),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(Woven)),
      tester.getSize(find.byType(Scaffold)),
    );
  });
}
