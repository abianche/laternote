import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/messages/presentation/countdown.dart';
import 'package:laternote/l10n/app_localizations_en.dart';
import 'package:laternote/l10n/app_localizations_it.dart';

void main() {
  final from = DateTime(2030, 1, 31, 12);

  group('countdownBetween', () {
    test('counts calendar months, clamping to the month end', () {
      expect(countdownBetween(from, DateTime(2030, 2, 28, 12)), (
        years: 0,
        months: 1,
        days: 0,
        hours: 0,
        minutes: 0,
      ));
    });

    test('splits years, months, days, hours and minutes', () {
      expect(countdownBetween(from, DateTime(2032, 4, 2, 15, 7)), (
        years: 2,
        months: 2,
        days: 2,
        hours: 3,
        minutes: 7,
      ));
    });

    test('a month not yet complete counts as days', () {
      expect(countdownBetween(from, DateTime(2030, 2, 27, 12)).months, 0);
      expect(countdownBetween(from, DateTime(2030, 2, 27, 12)).days, 27);
    });

    test('is zero when the time has come', () {
      expect(countdownBetween(from, from), (
        years: 0,
        months: 0,
        days: 0,
        hours: 0,
        minutes: 0,
      ));
      expect(
        countdownBetween(from, from.subtract(const Duration(days: 3))).days,
        0,
      );
    });
  });

  group('formatCountdown', () {
    final en = AppLocalizationsEn();
    final it = AppLocalizationsIt();
    Countdown c({int y = 0, int mo = 0, int d = 0, int h = 0, int mi = 0}) =>
        (years: y, months: mo, days: d, hours: h, minutes: mi);

    test('shows the largest unit and the next one down', () {
      expect(formatCountdown(en, c(y: 2, mo: 3, d: 4)), '2 years, 3 months');
      expect(formatCountdown(en, c(d: 1, h: 1, mi: 5)), '1 day, 1 hour');
      expect(formatCountdown(en, c(mi: 1)), '1 minute');
    });

    test('skips a zero next unit rather than jumping further down', () {
      expect(formatCountdown(en, c(y: 2, d: 5)), '2 years');
    });

    test('under a minute', () {
      expect(formatCountdown(en, c()), 'less than a minute');
      expect(formatCountdown(it, c()), 'meno di un minuto');
    });

    test('Italian plurals', () {
      expect(formatCountdown(it, c(y: 1, mo: 2)), '1 anno, 2 mesi');
      expect(formatCountdown(it, c(h: 5, mi: 1)), '5 ore, 1 minuto');
    });
  });
}
