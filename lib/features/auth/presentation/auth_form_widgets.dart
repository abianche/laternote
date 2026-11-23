import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/ui/envelope.dart';
import '../../../core/ui/wax_seal.dart';
import '../../../core/ui/wordmark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/validators.dart';

/// Localized text for an auth field [problem], or null when valid.
String? authFieldText(BuildContext context, AuthFieldProblem? problem) {
  if (problem == null) return null;
  final l10n = AppLocalizations.of(context);
  return switch (problem) {
    AuthFieldProblem.emailEmpty => l10n.validationEmailEmpty,
    AuthFieldProblem.emailInvalid => l10n.validationEmailInvalid,
    AuthFieldProblem.passwordEmpty => l10n.validationPasswordEmpty,
    AuthFieldProblem.passwordTooShort => l10n.validationPasswordTooShort(
      minPasswordLength,
    ),
    AuthFieldProblem.confirmationEmpty => l10n.validationConfirmationEmpty,
    AuthFieldProblem.passwordsDiffer => l10n.validationPasswordsDiffer,
  };
}

/// Centered, width-capped, scrollable sheet of paper shared by the auth
/// screens.
class AuthFormBody extends StatelessWidget {
  const AuthFormBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    );
  }
}

/// The seal, the wordmark and what Laternote is for.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const WaxSeal(size: 72),
        const SizedBox(height: 12),
        const Wordmark(size: 40),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).authTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Primary button that shows a spinner and is disabled while [isLoading].
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

/// Form-level error line, or nothing when [message] is null.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

/// "Check your email" confirmation with a way back to sign-in.
class EmailSentMessage extends StatelessWidget {
  const EmailSentMessage({
    required this.message,
    required this.onBack,
    super.key,
  });

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Envelope(width: 96, sealed: false, stamped: true),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onBack,
          child: Text(AppLocalizations.of(context).authBackToSignIn),
        ),
      ],
    );
  }
}

/// What happened with a link the app was opened from, and a way on.
class LinkOutcome extends StatelessWidget {
  const LinkOutcome({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: AuthFormBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(Routes.home),
              child: Text(AppLocalizations.of(context).linkContinue),
            ),
          ],
        ),
      ),
    );
  }
}
