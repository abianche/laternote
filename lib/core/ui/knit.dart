import 'package:material_ui/material_ui.dart';

/// "Knitted": a message is a handwritten note tucked into a felt envelope and
/// buttoned shut. Oatmeal wool, cream fabric, tomato, mustard and sage,
/// stitched edges. In dark mode the wool is a deep bark brown and the colors
/// brighten to stay readable on it.
abstract final class Palette {
  static const oat = Color(0xFFEFE6D6);
  static const oatShade = Color(0xFFE6DAC4);
  static const cream = Color(0xFFFBF6EC);
  static const cocoa = Color(0xFF43352B);
  static const cocoaSoft = Color(0xFF6B5646);
  static const tomato = Color(0xFFB03E32);
  static const tomatoBright = Color(0xFFC8483B);
  static const tomatoLight = Color(0xFFE27D6E);
  static const tomatoDeep = Color(0xFF8E2E25);
  static const mustard = Color(0xFFE3B23C);
  static const mustardLight = Color(0xFFF3D58A);
  static const mustardDeep = Color(0xFF8A6414);
  static const sage = Color(0xFF6F9A8D);
  static const sageDeep = Color(0xFF3F665A);
  static const sageLight = Color(0xFFCFE1D6);
  static const peach = Color(0xFFF2C9B4);
  static const tan = Color(0xFFCBB89A);
  static const seam = Color(0xFF8C7A63);

  // Dark mode.
  static const bark = Color(0xFF2A211B);
  static const barkDeep = Color(0xFF221A15);
  static const barkLifted = Color(0xFF3A2E25);
  static const barkHigh = Color(0xFF443629);
  static const barkHighest = Color(0xFF4F4033);
  static const ink = Color(0xFF1A130F);
  static const oatLight = Color(0xFFF1E8D8);
  static const sageBright = Color(0xFF9CC2B4);
  static const seamLight = Color(0xFFA8957B);
  static const seamDark = Color(0xFF5A4A3D);
}

/// [family] at [weight] (100–900). Both bundled fonts are variable, so the
/// weight is set as a font variation too.
TextStyle _font(
  String family,
  double weight, {
  double? size,
  double? height,
}) => TextStyle(
  fontFamily: family,
  fontSize: size,
  height: height,
  fontWeight: FontWeight.values[(weight ~/ 100) - 1],
  fontVariations: [FontVariation.weight(weight)],
);

/// Fredoka: round, soft UI type.
TextStyle fredoka(double weight, {double? size, double? height}) =>
    _font('Fredoka', weight, size: size, height: height);

/// Caveat: handwriting, for letters.
TextStyle caveat(double weight, {double? size, double? height}) =>
    _font('Caveat', weight, size: size, height: height);

/// Colors and styles the drawn widgets share, beyond Material's roles.
@immutable
class Knit extends ThemeExtension<Knit> {
  const Knit({
    required this.button,
    required this.buttonLight,
    required this.buttonDeep,
    required this.thread,
    required this.fabric,
    required this.envelope,
    required this.envelopeCalm,
    required this.outline,
    required this.stitch,
    required this.stitchCalm,
    required this.rule,
    required this.patch,
    required this.glow,
    required this.weave,
    required this.shadow,
    required this.letter,
    required this.wordmark,
    required this.label,
  });

  static final light = Knit(
    button: Palette.tomatoBright,
    buttonLight: Palette.tomatoLight,
    buttonDeep: Palette.tomatoDeep,
    thread: Palette.mustardLight,
    fabric: Palette.cream,
    envelope: Palette.peach,
    envelopeCalm: Palette.sageLight,
    outline: Palette.cocoa,
    stitch: const Color(0xFFD36A5C),
    stitchCalm: Palette.sage,
    rule: const Color(0x66CBB89A),
    patch: Palette.mustardLight,
    glow: Palette.mustard,
    weave: const Color(0x14967850),
    shadow: const Color(0x66705030),
    letter: caveat(500, size: 24, height: 1.2).copyWith(color: Palette.cocoa),
    wordmark: fredoka(700).copyWith(color: Palette.tomato),
    label: fredoka(
      600,
      size: 14,
    ).copyWith(letterSpacing: 0.4, color: Palette.cocoaSoft),
  );

  /// Felt dimmed for a dark room; letter paper is brown fabric with cream
  /// handwriting, so text on it uses the dark scheme like the rest.
  static final dark = Knit(
    button: Palette.tomatoBright,
    buttonLight: Palette.tomatoLight,
    buttonDeep: Palette.tomatoDeep,
    thread: Palette.mustardLight,
    fabric: Palette.barkLifted,
    envelope: const Color(0xFFCC9C86),
    envelopeCalm: const Color(0xFF9DB8A9),
    outline: Palette.ink,
    stitch: Palette.tomatoLight,
    stitchCalm: Palette.sage,
    rule: const Color(0x4DA8957B),
    patch: const Color(0xFFE0C27A),
    glow: Palette.mustard,
    weave: const Color(0x14F1E8D8),
    shadow: const Color(0x99000000),
    letter: caveat(
      500,
      size: 24,
      height: 1.2,
    ).copyWith(color: Palette.oatLight),
    wordmark: fredoka(700).copyWith(color: Palette.tomatoLight),
    label: fredoka(
      600,
      size: 14,
    ).copyWith(letterSpacing: 0.4, color: Palette.tan),
  );

  /// The app theme's set; widgets pumped without `appTheme` (as in tests)
  /// get the light set.
  static Knit of(BuildContext context) =>
      Theme.of(context).extension<Knit>() ?? light;

  /// The sewn-on button that closes an envelope.
  final Color button;
  final Color buttonLight;
  final Color buttonDeep;

  /// Cross-stitch through the button's holes.
  final Color thread;

  /// Letter paper and cards.
  final Color fabric;

  /// Felt envelopes: delivered ones, and ones still on their way.
  final Color envelope;
  final Color envelopeCalm;

  /// Ink outline around drawings.
  final Color outline;

  /// Stitched seams: warm on cards and buttons, calm on letters.
  final Color stitch;
  final Color stitchCalm;

  /// Ruled lines on letter paper.
  final Color rule;

  /// Sewn-on date patches.
  final Color patch;

  /// Warm halo around a letter about to open.
  final Color glow;

  /// The wool texture behind screens.
  final Color weave;

  /// Shadows under cards; letter paper uses half its opacity.
  final Color shadow;

  /// The text of a letter, on `LetterPaper`.
  final TextStyle letter;

  /// "Laternote" set as a wordmark; size it with `copyWith(fontSize:)`.
  final TextStyle wordmark;

  /// Section headers and small labels.
  final TextStyle label;

  @override
  Knit copyWith() => this;

  @override
  Knit lerp(Knit? other, double t) => t < 0.5 || other == null ? this : other;
}
