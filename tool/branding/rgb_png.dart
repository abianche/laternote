import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Encodes opaque [rgba] pixels as an 8-bit RGB PNG, dropping the alpha
/// channel, which `dart:ui` always writes.
Uint8List encodeRgbPng(
  Uint8List rgba, {
  required int width,
  required int height,
}) {
  // Each row is a filter byte (0, none) followed by its pixels.
  final stride = 1 + width * 3;
  final rows = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final from = (y * width + x) * 4;
      final to = y * stride + 1 + x * 3;
      rows.setRange(to, to + 3, rgba, from);
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // Bit depth.
    ..setUint8(9, 2); // Color type: RGB.
  return (BytesBuilder()
        ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        ..add(_chunk('IHDR', header.buffer.asUint8List()))
        ..add(_chunk('IDAT', zlib.encode(rows)))
        ..add(_chunk('IEND', const [])))
      .takeBytes();
}

/// Length, type, data and the CRC-32 of type and data.
Uint8List _chunk(String type, List<int> data) {
  final bytes = Uint8List(12 + data.length)
    ..setRange(4, 8, ascii.encode(type))
    ..setRange(8, 8 + data.length, data);
  final view = ByteData.sublistView(bytes);
  var crc = 0xFFFFFFFF;
  for (final byte in bytes.getRange(4, 8 + data.length)) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = crc.isOdd ? 0xEDB88320 ^ (crc >> 1) : crc >> 1;
    }
  }
  view
    ..setUint32(0, data.length)
    ..setUint32(8 + data.length, crc ^ 0xFFFFFFFF);
  return bytes;
}
