import 'package:material_ui/material_ui.dart';

import '../core/ui/stationery.dart';

final ColorScheme _colorScheme =
    ColorScheme.fromSeed(
      seedColor: Palette.wax,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: Palette.wax,
      onPrimary: Palette.paperLight,
      primaryContainer: const Color(0xFFF4D9D3),
      onPrimaryContainer: Palette.waxDeep,
      secondary: Palette.postmark,
      onSecondary: Palette.paperLight,
      tertiary: Palette.brass,
      onTertiary: Palette.paperLight,
      surface: Palette.paper,
      onSurface: Palette.ink,
      onSurfaceVariant: Palette.inkSoft,
      surfaceContainerLowest: Palette.paperLight,
      surfaceContainerLow: const Color(0xFFF3ECDF),
      surfaceContainer: Palette.paperShade,
      surfaceContainerHigh: const Color(0xFFEAE0CC),
      surfaceContainerHighest: const Color(0xFFE4D9C3),
      surfaceTint: Colors.transparent,
      outline: Palette.sepia,
      outlineVariant: Palette.sepiaLight,
      inverseSurface: Palette.ink,
      onInverseSurface: Palette.paper,
      inversePrimary: const Color(0xFFF2A79C),
    );

/// Headlines and titles in Fraunces; UI text stays in the platform sans.
final TextTheme _textTheme = TextTheme(
  displayLarge: fraunces(400, opticalSize: 72),
  displayMedium: fraunces(400, opticalSize: 72),
  displaySmall: fraunces(400, opticalSize: 48),
  headlineLarge: fraunces(500, opticalSize: 36),
  headlineMedium: fraunces(500, opticalSize: 36),
  headlineSmall: fraunces(500, opticalSize: 24),
  titleLarge: fraunces(600, opticalSize: 24),
);

const _stadium = StadiumBorder();
const _buttonSize = Size(64, 52);
const _buttonText = TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3);

/// "Ink & Wax" (see `Stationery`). Light mode only for now.
final ThemeData appTheme = ThemeData(
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  scaffoldBackgroundColor: Palette.paper,
  extensions: [Stationery.standard],
  appBarTheme: AppBarThemeData(
    backgroundColor: Palette.paper,
    foregroundColor: Palette.ink,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: fraunces(
      600,
      size: 22,
      opticalSize: 24,
    ).copyWith(color: Palette.ink),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: _buttonSize,
      shape: _stadium,
      textStyle: _buttonText,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: _buttonSize,
      shape: _stadium,
      textStyle: _buttonText,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: _buttonSize,
      shape: _stadium,
      textStyle: _buttonText,
      foregroundColor: Palette.ink,
      side: const BorderSide(color: Palette.sepia),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Palette.postmark,
      textStyle: _buttonText,
    ),
  ),
  // Underlined fields, like writing on ruled paper.
  inputDecorationTheme: const InputDecorationThemeData(
    contentPadding: EdgeInsets.symmetric(vertical: 12),
    border: UnderlineInputBorder(borderSide: BorderSide(color: Palette.sepia)),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Palette.sepia),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Palette.wax, width: 2),
    ),
    floatingLabelStyle: TextStyle(color: Palette.wax),
  ),
  // A sheet of paper: flat, thin edge, barely rounded.
  cardTheme: const CardThemeData(
    color: Palette.paperLight,
    elevation: 0,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      side: BorderSide(color: Palette.sepiaLight),
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    indicatorColor: Palette.wax,
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Palette.ink,
    unselectedLabelColor: Palette.inkSoft,
    dividerColor: Palette.sepiaLight,
    labelStyle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Palette.wax,
    foregroundColor: Palette.paperLight,
    shape: _stadium,
    elevation: 2,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Palette.paperLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    titleTextStyle: fraunces(
      600,
      size: 22,
      opticalSize: 24,
    ).copyWith(color: Palette.ink),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Palette.ink,
    contentTextStyle: TextStyle(color: Palette.paper),
    actionTextColor: Palette.brassGlow,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: Palette.sepiaLight, thickness: 1),
  listTileTheme: const ListTileThemeData(iconColor: Palette.inkSoft),
  datePickerTheme: const DatePickerThemeData(
    backgroundColor: Palette.paperLight,
    surfaceTintColor: Colors.transparent,
  ),
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Palette.paperLight,
  ),
);
