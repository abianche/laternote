import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Pumps an app with [locale] as the device locale and returns the
/// [AppLocalizations] it resolved.
Future<AppLocalizations> resolve(WidgetTester tester, Locale locale) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return l10n;
}

Map<String, dynamic> readArb(String file) =>
    jsonDecode(File('lib/l10n/$file').readAsStringSync())
        as Map<String, dynamic>;

Set<String> arbKeys(String file) =>
    readArb(file).keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  testWidgets('an Italian device gets Italian strings', (tester) async {
    final l10n = await resolve(tester, const Locale('it', 'IT'));

    expect(l10n.localeName, 'it');
    expect(
      l10n.inboxEmpty,
      'Non si è ancora aperto nulla. I tuoi messaggi arrivano qui quando è '
      'il loro momento.',
    );
  });

  testWidgets('an unsupported locale falls back to English', (tester) async {
    final l10n = await resolve(tester, const Locale('fr', 'FR'));

    expect(l10n.localeName, 'en');
    expect(
      l10n.inboxEmpty,
      'Nothing has opened yet. Your messages arrive here when their time '
      'comes.',
    );
  });

  test('English and Italian have the same keys', () {
    expect(arbKeys('app_it.arb'), arbKeys('app_en.arb'));
  });

  test(
    'every Italian string is filled in and uses the English placeholders',
    () {
      final en = readArb('app_en.arb');
      final it = readArb('app_it.arb');

      for (final key in arbKeys('app_en.arb')) {
        final italian = it[key] as String?;
        expect(italian?.trim(), isNotEmpty, reason: '$key is empty in Italian');

        final meta = en['@$key'] as Map<String, dynamic>?;
        final placeholders =
            (meta?['placeholders'] as Map<String, dynamic>?)?.keys ??
            const <String>[];
        for (final name in placeholders) {
          // A placeholder appears as `{name}` or, for plural/select, `{name,`.
          final use = RegExp('\\{${RegExp.escape(name)}\\s*[,}]');
          expect(
            use.hasMatch(en[key] as String),
            isTrue,
            reason: '$key does not use {$name} in English',
          );
          expect(
            use.hasMatch(italian!),
            isTrue,
            reason: '$key does not use {$name} in Italian',
          );
        }
      }
    },
  );
}
