import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';

/// "Saturday, December 20, 2027 at 9:00 AM (Europe/Rome)" in the device
/// locale. [timezone] is omitted while still loading.
String formatDelivery(BuildContext context, DateTime at, String? timezone) {
  final material = MaterialLocalizations.of(context);
  final time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(at),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
  final zone = timezone == null ? '' : ' ($timezone)';
  final when = AppLocalizations.of(
    context,
  ).deliveryDateTime(material.formatFullDate(at), time);
  return '$when$zone';
}
