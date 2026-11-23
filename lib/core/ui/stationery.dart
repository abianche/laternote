import 'package:material_ui/material_ui.dart';

/// "Ink & Wax": a message is a letter written in ink on paper and closed
/// with a wax seal. Light mode only for now.
abstract final class Palette {
  static const paper = Color(0xFFF7F1E6);
  static const paperLight = Color(0xFFFFFCF5);
  static const paperShade = Color(0xFFEFE6D4);
  static const ink = Color(0xFF1F2433);
  static const inkSoft = Color(0xFF4A4F5E);
  static const wax = Color(0xFF9E2B25);
  static const waxLight = Color(0xFFC4473D);
  static const waxDeep = Color(0xFF6B1A15);
  static const postmark = Color(0xFF2E4A7D);
  static const brass = Color(0xFF7D5A1C);
  static const brassGlow = Color(0xFFE0A93B);
  static const sepia = Color(0xFF8C7B5E);
  static const sepiaLight = Color(0xFFD9CCB4);
  static const envelope = Color(0xFFEDE0C6);
}

/// Fraunces at [weight] (100–900) and [opticalSize]; the font is variable.
TextStyle fraunces(
  double weight, {
  double? size,
  double? height,
  double opticalSize = 24,
  bool italic = false,
}) => TextStyle(
  fontFamily: 'Fraunces',
  fontSize: size,
  height: height,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  fontWeight: FontWeight.values[(weight ~/ 100) - 1],
  fontVariations: [
    FontVariation.weight(weight),
    FontVariation.opticalSize(opticalSize),
    const FontVariation('SOFT', 50),
  ],
);

/// Letter-specific styles and colors the drawn widgets share.
@immutable
class Stationery extends ThemeExtension<Stationery> {
  const Stationery({
    required this.wax,
    required this.waxLight,
    required this.waxDeep,
    required this.paper,
    required this.envelope,
    required this.rule,
    required this.margin,
    required this.postmark,
    required this.glow,
    required this.letter,
    required this.wordmark,
    required this.smallCaps,
  });

  static final standard = Stationery(
    wax: Palette.wax,
    waxLight: Palette.waxLight,
    waxDeep: Palette.waxDeep,
    paper: Palette.paperLight,
    envelope: Palette.envelope,
    rule: const Color(0x332E4A7D),
    margin: const Color(0x669E2B25),
    postmark: Palette.postmark,
    glow: Palette.brassGlow,
    letter: fraunces(
      400,
      size: 18,
      height: 1.6,
      opticalSize: 14,
    ).copyWith(color: Palette.ink),
    wordmark: fraunces(
      600,
      opticalSize: 72,
      italic: true,
    ).copyWith(color: Palette.wax),
    smallCaps: fraunces(600, size: 14, opticalSize: 14).copyWith(
      letterSpacing: 1.2,
      fontFeatures: const [FontFeature.enable('smcp')],
    ),
  );

  /// The app theme's stationery; widgets pumped without [appTheme] (as in
  /// tests) get the same standard set.
  static Stationery of(BuildContext context) =>
      Theme.of(context).extension<Stationery>() ?? standard;

  final Color wax;
  final Color waxLight;
  final Color waxDeep;
  final Color paper;
  final Color envelope;
  final Color rule;
  final Color margin;
  final Color postmark;
  final Color glow;

  /// The text of a letter, on [LetterPaper].
  final TextStyle letter;

  /// "Laternote" set as a wordmark; size it with `copyWith(fontSize:)`.
  final TextStyle wordmark;

  /// Section headers.
  final TextStyle smallCaps;

  @override
  Stationery copyWith() => this;

  @override
  Stationery lerp(Stationery? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
