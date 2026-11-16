import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_error.dart';

/// Message to show for a failed [AsyncValue], or null.
String? errorMessage(AsyncValue<Object?> value) => switch (value) {
  AsyncError(:final error) => switch (error) {
    AppError(:final message) => message,
    _ => const UnexpectedError().message,
  },
  _ => null,
};
