import 'package:material_ui/material_ui.dart';

/// "Saturday, December 20, 2027 at 9:00 AM (Europe/Rome)" in the device
/// locale. [timezone] is omitted while still loading.
String formatDelivery(BuildContext context, DateTime at, String? timezone) {
  final l10n = MaterialLocalizations.of(context);
  final time = l10n.formatTimeOfDay(
    TimeOfDay.fromDateTime(at),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
  final zone = timezone == null ? '' : ' ($timezone)';
  return '${l10n.formatFullDate(at)} at $time$zone';
}
