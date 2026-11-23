/// Links the OS hands to the app from outside: `io.laternote://auth/<kind>`.
/// The scheme is registered in the Android manifest and iOS Info.plist, and
/// every [authLinkUrl] is in the Supabase Auth redirect allow-list
/// (supabase/config.toml, docs/environments.md).
const deepLinkScheme = 'io.laternote';

const _authHost = 'auth';

/// The Supabase Auth email that sent the user back to the app.
enum AuthLinkKind {
  passwordReset('/reset-password'),
  emailConfirmation('/confirm-email'),
  magicLink('/magic-link');

  const AuthLinkKind(this.path);

  final String path;
}

/// The redirect URL to give Supabase Auth for [kind].
String authLinkUrl(AuthLinkKind kind) =>
    Uri(scheme: deepLinkScheme, host: _authHost, path: kind.path).toString();

/// Why a link can't be followed.
enum LinkProblem {
  /// The link was valid but is too old or already used.
  expired,

  /// The link is malformed or can't be used on this device.
  invalid,

  /// The app doesn't know this link.
  unrecognized,

  /// The device couldn't reach the backend to finish.
  network,
}

/// What an incoming link means.
sealed class DeepLink {
  const DeepLink();
}

/// A Supabase Auth callback carrying a PKCE code to exchange for a session.
final class AuthCallbackLink extends DeepLink {
  const AuthCallbackLink(this.kind, this.uri);

  final AuthLinkKind kind;
  final Uri uri;
}

/// A link the app can't follow.
final class BrokenLink extends DeepLink {
  const BrokenLink(this.problem);

  final LinkProblem problem;
}

const _expiredCodes = {'otp_expired', 'flow_state_expired'};

/// Classifies [uri]. The only place that interprets incoming links.
DeepLink parseDeepLink(Uri uri) {
  if (uri.scheme != deepLinkScheme || uri.host != _authHost) {
    return const BrokenLink(LinkProblem.unrecognized);
  }
  final kind = AuthLinkKind.values.where((k) => k.path == uri.path);
  if (kind.isEmpty) return const BrokenLink(LinkProblem.unrecognized);

  // Supabase puts errors in the fragment, the PKCE code in the query.
  final params = {
    ...Uri.splitQueryString(uri.fragment),
    ...uri.queryParameters,
  };
  if (params.containsKey('error') ||
      params.containsKey('error_code') ||
      params.containsKey('error_description')) {
    return BrokenLink(
      _expiredCodes.contains(params['error_code'])
          ? LinkProblem.expired
          : LinkProblem.invalid,
    );
  }
  if (params['code']?.isEmpty ?? true) {
    return const BrokenLink(LinkProblem.invalid);
  }
  return AuthCallbackLink(kind.single, uri);
}
