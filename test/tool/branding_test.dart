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
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}
