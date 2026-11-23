import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_repository.g.dart';

/// The only place that receives links from the OS.
class DeepLinkRepository {
  DeepLinkRepository(this._appLinks);

  final AppLinks _appLinks;

  /// Every incoming link: the one that launched the app first, then any
  /// that arrive while it runs in the background or foreground.
  Stream<Uri> get links => _appLinks.uriLinkStream;
}

@Riverpod(keepAlive: true)
DeepLinkRepository deepLinkRepository(Ref ref) =>
    DeepLinkRepository(AppLinks());
