import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/core/ui/knit.dart';
import 'package:laternote/core/ui/stitches.dart';
import 'package:material_ui/material_ui.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  final scheme = appTheme.colorScheme;

  test('text colors meet WCAG AA on their backgrounds', () {
    final pairs = {
      'onSurface/surface': (scheme.onSurface, scheme.surface),
      'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
      'onSurface/card': (scheme.onSurface, scheme.surfaceContainerLowest),
      'primary/surface': (scheme.primary, scheme.surface),
      'onPrimary/primary': (scheme.onPrimary, scheme.primary),
      'secondary/surface': (scheme.secondary, scheme.surface),
      'tertiary/card': (scheme.tertiary, scheme.surfaceContainerLowest),
      'error/surface': (scheme.error, scheme.surface),
      'snackbar': (scheme.onInverseSurface, scheme.inverseSurface),
    };
    for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
    }
  });

  test('field outlines meet 3:1 for UI components', () {
    expect(contrast(scheme.outline, scheme.surface), greaterThanOrEqualTo(3));
  });

  test('defines the stitched component themes and the knit', () {
    expect(appTheme.appBarTheme.backgroundColor, scheme.surface);
    expect(appTheme.filledButtonTheme.style, isNotNull);
    expect(appTheme.elevatedButtonTheme.style, isNotNull);
    expect(appTheme.outlinedButtonTheme.style, isNotNull);
    expect(appTheme.textButtonTheme.style, isNotNull);
    expect(
      appTheme.inputDecorationTheme.focusedBorder,
      isA<OutlineInputBorder>(),
    );
    expect(appTheme.cardTheme.shape, isA<StitchedBorder>());
    expect(
      appTheme.filledButtonTheme.style?.shape?.resolve({}),
      isA<StitchedBorder>(),
    );
    expect(appTheme.tabBarTheme.indicator, isA<StitchedPill>());
    expect(appTheme.extension<Knit>(), Knit.standard);
  });

  test('UI text is in Fredoka, letters in Caveat', () {
    final text = appTheme.textTheme;
    for (final style in [
      text.displayLarge,
      text.headlineMedium,
      text.titleLarge,
      text.bodyMedium,
      text.labelLarge,
      appTheme.appBarTheme.titleTextStyle,
    ]) {
      expect(style?.fontFamily, 'Fredoka');
    }
    expect(Knit.standard.letter.fontFamily, 'Caveat');
  });
}
