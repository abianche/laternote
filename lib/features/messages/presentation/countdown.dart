import '../../../l10n/app_localizations.dart';

/// Time left until a message opens, in calendar units.
typedef Countdown = ({
  int years,
  int months,
  int days,
  int hours,
  int minutes,
});

/// Calendar time from [from] to [to]: whole months first (a month later is
/// the same day of the month, or its last day), then days, hours and
/// minutes. All zero when [to] isn't after [from].
Countdown countdownBetween(DateTime from, DateTime to) {
  if (!to.isAfter(from)) {
    return (years: 0, months: 0, days: 0, hours: 0, minutes: 0);
  }
  var months = (to.year - from.year) * 12 + to.month - from.month;
  if (_addMonths(from, months).isAfter(to)) months--;
  final rest = to.difference(_addMonths(from, months));
  return (
    years: months ~/ 12,
    months: months % 12,
    days: rest.inDays,
    hours: rest.inHours % 24,
    minutes: rest.inMinutes % 60,
  );
}

DateTime _addMonths(DateTime date, int months) {
  final month = date.month - 1 + months;
  final year = date.year + month ~/ 12;
  final lastDay = DateTime(year, month % 12 + 2, 0).day;
  return date.copyWith(
    year: year,
    month: month % 12 + 1,
    day: date.day > lastDay ? lastDay : date.day,
  );
}

/// The largest unit and, if not zero, the next one down: "2 years,
/// 3 months", "2 years", "5 hours, 1 minute".
String formatCountdown(AppLocalizations l10n, Countdown c) {
  final units = [
    (c.years, l10n.countdownYears),
    (c.months, l10n.countdownMonths),
    (c.days, l10n.countdownDays),
    (c.hours, l10n.countdownHours),
    (c.minutes, l10n.countdownMinutes),
  ];
  final first = units.indexWhere((u) => u.$1 > 0);
  if (first < 0) return l10n.countdownUnderMinute;
  final (count, unit) = units[first];
  final next = first + 1 < units.length ? units[first + 1] : null;
  return [
    unit(count),
    if (next != null && next.$1 > 0) next.$2(next.$1),
  ].join(', ');
}
