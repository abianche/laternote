import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/database.dart';
import 'package:laternote/core/limits.dart';
import 'package:laternote/features/messages/data/letters_file.dart';

final exportedAt = DateTime.utc(2030, 1, 1);

final letters = [
  LetterRow(
    id: 'a',
    body: 'Dear me',
    scheduledFor: DateTime.utc(2030, 1, 2, 9),
    timezone: 'Europe/Rome',
    createdAt: DateTime.utc(2029, 6, 1),
  ),
  LetterRow(
    id: 'b',
    body: 'Ciao',
    scheduledFor: DateTime.utc(2029, 12, 1),
    timezone: 'America/New_York',
    createdAt: DateTime.utc(2029, 6, 2),
    openedAt: DateTime.utc(2029, 12, 2),
  ),
];

/// A valid file with [edit] applied to its JSON.
Uint8List file(void Function(Map<String, dynamic> json) edit) {
  final json = jsonDecode(
    utf8.decode(encodeLetters(letters, exportedAt)),
  ) as Map<String, dynamic>;
  edit(json);
  return utf8.encode(jsonEncode(json));
}

Map<String, dynamic> first(Map<String, dynamic> json) =>
    (json['letters'] as List).first as Map<String, dynamic>;

void main() {
  test('decodes what it encodes', () {
    expect(decodeLetters(encodeLetters(letters, exportedAt)), letters);
  });

  test('writes times in UTC', () {
    final local = [letters.first.copyWith(scheduledFor: DateTime(2030))];
    final json = utf8.decode(encodeLetters(local, exportedAt));

    expect(
      json,
      contains('"scheduledFor":"${DateTime(2030).toUtc().toIso8601String()}"'),
    );
  });

  test('accepts an offset time', () {
    final decoded = decodeLetters(
      file((j) => first(j)['scheduledFor'] = '2030-01-02T10:00:00+01:00'),
    );

    expect(decoded.first.scheduledFor, DateTime.utc(2030, 1, 2, 9));
  });

  final invalid = <String, List<int>>{
    'not JSON': utf8.encode('{"letters": ['),
    'not UTF-8': [0xff, 0xfe, 0x00],
    'another format': file((j) => j['format'] = 'other'),
    'another version': file((j) => j['version'] = 2),
    'letters missing': file((j) => j.remove('letters')),
    'a letter that is not an object': file((j) => j['letters'] = [1]),
    'a missing field': file((j) => first(j).remove('timezone')),
    'a field of the wrong type': file((j) => first(j)['body'] = 3),
    'an empty id': file((j) => first(j)['id'] = ''),
    'an empty body': file((j) => first(j)['body'] = ''),
    'a body too long': file(
      (j) => first(j)['body'] = 'x' * (maxMessageLength + 1),
    ),
    'a bad date': file((j) => first(j)['createdAt'] = 'yesterday'),
    'a date without zone': file(
      (j) => first(j)['createdAt'] = '2029-06-01T00:00:00',
    ),
    'a repeated id': file((j) => (j['letters'] as List)[1]['id'] = 'a'),
  };
  for (final MapEntry(key: name, value: bytes) in invalid.entries) {
    test('rejects $name', () {
      expect(
        () => decodeLetters(Uint8List.fromList(bytes)),
        throwsA(isA<InvalidFileError>()),
      );
    });
  }
}
