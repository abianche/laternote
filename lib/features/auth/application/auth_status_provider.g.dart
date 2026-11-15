// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current [AuthStatus], starting from the stored session.

@ProviderFor(authStatus)
final authStatusProvider = AuthStatusProvider._();

/// The current [AuthStatus], starting from the stored session.

final class AuthStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthStatus>,
          AuthStatus,
          Stream<AuthStatus>
        >
    with $FutureModifier<AuthStatus>, $StreamProvider<AuthStatus> {
  /// The current [AuthStatus], starting from the stored session.
  AuthStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusHash();

  @$internal
  @override
  $StreamProviderElement<AuthStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthStatus> create(Ref ref) {
    return authStatus(ref);
  }
}

String _$authStatusHash() => r'79d99c1b77d30257ce0753bb633c6bf7c1beb0e9';
