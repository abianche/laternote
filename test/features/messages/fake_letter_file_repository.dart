import 'dart:typed_data';
import 'dart:ui';

import 'package:laternote/features/messages/data/letter_file_repository.dart';

/// In-memory [LetterFileRepository]: [shared] holds what was shared, [toPick]
/// is what the picker returns (null for a cancel), [error] makes both throw.
class FakeLetterFileRepository implements LetterFileRepository {
  final shared = <({Uint8List bytes, String name})>[];
  Uint8List? toPick;
  Object? error;

  @override
  Future<void> share(Uint8List bytes, String name, Rect? origin) async {
    if (error case final error?) throw error;
    shared.add((bytes: bytes, name: name));
  }

  @override
  Future<Uint8List?> pick() async {
    if (error case final error?) throw error;
    return toPick;
  }
}
