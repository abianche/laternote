import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_controllers.dart';
import '../application/validators.dart';
import 'auth_form_widgets.dart';

/// Shown when the app is opened from a password-recovery link. The user
/// already has a temporary recovery session at this point; submitting here
/// sets a new password for that account.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(resetPasswordControllerProvider.notifier)
        .updatePassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authNewPasswordTitle)),
      body: AuthFormBody(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(labelText: l10n.authNewPassword),
                validator: (value) =>
                    authFieldText(context, validatePassword(value)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.authConfirmNewPassword,
                ),
                validator: (value) => authFieldText(
                  context,
                  validatePasswordConfirmation(
                    _passwordController.text,
                    value ?? '',
                  ),
                ),
              ),
              FormErrorText(errorMessage(context, state)),
              const SizedBox(height: 24),
              SubmitButton(
                label: l10n.authUpdatePassword,
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
