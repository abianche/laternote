import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_controllers.dart';
import '../application/validators.dart';
import '../data/auth_status.dart';
import 'auth_form_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(signUpControllerProvider.notifier)
        .signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpControllerProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authCreateAccountTitle)),
      body: AuthFormBody(
        // A signed-in outcome needs nothing here: the router moves the user
        // to the home screen.
        child: switch (state) {
          AsyncData(value: SignUpOutcome.confirmationRequired) =>
            EmailSentMessage(
              message: l10n.authConfirmEmailSent,
              onBack: () => context.go(Routes.signIn),
            ),
          _ => Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: l10n.commonEmail),
                  validator: (value) =>
                      authFieldText(context, validateEmail(value)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(labelText: l10n.commonPassword),
                  validator: (value) =>
                      authFieldText(context, validatePassword(value)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.authConfirmPassword,
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
                  label: l10n.authCreateAccountButton,
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
