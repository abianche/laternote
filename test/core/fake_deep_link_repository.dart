import 'dart:async';

import 'package:laternote/core/deep_link_repository.dart';

/// [DeepLinkRepository] whose links are added by the test.
class FakeDeepLinkRepository implements DeepLinkRepository {
  final incoming = StreamController<Uri>.broadcast();

  Future<void> close() => incoming.close();

  @override
  Stream<Uri> get links => incoming.stream;
}
