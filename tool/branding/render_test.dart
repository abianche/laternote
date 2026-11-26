// Regenerates assets/branding/. Needs the Flutter engine to paint, so it runs
// as a test: `flutter test tool/branding/render_test.dart`, then the
// launcher icon and splash generators (see assets/branding/README.md).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'branding.dart';

void main() {
  test('render branding', () async {
    for (final MapEntry(:key, :value) in (await renderBranding()).entries) {
      File('assets/branding/$key')
        ..createSync(recursive: true)
        ..writeAsBytesSync(value);
    }
  });
}
