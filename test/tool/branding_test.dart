import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../../tool/branding/branding.dart';

void main() {
  test('renders every branding image as a square PNG', () async {
    final images = await renderBranding();

    expect(images.keys, {
      'icon-production.png',
      'icon-production-foreground.png',
      'icon-development.png',
      'icon-development-foreground.png',
      'splash.png',
    });
    for (final MapEntry(:key, :value) in images.entries) {
      final size = key == 'splash.png' ? splashSize : iconSize;
      final image = await _decode(value);
      expect((image.width, image.height), (size, size), reason: key);
    }
  });

  test('development and production icons differ', () async {
    final images = await renderBranding();

    expect(
      images['icon-development.png'],
      isNot(images['icon-production.png']),
    );
  });

  test('renders the feature graphic as a 1024x500 PNG without alpha', () async {
    final png = await renderFeatureGraphic();

    // Byte 25 is the header's color type; 2 is RGB.
    expect(png[25], 2);
    final image = await _decode(png);
    expect((image.width, image.height), (1024, 500));
    final pixels = (await image.toByteData())!;
    // (10, 10) is bare wool between the weave's threads.
    const offset = (10 * 1024 + 10) * 4;
    expect(
      [for (var i = 0; i < 4; i++) pixels.getUint8(offset + i)],
      [0xEF, 0xE6, 0xD6, 0xFF],
    );
  });
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}
