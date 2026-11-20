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
}
