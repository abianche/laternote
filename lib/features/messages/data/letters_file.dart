import 'dart:convert';
import 'dart:typed_data';

import '../../../core/app_error.dart';
import '../../../core/database.dart';
import '../../../core/limits.dart';

const _format = 'laternote-letters';
const _version = 1;

/// Writes [letters] as an export file (UTF-8 JSON, all times in UTC).
Uint8List encodeLetters(List<LetterRow> letters, DateTime exportedAt) =>
    utf8.encode(
      jsonEncode({
        'format': _format,
        'version': _version,
        'exportedAt': _time(exportedAt),
        'letters': [
          for (final l in letters)
            {
              'id': l.id,
              'body': l.body,
              'scheduledFor': _time(l.scheduledFor),
              'timezone': l.timezone,
              'createdAt': _time(l.createdAt),
              'openedAt': l.openedAt == null ? null : _time(l.openedAt!),
            },
        ],
      }),
    );

/// Reads an export file. Anything that isn't a valid file of this version,
/// including one invalid letter or a repeated ID, rejects the whole file
/// with an [InvalidFileError].
List<LetterRow> decodeLetters(Uint8List bytes) {
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const InvalidFileError();
  }
  if (json case {
    'format': _format,
    'version': _version,
    'letters': final List<Object?> items,
  }) {
    final letters = [for (final item in items) _letter(item)];
    if ({for (final l in letters) l.id}.length != letters.length) {
      throw const InvalidFileError();
    }
    return letters;
  }
  throw const InvalidFileError();
}

LetterRow _letter(Object? item) => switch (item) {
  {
    'id': String id,
    'body': String body,
    'scheduledFor': String scheduledFor,
    'timezone': String timezone,
    'createdAt': String createdAt,
    'openedAt': String? openedAt,
  }
      when id.isNotEmpty &&
          timezone.isNotEmpty &&
          body.isNotEmpty &&
          body.length <= maxMessageLength =>
    LetterRow(
      id: id,
      body: body,
      scheduledFor: _parse(scheduledFor),
      timezone: timezone,
      createdAt: _parse(createdAt),
      openedAt: openedAt == null ? null : _parse(openedAt),
    ),
  _ => throw const InvalidFileError(),
};

String _time(DateTime t) => t.toUtc().toIso8601String();

/// An ISO 8601 time with a zone (`Z` or an offset); a time without one would
/// depend on the reading device's zone.
DateTime _parse(String value) {
  final time = DateTime.tryParse(value);
  if (time == null || !time.isUtc) throw const InvalidFileError();
  return time;
}
