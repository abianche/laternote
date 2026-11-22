import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';

/// Plain-language privacy notice as (title, text) pairs. Keep in sync with
/// PRIVACY.md.
List<(String, String)> privacySections(AppLocalizations l10n) => [
  (l10n.privacyDraftsTitle, l10n.privacyDraftsBody),
  (l10n.privacySealedTitle, l10n.privacySealedBody),
  (l10n.privacyNotificationsTitle, l10n.privacyNotificationsBody),
  (l10n.privacyTrackingTitle, l10n.privacyTrackingBody),
  (l10n.privacyDeletionTitle, l10n.privacyDeletionBody),
  (l10n.privacyBackupsTitle, l10n.privacyBackupsBody),
];

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (final (title, text) in privacySections(l10n)) ...[
            Text(title, style: titleStyle),
            const SizedBox(height: 8),
            Text(text),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
