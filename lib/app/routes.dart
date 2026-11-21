/// Route locations. Nested paths give each child screen a back button to
/// its parent.
abstract final class Routes {
  static const home = '/';

  /// Home on the Sealed tab, e.g. right after sealing.
  static const sealed = '/?tab=sealed';
  static const compose = '/compose';
  static const composeReview = '/compose/review';
  static const account = '/account';
  static const privacy = '/account/privacy';
  static const signIn = '/sign-in';
  static const signUp = '/sign-in/sign-up';
  static const forgotPassword = '/sign-in/forgot-password';
  static const resetPassword = '/reset-password';

  /// A released message, opened from the inbox or a notification.
  static String message(String id) => '/messages/$id';

  static final _messagePath = RegExp(r'^/messages/[^/]+$');

  static bool isMessage(String location) => _messagePath.hasMatch(location);

  /// Sign-in that continues to [location] afterwards. Only a message is
  /// kept, since that's where a notification leads; anything else starts
  /// at home.
  static String signInThen(String location) => isMessage(location)
      ? Uri(path: signIn, queryParameters: {'from': location}).toString()
      : signIn;
}
