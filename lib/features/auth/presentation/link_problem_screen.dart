import 'package:material_ui/material_ui.dart';

import '../../../core/deep_link.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_form_widgets.dart';

/// Shown when the app was opened from a link it can't follow.
class LinkProblemScreen extends StatelessWidget {
  const LinkProblemScreen({required this.problem, super.key});

  final LinkProblem problem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LinkOutcome(
      icon: Icons.link_off,
      title: l10n.linkProblemTitle,
      message: switch (problem) {
        LinkProblem.expired => l10n.linkProblemExpired,
        LinkProblem.invalid => l10n.linkProblemInvalid,
        LinkProblem.unrecognized => l10n.linkProblemUnrecognized,
        LinkProblem.network => l10n.linkProblemNetwork,
      },
    );
  }
}
