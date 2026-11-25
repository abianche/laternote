/// App-level error. Repositories catch storage and plugin errors and
/// rethrow them as one of these. Each case is turned into localized text in
/// the presentation layer.
sealed class AppError implements Exception {
  const AppError();
}

/// The device could not reach the backend.
final class NetworkError extends AppError {
  const NetworkError();
}

/// Input that a client-side check or the backend rejected.
enum ValidationProblem {
  bodyEmpty,
  bodyTooLong,
  deliveryMissing,
  deliveryInPast,
  alreadyOpening,
}

final class ValidationError extends AppError {
  const ValidationError(this.problem);

  final ValidationProblem problem;
}

/// A file to import that isn't a valid export; nothing was imported.
final class InvalidFileError extends AppError {
  const InvalidFileError();
}

/// Anything not covered above.
final class UnexpectedError extends AppError {
  const UnexpectedError();
}
