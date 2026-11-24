import 'package:material_ui/material_ui.dart';

import '../core/ui/knit.dart';
import '../core/ui/stitches.dart';

final ColorScheme _colorScheme =
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
      inversePrimary: Palette.tomatoLight,
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

/// "Knitted" (see `Knit`). Light mode only for now.
final ThemeData appTheme = ThemeData(
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  fontFamily: 'Fredoka',
  scaffoldBackgroundColor: Palette.oat,
  extensions: [Knit.standard],
  appBarTheme: AppBarThemeData(
    backgroundColor: Palette.oat,
    foregroundColor: Palette.cocoa,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: fredoka(600, size: 22).copyWith(color: Palette.cocoa),
  ),
  // Filled buttons look like felt with a stitched seam inside the edge.
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      shape: const StitchedBorder(
        radius: _pill,
        stitch: Color(0xB3FBF6EC),
        inset: 5,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      backgroundColor: Palette.cream,
      foregroundColor: Palette.tomato,
      shape: const StitchedBorder(
        radius: _pill,
        stitch: Palette.tan,
        inset: 5,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: _buttonSize,
      textStyle: _buttonText,
      foregroundColor: Palette.cocoa,
      side: const BorderSide(color: Palette.cocoa, width: 2),
      shape: const StitchedBorder(radius: _pill),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Palette.sageDeep,
      textStyle: _buttonText,
      shape: const StadiumBorder(),
    ),
  ),
  // Soft rounded fields on cream, tomato when focused.
  inputDecorationTheme: const InputDecorationThemeData(
    filled: true,
    fillColor: Palette.cream,
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: Palette.seam, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: Palette.seam, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide(color: Palette.tomato, width: 2.5),
    ),
    floatingLabelStyle: TextStyle(color: Palette.tomato),
  ),
  // A cushion of cream fabric with a stitched seam.
  cardTheme: const CardThemeData(
    color: Palette.cream,
    elevation: 2,
    shadowColor: Color(0x66705030),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    shape: StitchedBorder(
      side: BorderSide(color: Palette.tan, width: 1.5),
      radius: 22,
      stitch: Color(0xFFD36A5C),
      inset: 7,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    indicator: const StitchedPill(
      color: Palette.mustard,
      outline: Palette.cocoa,
      stitch: Color(0x9943352B),
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Palette.cocoa,
    unselectedLabelColor: Palette.cocoaSoft,
    dividerColor: Colors.transparent,
    labelStyle: fredoka(600, size: 15),
    unselectedLabelStyle: fredoka(500, size: 15),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Palette.tomato,
    foregroundColor: Palette.cream,
    extendedTextStyle: _buttonText,
    elevation: 3,
    shape: const StitchedBorder(
      radius: 24,
      stitch: Color(0xCCFBF6EC),
      inset: 6,
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Palette.cream,
    shape: const StitchedBorder(radius: 26, stitch: Palette.tan, inset: 8),
    titleTextStyle: fredoka(600, size: 22).copyWith(color: Palette.cocoa),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Palette.cocoa,
    contentTextStyle: fredoka(500, size: 15).copyWith(color: Palette.oat),
    actionTextColor: Palette.mustard,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: Palette.tan, thickness: 1.5),
  listTileTheme: const ListTileThemeData(iconColor: Palette.cocoaSoft),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Palette.cream,
    surfaceTintColor: Colors.transparent,
  ),
  timePickerTheme: const TimePickerThemeData(backgroundColor: Palette.cream),
);
