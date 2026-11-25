import 'dart:typed_data';
import 'dart:ui';

import 'package:laternote/features/messages/data/letter_file_repository.dart';

/// In-memory [LetterFileRepository]: [shared] and [saved] hold what was
/// shared and saved, [cancelSave] cancels the save dialog, [toPick] is what
/// the picker returns (null for a cancel), [error] makes every call throw.
class FakeLetterFileRepository implements LetterFileRepository {
  final shared = <({Uint8List bytes, String name})>[];
  final saved = <({Uint8List bytes, String name})>[];
  bool cancelSave = false;
  Uint8List? toPick;
  Object? error;

  @override
  Future<void> share(Uint8List bytes, String name, Rect? origin) async {
    if (error case final error?) throw error;
    shared.add((bytes: bytes, name: name));
  }

  @override
  Future<bool> save(Uint8List bytes, String name) async {
    if (error case final error?) throw error;
    if (cancelSave) return false;
    saved.add((bytes: bytes, name: name));
    return true;
  }

  @override
  Future<Uint8List?> pick() async {
    if (error case final error?) throw error;
    return toPick;
  }
}
