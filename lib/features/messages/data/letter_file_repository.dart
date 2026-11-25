import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_error.dart';

part 'letter_file_repository.g.dart';

/// Largest file import reads. Far above any real export (letters are text),
/// it keeps a wrong pick from loading a huge file into memory.
const maxImportBytes = 50 * 1024 * 1024;

/// The only place that hands files to and takes files from the OS. Plugin
/// failures are rethrown as [AppError]s.
class LetterFileRepository {
  const LetterFileRepository();

  /// Opens the share sheet with [bytes] as a JSON file named [name].
  /// [origin] anchors the sheet on iPad.
  Future<void> share(Uint8List bytes, String name, Rect? origin) =>
      _guard(() async {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'application/json')],
            fileNameOverrides: [name],
            sharePositionOrigin: origin,
          ),
        );
      });

  /// Opens the system save dialog for [bytes] as a JSON file named [name].
  /// Returns false when the user cancels.
  Future<bool> save(Uint8List bytes, String name) => _guard(() async {
    final saved = await FilePicker.saveFile(
      fileName: name,
      bytes: bytes,
      mimeType: 'application/json',
    );
    return saved != null;
  });

  /// Lets the user pick a JSON file and returns its content, or null when
  /// they cancel.
  Future<Uint8List?> pick() => _guard(() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    if ((await file.length() ?? 0) > maxImportBytes) {
      throw const InvalidFileError();
    }
    return file.readAsBytes();
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppError {
      rethrow;
    } on Exception {
      // PlatformException and I/O failures from the plugins.
      throw const UnexpectedError();
    }
  }
}

@Riverpod(keepAlive: true)
LetterFileRepository letterFileRepository(Ref ref) =>
    const LetterFileRepository();
