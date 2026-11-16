import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Current local time. Overridden in tests to pin "now".
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
