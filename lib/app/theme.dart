import 'package:material_ui/material_ui.dart';

import '../core/ui/knit.dart';
import '../core/ui/stitches.dart';

final ColorScheme _lightScheme =
    ColorScheme.fromSeed(
      seedColor: Palette.tomato,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: Palette.tomato,
      onPrimary: Palette.cream,
      primaryContainer: Palette.peach,
      onPrimaryContainer: Palette.tomatoDeep,
      secondary: Palette.sageDeep,
      onSecondary: Palette.cream,
      secondaryContainer: Palette.sageLight,
      onSecondaryContainer: Palette.sageDeep,
      tertiary: Palette.mustardDeep,
      onTertiary: Palette.cream,
      tertiaryContainer: Palette.mustardLight,
      onTertiaryContainer: Palette.cocoa,
      surface: Palette.oat,
      onSurface: Palette.cocoa,
      onSurfaceVariant: Palette.cocoaSoft,
      // Cards, fields and dialogs.
      surfaceContainerLowest: Palette.cream,
      surfaceContainerLow: const Color(0xFFF6EFE2),
      surfaceContainer: const Color(0xFFF2EADC),
      surfaceContainerHigh: Palette.oatShade,
      surfaceContainerHighest: const Color(0xFFDFD2BA),
      surfaceTint: Colors.transparent,
      outline: Palette.seam,
      outlineVariant: Palette.tan,
      inverseSurface: Palette.cocoa,
      onInverseSurface: Palette.oat,
      // Snackbar actions.
      inversePrimary: Palette.mustard,
    );

final ColorScheme _darkScheme =
    ColorScheme.fromSeed(
      seedColor: Palette.tomato,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: Palette.tomatoLight,
      onPrimary: Palette.ink,
      primaryContainer: Palette.tomatoDeep,
      onPrimaryContainer: Palette.peach,
      secondary: Palette.sageBright,
      onSecondary: Palette.ink,
      secondaryContainer: Palette.sageDeep,
      onSecondaryContainer: Palette.sageLight,
      tertiary: Palette.mustard,
      onTertiary: Palette.ink,
      tertiaryContainer: Palette.mustardDeep,
      onTertiaryContainer: Palette.mustardLight,
      surface: Palette.bark,
      onSurface: Palette.oatLight,
      onSurfaceVariant: Palette.tan,
      // Cards, fields and dialogs are lifted above the wool, as in light mode.
      surfaceContainerLowest: Palette.barkLifted,
      surfaceContainerLow: Palette.barkDeep,
      surfaceContainer: const Color(0xFF30261F),
      surfaceContainerHigh: Palette.barkHigh,
      surfaceContainerHighest: Palette.barkHighest,
      surfaceTint: Colors.transparent,
      outline: Palette.seamLight,
      outlineVariant: Palette.seamDark,
      inverseSurface: Palette.oat,
      onInverseSurface: Palette.cocoa,
      // Snackbar actions.
      inversePrimary: Palette.tomato,
    );

/// Everything in Fredoka; sizes come from the Material defaults.
final TextTheme _textTheme = TextTheme(
  displayLarge: fredoka(500),
  displayMedium: fredoka(500),
  displaySmall: fredoka(500),
  headlineLarge: fredoka(600),
  headlineMedium: fredoka(600),
  headlineSmall: fredoka(600),
  titleLarge: fredoka(600),
  titleMedium: fredoka(600),
  titleSmall: fredoka(600),
  bodyLarge: fredoka(400),
  bodyMedium: fredoka(400),
  bodySmall: fredoka(400),
  labelLarge: fredoka(600),
  labelMedium: fredoka(500),
  labelSmall: fredoka(500),
);

const _buttonSize = Size(64, 52);
final _buttonText = fredoka(600, size: 16).copyWith(letterSpacing: 0.2);
const _pill = 999.0;

/// "Knitted" (see `Knit`), light and dark; the app follows the OS setting.
final ThemeData appTheme = _knitted(_lightScheme, Knit.light);
final ThemeData appDarkTheme = _knitted(_darkScheme, Knit.dark);

ThemeData _knitted(ColorScheme scheme, Knit knit) => ThemeData(
  colorScheme: scheme,
  textTheme: _textTheme,
  fontFamily: 'Fredoka',
  scaffoldBackgroundColor: scheme.surface,
  extensions: [knit],
  appBarTheme: AppBarThemeData(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: fredoka(600, size: 22).copyWith(color: scheme.onSurface),
  ),
  // Filled buttons look like felt with a stitched seam inside the edge.
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      shape: StitchedBorder(
        radius: _pill,
        stitch: scheme.onPrimary.withValues(alpha: 0.7),
        inset: 5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      backgroundColor: scheme.surfaceContainerLowest,
      foregroundColor: scheme.primary,
      shape: StitchedBorder(
        radius: _pill,
        stitch: scheme.outlineVariant,
        inset: 5,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: scheme.onSurface, width: 2),
      shape: const StitchedBorder(radius: _pill),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: scheme.secondary,
      textStyle: _buttonText,
      shape: const StadiumBorder(),
    ),
  ),
  // Soft rounded fields on cream, tomato when focused.
  inputDecorationTheme: InputDecorationThemeData(
    filled: true,
    fillColor: scheme.surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: _fieldBorder(scheme.outline, 1.5),
    enabledBorder: _fieldBorder(scheme.outline, 1.5),
    focusedBorder: _fieldBorder(scheme.primary, 2.5),
    floatingLabelStyle: TextStyle(color: scheme.primary),
  ),
  // A cushion of fabric with a stitched seam.
  cardTheme: CardThemeData(
    color: scheme.surfaceContainerLowest,
    elevation: 2,
    shadowColor: knit.shadow,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    shape: StitchedBorder(
      side: BorderSide(color: scheme.outlineVariant, width: 1.5),
      radius: 22,
      stitch: knit.stitch,
      inset: 7,
    ),
  ),
  // A mustard patch with ink text, in both modes.
  tabBarTheme: TabBarThemeData(
    indicator: StitchedPill(
      color: knit.glow,
      outline: knit.outline,
      stitch: knit.outline.withValues(alpha: 0.6),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: knit.outline,
    unselectedLabelColor: scheme.onSurfaceVariant,
    dividerColor: Colors.transparent,
    labelStyle: fredoka(600, size: 15),
    unselectedLabelStyle: fredoka(500, size: 15),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    extendedTextStyle: _buttonText,
    elevation: 3,
    shape: StitchedBorder(
      radius: 24,
      stitch: scheme.onPrimary.withValues(alpha: 0.8),
      inset: 6,
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: scheme.surfaceContainerLowest,
    shape: StitchedBorder(
      radius: 26,
      stitch: scheme.outlineVariant,
      inset: 8,
    ),
    titleTextStyle: fredoka(600, size: 22).copyWith(color: scheme.onSurface),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: scheme.inverseSurface,
    contentTextStyle: fredoka(
      500,
      size: 15,
    ).copyWith(color: scheme.onInverseSurface),
    actionTextColor: scheme.inversePrimary,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1.5),
  listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: scheme.surfaceContainerLowest,
    surfaceTintColor: Colors.transparent,
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: scheme.surfaceContainerLowest,
  ),
);

OutlineInputBorder _fieldBorder(Color color, double width) =>
    OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: color, width: width),
    );
