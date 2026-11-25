import 'dart:async';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../notifications/application/ready_notifications.dart';
import '../data/letter_file_repository.dart';
import '../data/letters_file.dart';
import '../data/messages_repository.dart';
import 'inbox.dart';
import 'upcoming_messages.dart';

part 'letter_transfer.g.dart';

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run: the number of letters an import added, or null after an export
/// or a cancelled pick.
@riverpod
class LetterTransfer extends _$LetterTransfer {
  @override
  FutureOr<int?> build() => null;

  /// Writes every letter to a file and opens the share sheet anchored at
  /// [origin].
  Future<void> export({Rect? origin}) => _run(() async {
    final now = ref.read(clockProvider)();
    final letters = await ref.read(messagesRepositoryProvider).exportAll();
    await ref
        .read(letterFileRepositoryProvider)
        .share(encodeLetters(letters, now), _fileName(now), origin);
    return null;
  });

  /// Adds the letters of a picked file that aren't on the device yet and
  /// schedules their notifications. An invalid file adds nothing.
  Future<void> import() => _run(() async {
    final bytes = await ref.read(letterFileRepositoryProvider).pick();
    if (bytes == null) return null;
    final letters = decodeLetters(bytes);
    final added = await ref
        .read(messagesRepositoryProvider)
        .importLetters(letters);
    if (added > 0 && ref.mounted) {
      ref
        ..invalidate(upcomingMessagesProvider)
        ..invalidate(availableMessagesProvider);
      unawaited(ref.read(readyNotificationsProvider.notifier).sync());
    }
    return added;
  });

  Future<void> _run(Future<int?> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }

  static String _fileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'laternote-${now.year}-${two(now.month)}-${two(now.day)}.json';
  }
}
