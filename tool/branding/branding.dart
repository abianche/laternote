import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:laternote/core/ui/button_seal.dart';
import 'package:laternote/core/ui/envelope.dart';
import 'package:laternote/core/ui/knit.dart';
import 'package:laternote/core/ui/stitches.dart';
import 'package:material_ui/material_ui.dart';

/// Source art for the app icons and launch screen, drawn with the app's own
/// painters. `flutter_launcher_icons` and `flutter_native_splash` turn these
/// into platform assets.
const iconSize = 1024.0;
const splashSize = 1152.0;

/// File name in `assets/branding/` → PNG bytes.
Future<Map<String, Uint8List>> renderBranding() async {
  await _loadFredoka();
  return {
    for (final dev in [false, true]) ...{
      'icon-${_flavor(dev)}.png': await _png(
        iconSize,
        (c) => _paintIcon(c, dev: dev),
      ),
      'icon-${_flavor(dev)}-foreground.png': await _png(
        iconSize,
        (c) => _paintMark(c, dev: dev, scale: 0.72),
      ),
    },
    'splash.png': await _png(splashSize, _paintSplash),
  };
}

/// Opaque background colors, also used for adaptive icon backgrounds.
const productionBackground = Palette.oat;
const developmentBackground = Palette.sage;

String _flavor(bool dev) => dev ? 'development' : 'production';

final _k = Knit.light;

Future<Uint8List> _png(double size, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder, Rect.fromLTWH(0, 0, size, size)));
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// The full icon: background, a stitched rim and the mark.
void _paintIcon(Canvas canvas, {required bool dev}) {
  const s = iconSize;
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, s, s),
    Paint()..color = dev ? developmentBackground : productionBackground,
  );
  drawStitches(
    canvas,
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(s * 0.07, s * 0.07, s * 0.86, s * 0.86),
        const Radius.circular(s * 0.17),
      ),
    ),
    stitchPaint(
      (dev ? Palette.sageDeep : Palette.tan).withValues(alpha: 0.8),
      width: s / 90,
    ),
    dash: s / 28,
    gap: s / 40,
  );
  _paintMark(canvas, dev: dev, scale: 0.62);
}

/// A sealed envelope centred on the canvas, [scale] × its width wide; the
/// development flavor gets a "DEV" patch sewn over its lower edge. At 0.72,
/// after the 16% inset Android adds, it stays in the adaptive safe zone.
void _paintMark(Canvas canvas, {required bool dev, required double scale}) {
  const s = iconSize;
  final w = s * scale;
  final h = w * Envelope.aspect;
  final bodyH = w * 0.64;
  final bodyCenterY = h - bodyH / 2;
  canvas
    ..save()
    ..translate((s - w) / 2, s / 2 - bodyCenterY);
  EnvelopePainter(
    _k,
    flap: 0,
    sealed: true,
    undone: 0,
    glow: 0,
    stamped: false,
    calm: false,
    letter: null,
  ).paint(canvas, Size(w, h));
  canvas.restore();
  if (dev) _paintDevPatch(canvas, Offset(s / 2, s / 2 + bodyH * 0.5), w);
}

void _paintDevPatch(Canvas canvas, Offset center, double envelopeWidth) {
  final w = envelopeWidth * 0.52;
  final h = envelopeWidth * 0.2;
  final patch = RRect.fromRectAndRadius(
    Rect.fromCenter(center: center, width: w, height: h),
    Radius.circular(h / 2),
  );
  canvas
    ..drawShadow(
      Path()..addRRect(patch),
      const Color(0xFF000000),
      h / 12,
      false,
    )
    ..drawRRect(patch, Paint()..color = Palette.mustard)
    ..drawRRect(
      patch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h / 16
        ..color = _k.outline,
    );
  drawStitches(
    canvas,
    Path()..addRRect(patch.deflate(h * 0.14)),
    stitchPaint(_k.outline.withValues(alpha: 0.7), width: h / 28),
    dash: h / 7,
    gap: h / 10,
  );
  final text = TextPainter(
    text: TextSpan(
      text: 'DEV',
      style: fredoka(
        700,
        size: h * 0.55,
      ).copyWith(color: _k.outline, letterSpacing: h * 0.05),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  text.dispose();
}

/// A button seal centred on a transparent canvas. Android 12+ shows it in a
/// circle two-thirds as wide, so it stays well inside that.
void _paintSplash(Canvas canvas) => paintButtonSeal(
  canvas,
  const Offset(splashSize / 2, splashSize / 2),
  splashSize * 0.2,
  _k,
);

Future<void> _loadFredoka() async {
  final bytes = await File('assets/fonts/Fredoka.ttf').readAsBytes();
  await (FontLoader(
    'Fredoka',
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}
