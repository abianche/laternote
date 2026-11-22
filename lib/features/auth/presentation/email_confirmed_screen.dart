import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import 'auth_form_widgets.dart';

/// Shown after an email-confirmation link signed the user in.
class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LinkOutcome(
      icon: Icons.verified_outlined,
      title: l10n.linkEmailConfirmedTitle,
      message: l10n.linkEmailConfirmedBody,
    );
  }
}
