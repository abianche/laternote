import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l10n/app_localizations.dart';
import 'app_error.dart';
import 'tables.dart';

/// Localized message to show for a failed [AsyncValue], or null.
String? errorMessage(BuildContext context, AsyncValue<Object?> value) =>
    switch (value) {
      AsyncError(:final error) => appErrorText(
        AppLocalizations.of(context),
        error is AppError ? error : const UnexpectedError(),
      ),
      _ => null,
    };

/// Localized text for [error].
String appErrorText(AppLocalizations l10n, AppError error) => switch (error) {
  NetworkError() => l10n.errorNetwork,
  ValidationError(:final problem) => validationText(l10n, problem),
  UnexpectedError() => l10n.errorUnexpected,
};

/// Localized text for a [ValidationProblem].
String validationText(AppLocalizations l10n, ValidationProblem problem) =>
    switch (problem) {
      ValidationProblem.bodyEmpty => l10n.validationBodyEmpty,
      ValidationProblem.bodyTooLong => l10n.validationBodyTooLong(
        maxMessageLength,
      ),
      ValidationProblem.deliveryMissing => l10n.validationDeliveryMissing,
      ValidationProblem.deliveryInPast => l10n.validationDeliveryInPast,
      ValidationProblem.alreadyOpening => l10n.validationAlreadyOpening,
    };
