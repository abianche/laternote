import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps an exception from a Supabase Auth call to a clear, recoverable
/// message to show in a form.
String describeAuthError(Object error) {
  if (error is AuthException) return error.message;
  if (error is SocketException || error is TimeoutException) {
    return 'No connection. Check your network and try again.';
  }
  return 'Something went wrong. Please try again.';
}
